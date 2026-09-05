"""Archive walking, sidecar naming, and media identification."""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import os
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterator, Sequence

from photo_archive.exif import ExifTool
from photo_archive.util import LOG, Stats

# Extensions we can classify without paying for a probe. Anything not listed
# here gets probed, so unusual containers are still discovered.
KNOWN_VIDEO_EXTS = {
    ".mov", ".mp4", ".m4v", ".avi", ".mkv", ".webm", ".mpg", ".mpeg",
    ".mts", ".m2ts", ".ts", ".wmv", ".flv", ".3gp", ".3g2", ".ogv",
    ".mod", ".tod", ".vob", ".asf", ".rm", ".rmvb", ".divx", ".f4v",
    ".mxf", ".dv", ".m2v", ".mpe",
}
KNOWN_IMAGE_EXTS = {
    ".jpg", ".jpeg", ".png", ".heic", ".heif", ".gif", ".tif", ".tiff",
    ".bmp", ".webp", ".dng", ".cr2", ".cr3", ".nef", ".arw", ".raf",
    ".orf", ".rw2", ".pef", ".srw",
}
KNOWN_NONVIDEO_EXTS = KNOWN_IMAGE_EXTS | {
    ".xmp", ".ds_store", ".txt", ".md", ".pdf", ".zip",
    ".aae", ".thm", ".ini", ".db", ".json", ".uuid", ".nfo",
}

def sidecar_for(media: Path) -> Path:
    """digiKam-style sidecar name: '<full filename>.xmp'."""
    return media.with_name(media.name + ".xmp")


def media_for(sidecar: Path) -> Path:
    """Inverse of sidecar_for: strip the trailing '.xmp'."""
    return sidecar.with_name(sidecar.name[:-4])


def iter_candidate_files(scan_path: Path) -> Iterator[Path]:
    for dirpath, dirnames, filenames in os.walk(scan_path):
        dirnames[:] = sorted(d for d in dirnames if not d.startswith("."))
        for name in sorted(filenames):
            if name.startswith("."):
                continue
            yield Path(dirpath) / name


@dataclass
class VideoInfo:
    path: Path
    duration: float | None
    width: int | None
    height: int | None
    codec: str | None


def ffprobe_video(path: Path) -> VideoInfo | None:
    """Return stream info, or None if the file has no usable video stream.

    Cover art is stored as a video stream with the ATTACHED_PIC disposition;
    those are rejected so music files and the like are not mistaken for video.
    """
    proc = subprocess.run(
        [
            "ffprobe", "-v", "error",
            "-select_streams", "v",
            "-show_entries",
            "stream=codec_name,width,height,disposition=attached_pic",
            "-show_entries", "format=duration",
            "-of", "json",
            str(path),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if proc.returncode != 0 or not proc.stdout.strip():
        return None
    try:
        data = json.loads(proc.stdout)
    except json.JSONDecodeError:
        return None

    stream = None
    for candidate in data.get("streams", []):
        disposition = candidate.get("disposition") or {}
        if disposition.get("attached_pic"):
            continue
        stream = candidate
        break
    if stream is None:
        return None

    raw_duration = (data.get("format") or {}).get("duration")
    try:
        duration = float(raw_duration)
    except (TypeError, ValueError):
        duration = None
    if duration is not None and duration <= 0:
        duration = None

    return VideoInfo(
        path=path,
        duration=duration,
        width=stream.get("width"),
        height=stream.get("height"),
        codec=stream.get("codec_name"),
    )


def discover_videos(
    scan_path: Path,
    probe_all: bool,
    jobs: int,
    stats: Stats,
    probe: Callable[[Path], object | None] = ffprobe_video,
) -> list[Path]:
    """Find video files, probing anything whose extension is not conclusive."""
    fast_hits: list[Path] = []
    to_probe: list[Path] = []

    for path in iter_candidate_files(scan_path):
        ext = path.suffix.lower()
        if probe_all:
            if ext in {".xmp", ".ds_store"}:
                continue
            to_probe.append(path)
        elif ext in KNOWN_VIDEO_EXTS:
            fast_hits.append(path)
        elif ext in KNOWN_NONVIDEO_EXTS:
            continue
        else:
            to_probe.append(path)

    stats.bump("videos found by extension", len(fast_hits))
    videos = list(fast_hits)

    if to_probe:
        LOG.info("probing %d file(s) of unrecognised type...", len(to_probe))
        with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
            for path, info in zip(to_probe, pool.map(probe, to_probe)):
                if info is not None:
                    videos.append(path)
                    stats.bump("videos found by probing")

    return sorted(set(videos))


def read_markers(
    exif: ExifTool, media: Sequence[Path], marker_tag: str
) -> dict[Path, str]:
    """Map media path -> marker value, for files already carrying one."""
    sidecars = [sidecar_for(m) for m in media]
    existing = [s for s in sidecars if s.exists()]
    records = exif.read(existing, [marker_tag])
    markers: dict[Path, str] = {}
    for item, sidecar in zip(media, sidecars):
        rec = records.get(sidecar) or records.get(Path(os.path.normpath(sidecar)))
        if not rec:
            continue
        value = rec.get(marker_tag)
        if value:
            markers[item] = str(value)
    return markers


def resolve_scope(args: argparse.Namespace) -> Path:
    """Return the directory to process, honouring --path."""
    scan_path = Path(args.path).expanduser().resolve()
    if not scan_path.is_dir():
        raise SystemExit(f"--path not found: {scan_path}")
    return scan_path
