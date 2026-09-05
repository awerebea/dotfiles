#!/usr/bin/env python3

"""
video_geo_tagger.py

Infer GPS coordinates for videos by correlating them, in time, with geotagged
photos taken nearby in the archive.

Most videos in this archive already carry coordinates. The ones that do not
were usually shot alongside photos that do, minutes apart and in the same
place, so the surrounding photos can supply a position that is good enough to
put the video on a map.

    analyze    find candidates, classify every video, write a CSV report
    apply      write coordinates for rows approved in a reviewed CSV
    validate   run the same inference against videos that ALREADY have
               coordinates and report the error, to calibrate the thresholds
    config     show the config file in use, or write a starter template

Which timestamp is trusted
--------------------------
FileModifyDate is the authoritative capture time for videos here, and
QuickTime CreateDate is ignored outright. CreateDate is stored in UTC per
spec, files re-encoded through Tdarr had local time written into that UTC
field, and GoPro footage carries a 2016 date because the camera clock was
never set. mtime has been curated across the whole archive instead, and the
same timestamp is encoded in every filename.

That makes mtime load-bearing, with two consequences. Every write preserves it
at nanosecond precision. And each video's mtime is cross-checked against the
timestamp in its own filename: a disagreement means something touched the file
and the video is held back for review rather than geotagged.

The cross-check is also a timezone guard. mtime is stored as an epoch, so it
only renders back to the curated wall-clock time in the timezone the archive
was curated in. Run this somewhere else and essentially every video reports a
mismatch, which is loud and obvious rather than silently wrong.

For photos, exif:DateTimeOriginal is used: local time, and reliable.

Algorithm
---------
For each video lacking coordinates:

 1. Take its mtime as the capture time.
 2. Collect geotagged photos within --window of that time, from the directory
    chosen by --scope.
 3. Take the median latitude and the median longitude independently. A mean
    would put two photos on opposite sides of a bay into the water; a median
    picks a real place. Candidates further than --radius from that median are
    discarded as outliers and the median is recomputed.
 4. Measure the spread: the furthest any candidate sits from the median. A
    spread beyond --radius means the subject was moving, so no position is
    claimed.
 5. Measure the implied speed between the nearest photo before and the nearest
    photo after. Walking pace means stationary and safe.
 6. Emit coordinates rounded to --precision decimals, about 10 m at the
    default of 4, so the result cannot be mistaken for a measured fix.

Devices are deliberately not filtered on. Phones sync their clocks over the
network, and requiring the same camera would throw away every case where one
person shoots video while another shoots photos. The matched photos' devices
are reported as context instead.

Result categories
-----------------
    confident                       both sides, tight, slow, enough candidates
    review: one-sided               candidates only before, or only after
    review: scattered               spread exceeds --radius
    review: moving                  implied speed exceeds --max-speed
    review: below-minimum           fewer candidates than --min-candidates
    review: single-candidate        exactly one geotagged photo in the window
    review: filename-time-mismatch  mtime disagrees with the filename
    review: no-filename-time        filename carries no timestamp to check
    skipped: no candidates          nothing geotagged in the window
    skipped: already geotagged      the video already has coordinates
    skipped: already inferred       carries this tool's marker; use --force

Only 'confident' is applied automatically, and only when --apply is given.
Everything else is reported for a human to approve by editing the CSV.

Writing
-------
Writes go to the video's XMP sidecar and nowhere else. Original media files are
never modified, and a video that already has coordinates is never overwritten:
the disagreement is reported instead.

Each written sidecar records its provenance in a private XMP namespace:

    XMP-vidgeo:GeoInferred    geo-inferred:YYYY-MM-DD
    XMP-vidgeo:GeoConfidence  confident
    XMP-vidgeo:GeoCandidates  7
    XMP-vidgeo:GeoSpread      42            (metres)

Recording the spread separately is what makes a low-precision inference
revocable later without recomputing anything:

    exiftool -config ~/.config/video_geo_tagger/ExifTool_config \\
        -if '$GeoSpread > 100' -p '$FilePath' -r ~/Photo
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import math
import os
import statistics
import sys
from bisect import bisect_left
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable, Sequence

# Run from a source checkout as well as through the symlink on PATH: the
# package lives one directory up from this entry point either way, and
# resolve() follows the symlink to get there.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from photo_archive import bootstrap

if __name__ == "__main__":
    # Only when run as a program: importing this module should never replace
    # the importing process.
    bootstrap.reexec("video_geo_tagger", Path(__file__).resolve())

from photo_archive import media, settings
from photo_archive.exif import ExifTool, Namespace
from photo_archive.util import (
    LOG,
    Stats,
    human_distance,
    human_duration,
    setup_logging,
)

DEFAULT_PATH = Path("~/Photo").expanduser()
CONFIG_DIR = Path("~/.config/video_geo_tagger").expanduser()
EXIFTOOL_CONFIG = CONFIG_DIR / "ExifTool_config"
CONFIG_FILE = CONFIG_DIR / "config.toml"
DEFAULT_CSV = Path("~/video_geo_tagger_report.csv").expanduser()

# Defaults chosen from a calibration run over the 2881 videos in this archive
# that already carry coordinates. See the README for the measured numbers; the
# short version is that --radius does the protecting, not --window, and that
# every gross error in the confident bucket came from a two-candidate match.
DEFAULT_WINDOW_HOURS = 4.0
DEFAULT_RADIUS_M = 300.0
DEFAULT_MIN_CANDIDATES = 3
DEFAULT_MAX_SPEED_KMH = 10.0
DEFAULT_PRECISION = 4
DEFAULT_TIME_TOLERANCE_S = 1.0

# Private XMP namespace for this tool's provenance. Distinct from the face
# tagger's 'vidfaces' so the two never collide, and chosen so no other tool in
# the pipeline (digiKam, Immich, exiv2) has any reason to touch it.
VG_NAMESPACE_URI = "http://ns.awerebea.net/videogeo/1.0/"
VG_PREFIX = "vidgeo"

VIDGEO_NS = Namespace(
    prefix=VG_PREFIX,
    uri=VG_NAMESPACE_URI,
    tags=("GeoInferred", "GeoConfidence", "GeoCandidates", "GeoSpread"),
    group2="Location",
)

EXIF = ExifTool(
    config_path=EXIFTOOL_CONFIG,
    namespace=VIDGEO_NS,
    generator="video_geo_tagger.py",
)

MARKER_TAG = VIDGEO_NS.qualify("GeoInferred")
CONFIDENCE_TAG = VIDGEO_NS.qualify("GeoConfidence")
CANDIDATES_TAG = VIDGEO_NS.qualify("GeoCandidates")
SPREAD_TAG = VIDGEO_NS.qualify("GeoSpread")
MARKER_PREFIX = "geo-inferred:"

LAT_TAG = "XMP-exif:GPSLatitude"
LON_TAG = "XMP-exif:GPSLongitude"
PHOTO_TIME_TAG = "XMP-exif:DateTimeOriginal"
PHOTO_MODEL_TAG = "XMP-tiff:Model"

# QuickTime stores video coordinates here rather than in GPSLatitude. Measured
# on this archive the sidecar is a strict superset of the file (no video has
# coordinates in the file but not the sidecar), so reading sidecars alone is
# both correct and roughly forty times faster than opening every .mov.
QUICKTIME_GPS_TAG = "GPSCoordinates"

CONFIDENT = "confident"
CATEGORY_ORDER = (
    CONFIDENT,
    "review: one-sided",
    "review: scattered",
    "review: moving",
    "review: below-minimum",
    "review: single-candidate",
    "review: filename-time-mismatch",
    "review: no-filename-time",
    "skipped: no candidates",
    "skipped: already geotagged",
    "skipped: already inferred",
)


# ---------------------------------------------------------------------------
# geodesy
# ---------------------------------------------------------------------------

EARTH_RADIUS_M = 6371008.8


def haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Great-circle distance in metres.

    Accurate to about 0.5% on a sphere, which is far below the precision this
    tool claims, and it has no trouble with the antimeridian or the poles.
    """
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = phi2 - phi1
    dlambda = math.radians(lon2 - lon1)
    h = (
        math.sin(dphi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    )
    return 2 * EARTH_RADIUS_M * math.asin(min(1.0, math.sqrt(h)))


def median_point(points: Sequence[tuple[float, float]]) -> tuple[float, float]:
    """Median latitude and median longitude, taken independently.

    Deliberately not a mean: two photos on opposite shores of a bay average to
    a point in the water, while the median always lands on one of them.
    """
    return (
        statistics.median([p[0] for p in points]),
        statistics.median([p[1] for p in points]),
    )


def spread_from(centre: tuple[float, float], points: Iterable[tuple[float, float]]) -> float:
    """Distance from centre to the furthest point."""
    return max(
        (haversine(centre[0], centre[1], lat, lon) for lat, lon in points),
        default=0.0,
    )


# ---------------------------------------------------------------------------
# the photo index
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class PhotoPoint:
    """A geotagged photo, reduced to what the correlation needs."""

    path: Path
    when: dt.datetime
    lat: float
    lon: float
    model: str | None

    @property
    def coord(self) -> tuple[float, float]:
        return (self.lat, self.lon)


def parse_exif_datetime(value: Any) -> dt.datetime | None:
    """Parse exiftool's 'YYYY:MM:DD HH:MM:SS' into a naive local datetime.

    Any timezone suffix is dropped rather than honoured: DateTimeOriginal is
    local wall-clock time here, and the videos it is compared against are too.
    """
    if not value:
        return None
    text = str(value).strip()
    if text.startswith("0000"):
        return None  # a few iPhone files carry 0000:00:00 00:00:00
    try:
        return dt.datetime.strptime(text[:19], "%Y:%m:%d %H:%M:%S")
    except ValueError:
        return None


def build_photo_index(
    scan_path: Path, stats: Stats, jobs: int = 1
) -> dict[Path, list[PhotoPoint]]:
    """Map directory -> geotagged photos in it, sorted by time.

    Reads sidecars only. Every geotagged photo in this archive has its position
    mirrored into the sidecar, and 23k small XML files read far faster than 23k
    JPEGs.
    """
    photos = media.discover_photos(scan_path)
    stats.bump("photos seen", len(photos))
    if not photos:
        return {}

    sidecars = [media.sidecar_for(p) for p in photos]
    existing = [s for s in sidecars if s.exists()]
    stats.bump("photo sidecars read", len(existing))
    LOG.info("reading %d photo sidecar(s)...", len(existing))

    records = EXIF.read(
        existing,
        [LAT_TAG, LON_TAG, PHOTO_TIME_TAG, PHOTO_MODEL_TAG],
        numeric=True,
        jobs=jobs,
    )

    index: dict[Path, list[PhotoPoint]] = defaultdict(list)
    for sidecar in existing:
        rec = records.get(sidecar) or records.get(Path(os.path.normpath(sidecar)))
        if not rec:
            continue
        lat, lon = rec.get(LAT_TAG), rec.get(LON_TAG)
        when = parse_exif_datetime(rec.get(PHOTO_TIME_TAG))
        if lat is None or lon is None:
            stats.bump("photos without coordinates")
            continue
        if when is None:
            stats.bump("photos without a usable DateTimeOriginal")
            continue
        photo = media.media_for(sidecar)
        index[photo.parent].append(
            PhotoPoint(
                path=photo,
                when=when,
                lat=float(lat),
                lon=float(lon),
                model=rec.get(PHOTO_MODEL_TAG),
            )
        )

    for entries in index.values():
        entries.sort(key=lambda p: p.when)
    stats.bump("geotagged photos indexed", sum(len(v) for v in index.values()))
    return dict(index)


class PhotoLookup:
    """Answers 'which geotagged photos are near this time, in this scope?'."""

    def __init__(self, index: dict[Path, list[PhotoPoint]], scope: str, root: Path):
        self._index = index
        self._scope = scope
        self._root = root
        # Each pool is cached alongside its sorted list of times, so the
        # bisect key is built once per directory rather than once per video.
        self._pools: dict[Path, tuple[list[PhotoPoint], list[dt.datetime]]] = {}

    def _pool(self, directory: Path) -> tuple[list[PhotoPoint], list[dt.datetime]]:
        key = directory
        if self._scope == "tree":
            key = self._root
        elif self._scope == "dir+siblings":
            key = directory.parent

        cached = self._pools.get(key)
        if cached is not None:
            return cached

        if self._scope == "dir":
            gathered = list(self._index.get(key, []))
        else:
            gathered = []
            for candidate_dir, entries in self._index.items():
                if candidate_dir == key or key in candidate_dir.parents:
                    gathered.extend(entries)
            gathered.sort(key=lambda p: p.when)

        cached = (gathered, [p.when for p in gathered])
        self._pools[key] = cached
        return cached

    def within(self, directory: Path, when: dt.datetime, window_s: float) -> list[PhotoPoint]:
        pool, times = self._pool(directory)
        if not pool:
            return []
        lo = bisect_left(times, when - dt.timedelta(seconds=window_s))
        hi = bisect_left(times, when + dt.timedelta(seconds=window_s))
        return pool[lo:hi]

    def nearest_gap(self, directory: Path, when: dt.datetime) -> float | None:
        """Seconds to the closest geotagged photo, ignoring the window.

        Reported for videos that found nothing, so a run tells you how much
        wider a window would have to be before it helped.
        """
        pool, times = self._pool(directory)
        if not pool:
            return None
        i = bisect_left(times, when)
        return min(
            abs((times[j] - when).total_seconds())
            for j in (i - 1, i)
            if 0 <= j < len(times)
        )


# ---------------------------------------------------------------------------
# inference
# ---------------------------------------------------------------------------


@dataclass
class Result:
    """One video's verdict, and everything the report needs to explain it."""

    video: Path
    category: str
    when: dt.datetime | None = None
    filename_time: dt.datetime | None = None
    lat: float | None = None
    lon: float | None = None
    candidates: int = 0
    inliers: int = 0
    spread_m: float | None = None
    speed_kmh: float | None = None
    before_gap_s: float | None = None
    after_gap_s: float | None = None
    nearest_gap_s: float | None = None
    devices: tuple[str, ...] = ()
    photos: tuple[str, ...] = ()
    existing: tuple[float, float] | None = None
    error_m: float | None = None
    note: str = ""

    @property
    def approved(self) -> bool:
        return self.category == CONFIDENT

    @property
    def has_position(self) -> bool:
        return self.lat is not None and self.lon is not None


@dataclass
class Thresholds:
    window_s: float
    radius_m: float
    min_candidates: int
    max_speed_kmh: float
    precision: int
    time_tolerance_s: float


def classify(
    video: Path,
    when: dt.datetime,
    candidates: Sequence[PhotoPoint],
    limits: Thresholds,
) -> Result:
    """Turn a set of nearby geotagged photos into a verdict.

    Category precedence is deliberate: the checks that say 'this position is
    wrong' (scattered, moving) come before the ones that say 'this position is
    thin' (below-minimum, one-sided), so the report names the most serious
    reason a video was held back.
    """
    result = Result(video=video, category=CONFIDENT, when=when)
    result.candidates = len(candidates)
    if not candidates:
        return Result(video=video, category="skipped: no candidates", when=when)

    coords = [c.coord for c in candidates]
    centre = median_point(coords)
    result.spread_m = spread_from(centre, coords)

    # Outlier discard, then recompute. When the spread is already inside the
    # radius nothing is dropped and this is a no-op; it only matters for the
    # scattered case, where it gives the human a saner suggestion to look at.
    inliers = [
        c
        for c in candidates
        if haversine(centre[0], centre[1], c.lat, c.lon) <= limits.radius_m
    ]
    if inliers and len(inliers) < len(candidates):
        centre = median_point([c.coord for c in inliers])
    result.inliers = len(inliers)
    result.lat = round(centre[0], limits.precision)
    result.lon = round(centre[1], limits.precision)

    result.devices = tuple(sorted({c.model for c in candidates if c.model}))
    result.photos = tuple(c.path.name for c in candidates)

    before = [c for c in candidates if c.when <= when]
    after = [c for c in candidates if c.when > when]
    if before:
        result.before_gap_s = (when - before[-1].when).total_seconds()
    if after:
        result.after_gap_s = (after[0].when - when).total_seconds()

    # Implied travel speed between the photos bracketing the video. Note this
    # is nearly inert at a tight radius, where the candidates cannot be far
    # apart by construction; it earns its keep when two photos sit seconds
    # apart but hundreds of metres apart.
    if before and after:
        gap_s = (after[0].when - before[-1].when).total_seconds()
        distance = haversine(
            before[-1].lat, before[-1].lon, after[0].lat, after[0].lon
        )
        if gap_s > 0:
            result.speed_kmh = distance / gap_s * 3.6
        elif distance > 0:
            result.speed_kmh = math.inf

    if result.spread_m > limits.radius_m:
        result.category = "review: scattered"
    elif result.speed_kmh is not None and result.speed_kmh > limits.max_speed_kmh:
        result.category = "review: moving"
    elif len(candidates) == 1:
        result.category = "review: single-candidate"
    elif len(candidates) < limits.min_candidates:
        result.category = "review: below-minimum"
    elif not before or not after:
        result.category = "review: one-sided"
    return result


def apply_time_check(result: Result, video: Path, limits: Thresholds) -> Result:
    """Downgrade a verdict when the video's own timestamps disagree.

    The capture time is the input to everything else, so a video whose mtime
    does not match the timestamp in its filename is never geotagged
    automatically, however good its candidates look.
    """
    stamp = media.filename_timestamp(video)
    result.filename_time = stamp
    if result.category.startswith("skipped"):
        return result
    if stamp is None:
        result.category = "review: no-filename-time"
        result.note = "filename carries no timestamp to cross-check"
        return result
    if result.when is not None:
        drift = abs((result.when - stamp).total_seconds())
        if drift > limits.time_tolerance_s:
            result.category = "review: filename-time-mismatch"
            result.note = f"mtime is {human_duration(drift)} from the filename"
    return result


def video_capture_time(video: Path) -> dt.datetime:
    """The authoritative capture time: mtime, rendered in local time.

    Matches what exiftool prints for FileModifyDate, which is what the archive
    was curated against.
    """
    return dt.datetime.fromtimestamp(video.stat().st_mtime)


# ---------------------------------------------------------------------------
# reading the archive
# ---------------------------------------------------------------------------


@dataclass
class VideoState:
    """What the sidecar already says about one video."""

    video: Path
    lat: float | None
    lon: float | None
    marker: str | None

    @property
    def geotagged(self) -> bool:
        return self.lat is not None and self.lon is not None


def read_video_states(
    videos: Sequence[Path], jobs: int = 1
) -> dict[Path, VideoState]:
    """Read coordinates and the provenance marker for every video, in one pass."""
    sidecars = [media.sidecar_for(v) for v in videos]
    existing = [s for s in sidecars if s.exists()]
    records = EXIF.read(
        existing,
        [LAT_TAG, LON_TAG, MARKER_TAG, QUICKTIME_GPS_TAG],
        numeric=True,
        jobs=jobs,
    )
    states: dict[Path, VideoState] = {}
    for video, sidecar in zip(videos, sidecars):
        rec = records.get(sidecar) or records.get(Path(os.path.normpath(sidecar))) or {}
        lat, lon = rec.get(LAT_TAG), rec.get(LON_TAG)
        if lat is None and rec.get(QUICKTIME_GPS_TAG):
            # Belt and braces: no video in this archive stores a position only
            # in the QuickTime field, but a future import might.
            parts = str(rec[QUICKTIME_GPS_TAG]).split()
            if len(parts) >= 2:
                try:
                    lat, lon = float(parts[0]), float(parts[1])
                except ValueError:
                    lat = lon = None
        marker = rec.get(MARKER_TAG)
        states[video] = VideoState(
            video=video,
            lat=float(lat) if lat is not None else None,
            lon=float(lon) if lon is not None else None,
            marker=str(marker) if marker else None,
        )
    return states


# ---------------------------------------------------------------------------
# the CSV report
# ---------------------------------------------------------------------------

CSV_FIELDS = (
    "video",
    "category",
    "apply",
    "latitude",
    "longitude",
    "candidates",
    "inliers",
    "spread_m",
    "speed_kmh",
    "capture_time",
    "filename_time",
    "before_gap_s",
    "after_gap_s",
    "nearest_gap_s",
    "devices",
    "photos",
    "existing_latitude",
    "existing_longitude",
    "error_m",
    "note",
)


def _num(value: float | None, digits: int = 1) -> str:
    return "" if value is None else f"{value:.{digits}f}"


def result_to_row(result: Result, root: Path) -> dict[str, str]:
    try:
        name = str(result.video.relative_to(root))
    except ValueError:
        name = str(result.video)
    return {
        "video": name,
        "category": result.category,
        "apply": "yes" if result.approved else "no",
        "latitude": "" if result.lat is None else f"{result.lat}",
        "longitude": "" if result.lon is None else f"{result.lon}",
        "candidates": str(result.candidates),
        "inliers": str(result.inliers),
        "spread_m": _num(result.spread_m, 0),
        "speed_kmh": _num(result.speed_kmh, 1),
        "capture_time": result.when.isoformat(sep=" ") if result.when else "",
        "filename_time": (
            result.filename_time.isoformat(sep=" ") if result.filename_time else ""
        ),
        "before_gap_s": _num(result.before_gap_s, 0),
        "after_gap_s": _num(result.after_gap_s, 0),
        "nearest_gap_s": _num(result.nearest_gap_s, 0),
        "devices": "; ".join(result.devices),
        "photos": "; ".join(result.photos),
        "existing_latitude": "" if not result.existing else f"{result.existing[0]}",
        "existing_longitude": "" if not result.existing else f"{result.existing[1]}",
        "error_m": _num(result.error_m, 0),
        "note": result.note,
    }


def write_csv(path: Path, results: Sequence[Result], root: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    order = {name: i for i, name in enumerate(CATEGORY_ORDER)}
    ordered = sorted(
        results, key=lambda r: (order.get(r.category, len(order)), str(r.video))
    )
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for result in ordered:
            writer.writerow(result_to_row(result, root))
    LOG.info("wrote report: %s", path)


def read_csv(path: Path, root: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise SystemExit(f"CSV not found: {path}")
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        rows = list(reader)
        header = set(reader.fieldnames or ())
    missing = {"video", "apply", "latitude", "longitude"} - header
    if missing:
        raise SystemExit(
            f"{path} is missing required column(s): {', '.join(sorted(missing))}"
        )
    return rows


# ---------------------------------------------------------------------------
# rendering
# ---------------------------------------------------------------------------


def render_table(results: Sequence[Result], root: Path, limit: int | None) -> None:
    """Human-readable summary of everything that produced a position."""
    order = {name: i for i, name in enumerate(CATEGORY_ORDER)}
    shown = [r for r in results if not r.category.startswith("skipped")]
    shown.sort(key=lambda r: (order.get(r.category, len(order)), str(r.video)))
    if not shown:
        return
    truncated = limit is not None and len(shown) > limit
    if truncated:
        shown = shown[:limit]

    def rel(path: Path) -> str:
        try:
            return str(path.relative_to(root))
        except ValueError:
            return str(path)

    width = min(52, max(len(rel(r.video)) for r in shown))
    LOG.info("")
    LOG.info(
        "%-*s  %-28s %4s %9s %8s  %s",
        width, "video", "category", "n", "spread", "km/h", "position",
    )
    LOG.info("%s", "-" * (width + 66))
    for r in shown:
        name = rel(r.video)
        if len(name) > width:
            name = "..." + name[-(width - 3):]
        position = (
            f"{r.lat}, {r.lon}" if r.has_position else "(none)"
        )
        LOG.info(
            "%-*s  %-28s %4d %9s %8s  %s",
            width,
            name,
            r.category,
            r.candidates,
            human_distance(r.spread_m) if r.spread_m is not None else "-",
            _num(r.speed_kmh, 1) or "-",
            position,
        )
    if truncated:
        LOG.info("  ... (%d more; see the CSV)", len(results) - limit)


def report_categories(results: Sequence[Result], stats: Stats) -> None:
    for name in CATEGORY_ORDER:
        count = sum(1 for r in results if r.category == name)
        if count:
            stats.bump(name, count)


# ---------------------------------------------------------------------------
# writing
# ---------------------------------------------------------------------------


def write_position(
    video: Path,
    lat: float,
    lon: float,
    category: str,
    candidates: int,
    spread_m: float | None,
    dry_run: bool,
) -> bool:
    """Write coordinates and provenance to a video's sidecar.

    -n is required: without it exiftool wants a human-readable coordinate
    string, and a signed decimal is silently misread. With it the sidecar gets
    the correct XMP form, negative longitudes included ('44,46.224W').
    """
    sidecar = media.sidecar_for(video)
    today = dt.date.today().isoformat()
    assignments = [
        f"-{LAT_TAG}={lat}",
        f"-{LON_TAG}={lon}",
        f"-{MARKER_TAG}={MARKER_PREFIX}{today}",
        f"-{CONFIDENCE_TAG}={category}",
        f"-{CANDIDATES_TAG}={candidates}",
        f"-{SPREAD_TAG}={'' if spread_m is None else round(spread_m)}",
    ]
    return EXIF.write(sidecar, assignments, dry_run, numeric=True)


def apply_results(
    results: Sequence[Result], states: dict[Path, VideoState], dry_run: bool, stats: Stats
) -> None:
    for result in results:
        if not result.approved or not result.has_position:
            continue
        state = states.get(result.video)
        if state is not None and state.geotagged:
            # Never overwrite a real fix. Reaching here means the video gained
            # coordinates between the scan and the write.
            stats.bump("skipped, already geotagged at write time")
            continue
        ok = write_position(
            result.video,
            result.lat,
            result.lon,
            result.category,
            result.candidates,
            result.spread_m,
            dry_run,
        )
        stats.bump("coordinates written" if ok else "write failures")


# ---------------------------------------------------------------------------
# commands
# ---------------------------------------------------------------------------


def gather(args: argparse.Namespace, stats: Stats, want_geotagged: bool):
    """Shared front half of analyze and validate.

    Returns (scan_path, targets, states, lookup, limits).
    """
    scan_path = media.resolve_scope(args)
    limits = Thresholds(
        window_s=args.window * 3600.0,
        radius_m=args.radius,
        min_candidates=args.min_candidates,
        max_speed_kmh=args.max_speed,
        precision=args.precision,
        time_tolerance_s=args.time_tolerance,
    )

    LOG.info("scanning %s", scan_path)
    videos = media.discover_videos(scan_path, args.probe_all, args.jobs, stats)
    stats.bump("videos total", len(videos))
    LOG.info("videos found: %d", len(videos))
    if not videos:
        return scan_path, [], {}, None, limits

    LOG.info("reading %d video sidecar(s)...", len(videos))
    states = read_video_states(videos, args.jobs)

    targets: list[Path] = []
    for video in videos:
        state = states[video]
        if state.geotagged is not want_geotagged:
            continue
        if not want_geotagged and state.marker and not args.force:
            continue
        targets.append(video)

    index = build_photo_index(scan_path, stats, args.jobs)
    lookup = PhotoLookup(index, args.scope, scan_path)
    return scan_path, targets, states, lookup, limits


def infer_all(
    targets: Sequence[Path],
    lookup: PhotoLookup,
    limits: Thresholds,
    progress_every: int,
) -> list[Result]:
    results: list[Result] = []
    for i, video in enumerate(targets, 1):
        when = video_capture_time(video)
        candidates = lookup.within(video.parent, when, limits.window_s)
        result = classify(video, when, candidates, limits)
        if not candidates:
            result.nearest_gap_s = lookup.nearest_gap(video.parent, when)
        result = apply_time_check(result, video, limits)
        results.append(result)
        if progress_every and i % progress_every == 0:
            LOG.info("  ... %d/%d", i, len(targets))
    return results


def cmd_analyze(args: argparse.Namespace) -> int:
    stats = Stats()
    scan_path, targets, states, lookup, limits = gather(args, stats, want_geotagged=False)

    skipped: list[Result] = []
    for video, state in states.items():
        if state.geotagged:
            skipped.append(
                Result(
                    video=video,
                    category="skipped: already geotagged",
                    existing=(state.lat, state.lon),
                )
            )
        elif state.marker and not args.force:
            skipped.append(
                Result(
                    video=video,
                    category="skipped: already inferred",
                    note=state.marker,
                )
            )

    LOG.info("videos needing coordinates: %d", len(targets))
    results = infer_all(targets, lookup, limits, args.progress_every) if targets else []
    everything = results + skipped

    render_table(results, scan_path, args.max_rows)
    write_csv(args.csv, everything, scan_path)

    if args.apply:
        LOG.info("")
        LOG.info("applying %s rows...", CONFIDENT)
        apply_results(results, states, args.dry_run, stats)
    else:
        ready = sum(1 for r in results if r.approved)
        if ready:
            LOG.info("")
            LOG.info(
                "%d video(s) are ready to apply: re-run with --apply, or edit "
                "the 'apply' column of the CSV and use 'apply --from-csv'.",
                ready,
            )

    report_categories(everything, stats)
    stats.report("Analysis")
    return 0


def cmd_apply(args: argparse.Namespace) -> int:
    stats = Stats()
    scan_path = media.resolve_scope(args)
    rows = read_csv(args.from_csv, scan_path)
    stats.bump("rows in CSV", len(rows))

    wanted: list[tuple[Path, float, float, dict[str, str]]] = []
    for row in rows:
        if (row.get("apply") or "").strip().lower() not in {"yes", "y", "true", "1"}:
            continue
        raw = (row.get("video") or "").strip()
        if not raw:
            continue
        video = Path(raw)
        if not video.is_absolute():
            video = scan_path / video
        if not video.is_file():
            LOG.error("no such video, skipping: %s", video)
            stats.bump("missing videos")
            continue
        try:
            lat = float(row["latitude"])
            lon = float(row["longitude"])
        except (KeyError, TypeError, ValueError):
            LOG.error("row has no usable coordinates, skipping: %s", raw)
            stats.bump("rows without coordinates")
            continue
        wanted.append((video, lat, lon, row))

    stats.bump("rows approved", len(wanted))
    if not wanted:
        LOG.info("nothing marked for applying (set the 'apply' column to 'yes')")
        stats.report("Apply")
        return 0

    states = read_video_states([v for v, _, _, _ in wanted], args.jobs)
    for video, lat, lon, row in wanted:
        state = states.get(video)
        if state is not None and state.geotagged and not args.force:
            LOG.info(
                "  already geotagged, not overwriting: %s (%s, %s)",
                video.name, state.lat, state.lon,
            )
            stats.bump("skipped, already geotagged")
            continue
        try:
            spread = float(row.get("spread_m") or 0.0)
        except ValueError:
            spread = 0.0
        try:
            candidates = int(row.get("candidates") or 0)
        except ValueError:
            candidates = 0
        ok = write_position(
            video,
            lat,
            lon,
            row.get("category") or "manual",
            candidates,
            spread,
            args.dry_run,
        )
        if ok:
            LOG.info("  %s -> %s, %s", video.name, lat, lon)
        stats.bump("coordinates written" if ok else "write failures")

    stats.report("Apply")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    """Infer positions for videos that already have them, and measure the error.

    This is the calibration tool, and it doubles as an audit: the largest
    disagreements in this archive turned out to be videos whose own recorded
    fix was stale, not bad inferences.
    """
    stats = Stats()
    scan_path, targets, states, lookup, limits = gather(args, stats, want_geotagged=True)
    LOG.info("videos with coordinates to check: %d", len(targets))
    if not targets:
        stats.report("Validation")
        return 0

    results = infer_all(targets, lookup, limits, args.progress_every)
    measured: list[Result] = []
    for result in results:
        state = states[result.video]
        result.existing = (state.lat, state.lon)
        if result.has_position:
            result.error_m = haversine(state.lat, state.lon, result.lat, result.lon)
            measured.append(result)

    measured.sort(key=lambda r: r.error_m, reverse=True)

    LOG.info("")
    LOG.info("Worst disagreements (a large one usually means a bad timestamp,")
    LOG.info("on either side, or a stale fix recorded in the video itself):")
    LOG.info("")
    LOG.info("%12s %5s %10s  %-28s %s", "error", "n", "spread", "category", "video")
    LOG.info("%s", "-" * 100)
    for result in measured[: args.max_rows or len(measured)]:
        try:
            name = str(result.video.relative_to(scan_path))
        except ValueError:
            name = str(result.video)
        LOG.info(
            "%12s %5d %10s  %-28s %s",
            human_distance(result.error_m),
            result.candidates,
            human_distance(result.spread_m) if result.spread_m is not None else "-",
            result.category,
            name,
        )

    LOG.info("")
    LOG.info("Error distribution by category:")
    LOG.info("")
    LOG.info(
        "%-28s %6s %9s %9s %9s %8s", "category", "n", "median", "p90", "p99", "<=1km"
    )
    LOG.info("%s", "-" * 74)
    for name in CATEGORY_ORDER:
        errors = sorted(r.error_m for r in measured if r.category == name)
        if not errors:
            continue

        def pct(fraction: float) -> str:
            return human_distance(errors[min(len(errors) - 1, int(fraction * len(errors)))])

        within = 100.0 * sum(1 for e in errors if e <= 1000) / len(errors)
        LOG.info(
            "%-28s %6d %9s %9s %9s %7.1f%%",
            name,
            len(errors),
            human_distance(statistics.median(errors)),
            pct(0.90),
            pct(0.99),
            within,
        )

    write_csv(args.csv, results, scan_path)
    report_categories(results, stats)
    stats.report("Validation")
    return 0


def cmd_config(args: argparse.Namespace) -> int:
    return settings.cmd_config(args, CONFIG_TEMPLATE)


# ---------------------------------------------------------------------------
# command line
# ---------------------------------------------------------------------------

CONFIG_TEMPLATE = """\
# Configuration for video_geo_tagger.py
#
# Every setting here is optional and simply changes a default; anything passed
# on the command line still wins. Keys match the long option names with the
# leading dashes removed and hyphens turned into underscores, so --min-candidates
# becomes min_candidates.

# Applied to every subcommand.
[defaults]
# path = "~/Photo"
# scope = "dir"
# window = 4.0
# radius = 300.0
# min_candidates = 3
# max_speed = 10.0
# precision = 4
# time_tolerance = 1.0
# csv = "~/video_geo_tagger_report.csv"

# Applied to 'analyze' only, and takes precedence over [defaults].
[analyze]
# apply = false
# max_rows = 60

# Applied to 'validate' only.
[validate]
# max_rows = 25
"""


def build_parser(config: dict[str, Any] | None = None) -> argparse.ArgumentParser:
    config = config or {}
    parser = argparse.ArgumentParser(
        prog="video_geo_tagger.py",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    common = argparse.ArgumentParser(add_help=False)
    common.add_argument(
        "--path", type=Path, default=DEFAULT_PATH,
        help=f"directory to process, searched recursively "
             f"(default: {DEFAULT_PATH})",
    )
    common.add_argument(
        "--csv", type=Path, default=DEFAULT_CSV,
        help=f"where the report is written (default: {DEFAULT_CSV})",
    )
    common.add_argument(
        "--log", type=Path, default=None,
        help="append a detailed log here",
    )
    common.add_argument("--verbose", action="store_true", help="debug output")
    common.add_argument(
        "--config", type=Path, default=CONFIG_FILE,
        help=f"TOML config supplying defaults (default: {CONFIG_FILE})",
    )
    common.add_argument(
        "--jobs", type=int, default=max(1, min(6, os.cpu_count() or 4)),
        help="parallel workers used when probing unknown file types",
    )
    common.add_argument(
        "--probe-all", action="store_true",
        help="ffprobe every file instead of trusting known extensions",
    )
    common.add_argument(
        "--progress-every", type=int, default=50,
        help="emit a progress line every N videos (default: 50)",
    )

    inference = argparse.ArgumentParser(add_help=False)
    inference.add_argument(
        "--scope", choices=("dir", "dir+siblings", "tree"), default="dir",
        help="where to look for candidate photos: the video's own directory "
             "(default), everything under its parent, or the whole --path. "
             "'dir+siblings' is what reaches videos filed in video-only "
             "folders, which no same-directory search can ever match",
    )
    inference.add_argument(
        "--window", type=float, default=DEFAULT_WINDOW_HOURS,
        help=f"hours either side of the video to search "
             f"(default: {DEFAULT_WINDOW_HOURS})",
    )
    inference.add_argument(
        "--radius", type=float, default=DEFAULT_RADIUS_M,
        help=f"metres the candidates may spread before the position is "
             f"rejected (default: {DEFAULT_RADIUS_M:.0f})",
    )
    inference.add_argument(
        "--min-candidates", type=int, default=DEFAULT_MIN_CANDIDATES,
        help=f"geotagged photos required for a confident result "
             f"(default: {DEFAULT_MIN_CANDIDATES}; two photos that happen to "
             f"agree with each other prove very little)",
    )
    inference.add_argument(
        "--max-speed", type=float, default=DEFAULT_MAX_SPEED_KMH,
        help=f"km/h implied between the bracketing photos before the subject "
             f"counts as moving (default: {DEFAULT_MAX_SPEED_KMH:.0f})",
    )
    inference.add_argument(
        "--precision", type=int, default=DEFAULT_PRECISION,
        help=f"decimal places kept in the result (default: {DEFAULT_PRECISION}, "
             f"about 10 m)",
    )
    inference.add_argument(
        "--time-tolerance", type=float, default=DEFAULT_TIME_TOLERANCE_S,
        help=f"seconds the mtime may differ from the filename timestamp "
             f"(default: {DEFAULT_TIME_TOLERANCE_S:.0f})",
    )
    inference.add_argument(
        "--max-rows", type=int, default=60,
        help="rows to print to the terminal; the CSV always has all of them "
             "(default: 60, 0 for no limit)",
    )

    writing = argparse.ArgumentParser(add_help=False)
    writing.add_argument(
        "--dry-run", action="store_true",
        help="show what would change without writing anything",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    analyze = subparsers.add_parser(
        "analyze", parents=[common, inference, writing],
        help="classify every video and write the CSV report (writes nothing "
             "to sidecars unless --apply is given)",
    )
    analyze.add_argument(
        "--apply", action="store_true",
        help=f"also write coordinates for '{CONFIDENT}' videos",
    )
    analyze.add_argument(
        "--force", action="store_true",
        help="reconsider videos already carrying this tool's marker",
    )
    analyze.set_defaults(func=cmd_analyze)

    apply_cmd = subparsers.add_parser(
        "apply", parents=[common, writing],
        help="write coordinates for rows approved in a reviewed CSV",
    )
    apply_cmd.add_argument(
        "--from-csv", "--apply-from-csv", dest="from_csv", type=Path, required=True,
        help="the reviewed CSV; rows whose 'apply' column says yes are written",
    )
    apply_cmd.add_argument(
        "--force", action="store_true",
        help="overwrite coordinates on videos that already have them "
             "(off by default, and rarely what you want)",
    )
    apply_cmd.set_defaults(func=cmd_apply)

    validate = subparsers.add_parser(
        "validate", parents=[common, inference],
        help="infer positions for videos that ALREADY have coordinates and "
             "report the error, worst first",
    )
    validate.set_defaults(func=cmd_validate, dry_run=True, force=False)

    config_cmd = subparsers.add_parser(
        "config", parents=[common, writing],
        help="show the config file in use, or write a starter template",
    )
    config_cmd.add_argument(
        "--init", action="store_true", help="write a commented template"
    )
    config_cmd.add_argument(
        "--force", action="store_true", help="overwrite an existing config"
    )
    config_cmd.set_defaults(func=cmd_config)

    settings.apply_to_subparsers(subparsers, config)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    # --config has to be known before the real parser is built, since it
    # supplies that parser's defaults.
    pre = argparse.ArgumentParser(add_help=False)
    pre.add_argument("--config", type=Path, default=CONFIG_FILE)
    pre_args, _ = pre.parse_known_args(argv)
    config = settings.load_config(pre_args.config.expanduser())

    parser = build_parser(config)
    args = parser.parse_args(argv)
    args.csv = Path(args.csv).expanduser()
    if getattr(args, "max_rows", None) == 0:
        args.max_rows = None

    setup_logging(args.log, args.verbose)
    LOG.debug(
        "interpreter: %s (virtualenv: %s)",
        sys.executable,
        sys.prefix if sys.prefix != sys.base_prefix else "none",
    )

    settings.check_dependencies(("exiftool",), "brew install exiftool")
    EXIF.ensure_config()

    started = dt.datetime.now()
    LOG.info(
        "=== video_geo_tagger.py %s: %s ===",
        args.command, started.isoformat(timespec="seconds"),
    )
    if settings.has_settings(config):
        LOG.info("config: %s", pre_args.config.expanduser())
    if getattr(args, "dry_run", False):
        LOG.info("DRY RUN -- nothing will be written")

    try:
        rc = args.func(args)
    except KeyboardInterrupt:
        LOG.warning("interrupted")
        return 130

    LOG.info("")
    LOG.info(
        "elapsed: %s",
        human_duration((dt.datetime.now() - started).total_seconds()),
    )
    return rc


if __name__ == "__main__":
    sys.exit(main())
