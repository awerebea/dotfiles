#!/usr/bin/env python3

"""
video_face_tagger.py

Tag video files with people's names by running digiKam's face recognition on
extracted video frames.

digiKam cannot detect faces in videos. This tool works around that by sampling
still frames out of each video into a scratch directory, which you then add to
digiKam as a temporary collection. digiKam does the detection and recognition
there, you confirm the faces, and this tool reads the confirmed names back and
merges them into the source videos' XMP sidecars.

The workflow has four phases, three of them scripted:

    extract   phase 1   sample frames from videos into the work directory
    (manual)  phase 2   in digiKam: add the work directory as a collection,
                        run face detection + recognition, confirm the faces
    collect   phase 3   read names back from frame sidecars and merge them
                        into each source video's sidecar
    clean     phase 4   drop work-directory frames for processed videos

There is also a 'status' subcommand that reports where things stand.

Original media files are NEVER modified. Every write goes to a .xmp sidecar
named '<full filename>.xmp', which is digiKam's default and Immich's preferred
form. File modification times are preserved exactly.

Frames are linked back to their source video two independent ways, so the link
survives even if digiKam rewrites a frame sidecar and drops fields it does not
recognise:

    1. Each frame sidecar carries XMP-xmpMM:DerivedFromFilePath and
       XMP-vidfaces:SourceVideo holding the video's absolute path. This is the
       normal route and needs no archive scan at all.
    2. The frame filename embeds a short hash of that same absolute path. A
       metadata tool cannot alter a filename, so when route 1 is missing phase
       3 recovers the link by hashing the videos it finds under --path. This
       map is only built when something actually needs it.

Defaults can be set in ~/.config/video_face_tagger/config.toml (see the
'config' subcommand, which also writes a starter template). Command-line
arguments always take precedence over the file.

Optional face pre-filter: with opencv installed and the YuNet model fetched
(see requirements_video_face_tagger.txt and the 'fetch-model' subcommand),
phase 1 discards frames containing no detectable face before digiKam ever
indexes them. Measured on this archive that removes about 55% of frames at a
score threshold of 0.6, which gave 100% recall against digiKam's own confirmed
face regions. It is a pure optimisation: the tool behaves identically without
it, just with a larger working set.

Idempotency marker: a processed video's sidecar gets
XMP-vidfaces:FacesScanned = 'faces-scanned:YYYY-MM-DD' in a private XMP
namespace that no other tool writes. Phase 1 skips videos carrying it unless
--force is given.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import datetime as dt
import hashlib
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterator, Sequence

REQUIREMENTS_NAME = "requirements_video_face_tagger.txt"
SCRIPT_DIR = Path(__file__).resolve().parent

REEXEC_GUARD = "VIDEO_FACE_TAGGER_REEXEC"
PYTHON_OVERRIDE = "VIDEO_FACE_TAGGER_PYTHON"

# Fallback venv locations, used only when nothing else identifies one. These
# are a convenience, not a requirement: an activated virtualenv always wins.
VENV_CANDIDATES = (
    SCRIPT_DIR / ".venv",
    SCRIPT_DIR / "venv",
    Path("~/.local/share/video_face_tagger/venv").expanduser(),
)
VENV_DIR = VENV_CANDIDATES[0]


def _venv_python() -> Path | None:
    """Find a virtualenv interpreter to run under, or None to stay put."""
    override = os.environ.get(PYTHON_OVERRIDE)
    if override:
        candidate = Path(override).expanduser()
        return candidate if candidate.is_file() else None

    # An activated virtualenv that somehow is not the running interpreter.
    active = os.environ.get("VIRTUAL_ENV")
    if active:
        candidate = Path(active) / "bin" / "python"
        if candidate.is_file():
            return candidate

    for venv in VENV_CANDIDATES:
        candidate = venv / "bin" / "python"
        if candidate.is_file():
            return candidate
    return None


def _reexec_into_venv() -> None:
    """Re-run this script under a virtualenv interpreter when one applies.

    The dependencies for the optional face filter are installed into a
    virtualenv, but the shebang runs whatever `python3` resolves to. Rather
    than graft that virtualenv's site-packages onto sys.path, which only works
    when it was built for the very same Python, hand the script to the
    virtualenv's own interpreter so every import resolves natively.

    Deliberately does nothing when already inside a virtualenv, so an activated
    environment is always respected and no particular layout is imposed.
    """
    if os.environ.get(REEXEC_GUARD):
        return
    if sys.prefix != sys.base_prefix:
        return  # already running inside a virtualenv; use it as-is

    target = _venv_python()
    if target is None:
        return
    # Deliberately compared unresolved: a virtualenv's bin/python is a symlink
    # to the base interpreter, so resolving both sides makes any venv look
    # identical to the Python already running and the re-exec never happens.
    # Loop protection is the guard variable above, not this check.
    if target == Path(sys.executable):
        return

    os.environ[REEXEC_GUARD] = "1"
    script = str(Path(__file__).resolve())
    try:
        os.execv(str(target), [str(target), script, *sys.argv[1:]])
    except OSError as exc:  # pragma: no cover - execv essentially never fails
        del os.environ[REEXEC_GUARD]
        print(
            f"warning: could not run under {target}: {exc}",
            file=sys.stderr,
        )


if __name__ == "__main__":
    # Only when run as a program: importing this module should never replace
    # the importing process.
    _reexec_into_venv()

LOG = logging.getLogger("video_face_tagger.py")

# YuNet face detector, used only by the optional --face-filter. Measured on
# this archive at score threshold 0.6: 100% recall against digiKam-confirmed
# face regions, while discarding ~55% of extracted frames.
FACE_MODEL_URL = (
    "https://media.githubusercontent.com/media/opencv/opencv_zoo/main/"
    "models/face_detection_yunet/face_detection_yunet_2023mar.onnx"
)
FACE_MODEL_SHA256 = (
    "8f2383e4dd3cfbb4553ea8718107fc0423210dc964f9f4280604804ed2552fa4"
)

DEFAULT_PATH = Path("~/Photo").expanduser()
DEFAULT_WORK = Path("~/video_face_tagger_work").expanduser()
CONFIG_DIR = Path("~/.config/video_face_tagger").expanduser()
EXIFTOOL_CONFIG = CONFIG_DIR / "ExifTool_config"
CONFIG_FILE = CONFIG_DIR / "config.toml"
FACE_MODEL_PATH = CONFIG_DIR / "face_detection_yunet.onnx"

# Private XMP namespace for this tool's bookkeeping. Chosen so that no other
# tool in the pipeline (digiKam, Immich, exiv2) has any reason to touch it.
VF_NAMESPACE_URI = "http://ns.awerebea.net/videofaces/1.0/"
VF_PREFIX = "vidfaces"

MARKER_TAG = "XMP-vidfaces:FacesScanned"
MARKER_PREFIX = "faces-scanned:"
SOURCE_VIDEO_TAG = "XMP-vidfaces:SourceVideo"
FACE_COUNT_TAG = "XMP-vidfaces:FacesFound"
DERIVED_FROM_TAG = "XMP-xmpMM:DerivedFromFilePath"

# Tag list fields digiKam maintains. The first three are the ones the archive
# is indexed on; the last two are also written by digiKam and are kept in sync
# only when --extra-tag-fields is given (see notes in merge_person_tags).
TAGSLIST_TAG = "XMP-digiKam:TagsList"
HIERARCHICAL_TAG = "XMP-lr:HierarchicalSubject"
SUBJECT_TAG = "XMP-dc:Subject"
LASTKEYWORD_TAG = "XMP-microsoft:LastKeywordXMP"
CATALOGSETS_TAG = "XMP-mediapro:CatalogSets"

# Names digiKam uses for faces that are detected but not identified. These must
# never become person tags.
NON_PERSON_NAMES = {
    "unknown",
    "unknown person",
    "ignored",
    "ignore",
    "unconfirmed",
    "no face",
}

# Extensions we can classify without paying for a probe. Anything not listed
# here gets probed, so unusual containers are still discovered.
KNOWN_VIDEO_EXTS = {
    ".mov", ".mp4", ".m4v", ".avi", ".mkv", ".webm", ".mpg", ".mpeg",
    ".mts", ".m2ts", ".ts", ".wmv", ".flv", ".3gp", ".3g2", ".ogv",
    ".mod", ".tod", ".vob", ".asf", ".rm", ".rmvb", ".divx", ".f4v",
    ".mxf", ".dv", ".m2v", ".mpe",
}
KNOWN_NONVIDEO_EXTS = {
    ".jpg", ".jpeg", ".png", ".heic", ".heif", ".gif", ".tif", ".tiff",
    ".bmp", ".webp", ".xmp", ".ds_store", ".txt", ".md", ".pdf", ".zip",
    ".aae", ".thm", ".ini", ".db", ".json", ".uuid", ".nfo",
}

FRAME_EXT = ".jpg"
MARKER_DATE_RE = re.compile(r"^faces-scanned:(\d{4}-\d{2}-\d{2})")


# ---------------------------------------------------------------------------
# small helpers
# ---------------------------------------------------------------------------


def nfc(text: str) -> str:
    """Normalize to Unicode NFC.

    macOS hands back decomposed (NFD) filenames while digiKam writes composed
    names into XMP. Person names are Cyrillic here, so comparing the two forms
    byte-for-byte would create duplicate tags that look identical.
    """
    return unicodedata.normalize("NFC", text)


def as_list(value: Any) -> list[str]:
    """Coerce an exiftool JSON value into a list of strings.

    exiftool's JSON output emits numeric-looking values unquoted, so a tag
    literally named '2024' comes back as the integer 2024. Everything is forced
    back to str so set operations behave.
    """
    if value is None:
        return []
    if not isinstance(value, list):
        value = [value]
    out = []
    for item in value:
        if item is None:
            continue
        if isinstance(item, float) and item.is_integer():
            item = int(item)
        out.append(nfc(str(item)))
    return out


def path_hash(rel_path: str) -> str:
    """Short stable identifier for a video, derived from its relative path."""
    digest = hashlib.sha1(nfc(rel_path).encode("utf-8")).hexdigest()
    return digest[:10]


def ascii_slug(name: str, limit: int = 48) -> str:
    """Filesystem-safe ASCII stem, so frame names carry no Cyrillic or spaces."""
    decomposed = unicodedata.normalize("NFKD", name)
    stripped = decomposed.encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^A-Za-z0-9._-]+", "_", stripped).strip("._-")
    slug = re.sub(r"_+", "_", slug)
    if not slug:
        slug = "video"
    return slug[:limit]


def human_duration(seconds: float) -> str:
    seconds = int(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    if h:
        return f"{h}h{m:02d}m{s:02d}s"
    if m:
        return f"{m}m{s:02d}s"
    return f"{s}s"


class Stats:
    """Ordered counter used for the end-of-phase summaries."""

    def __init__(self) -> None:
        self._counts: dict[str, int] = {}

    def bump(self, key: str, amount: int = 1) -> None:
        self._counts[key] = self._counts.get(key, 0) + amount

    def get(self, key: str) -> int:
        return self._counts.get(key, 0)

    def report(self, title: str) -> None:
        LOG.info("")
        LOG.info("%s", title)
        LOG.info("%s", "-" * len(title))
        if not self._counts:
            LOG.info("  (nothing to report)")
        width = max((len(k) for k in self._counts), default=0)
        for key, value in self._counts.items():
            LOG.info("  %-*s : %d", width, key, value)


# ---------------------------------------------------------------------------
# exiftool plumbing
# ---------------------------------------------------------------------------


EXIFTOOL_CONFIG_BODY = f"""\
# Generated by video_face_tagger.py. Safe to delete; it will be recreated.
#
# Declares a private XMP namespace used to mark videos as processed and to
# record which video a frame came from. Kept out of ~/.ExifTool_config on
# purpose so it only applies to this tool's exiftool calls.
%Image::ExifTool::UserDefined = (
    'Image::ExifTool::XMP::Main' => {{
        {VF_PREFIX} => {{
            SubDirectory => {{
                TagTable => 'Image::ExifTool::UserDefined::{VF_PREFIX}',
            }},
        }},
    }},
);

%Image::ExifTool::UserDefined::{VF_PREFIX} = (
    GROUPS    => {{ 0 => 'XMP', 1 => 'XMP-{VF_PREFIX}', 2 => 'Image' }},
    NAMESPACE => {{ '{VF_PREFIX}' => '{VF_NAMESPACE_URI}' }},
    WRITABLE  => 'string',
    FacesScanned => {{ }},
    FacesFound   => {{ }},
    SourceVideo  => {{ }},
);

1;  #end
"""


def ensure_exiftool_config() -> Path:
    """Write the private-namespace exiftool config if it is missing or stale."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    if not EXIFTOOL_CONFIG.exists() or EXIFTOOL_CONFIG.read_text(
        encoding="utf-8"
    ) != EXIFTOOL_CONFIG_BODY:
        EXIFTOOL_CONFIG.write_text(EXIFTOOL_CONFIG_BODY, encoding="utf-8")
        LOG.debug("wrote exiftool config: %s", EXIFTOOL_CONFIG)
    return EXIFTOOL_CONFIG


def exiftool_argv(*args: str) -> list[str]:
    """Build an exiftool command line.

    '-config' is only honoured when it is the very first option, so it is
    always prepended here rather than passed by callers.
    """
    return [
        "exiftool",
        "-config",
        str(EXIFTOOL_CONFIG),
        "-charset",
        "utf8",
        "-charset",
        "filename=utf8",
        *args,
    ]


def run_exiftool(args: Sequence[str], check: bool = False) -> subprocess.CompletedProcess:
    proc = subprocess.run(
        exiftool_argv(*args),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if check and proc.returncode != 0:
        raise RuntimeError(
            f"exiftool failed ({proc.returncode}): {proc.stderr.strip()}"
        )
    return proc


def exiftool_read(paths: Sequence[Path], tags: Sequence[str]) -> dict[Path, dict]:
    """Read tags from many files in one exiftool invocation.

    Paths go through an argfile so the call is immune to ARGV length limits;
    24k frame sidecars in one shot is normal for phase 3.
    """
    if not paths:
        return {}
    tag_args = [f"-{tag}" for tag in tags]
    with tempfile.NamedTemporaryFile(
        "w", suffix=".args", delete=False, encoding="utf-8"
    ) as handle:
        for path in paths:
            handle.write(f"{path}\n")
        argfile = handle.name
    try:
        proc = run_exiftool(["-j", "-G1", "-m", *tag_args, "-@", argfile])
        if not proc.stdout.strip():
            if proc.returncode != 0:
                LOG.debug("exiftool read returned nothing: %s", proc.stderr.strip())
            return {}
        try:
            records = json.loads(proc.stdout)
        except json.JSONDecodeError as exc:
            LOG.error("could not parse exiftool output: %s", exc)
            return {}
        return {Path(rec["SourceFile"]): rec for rec in records}
    finally:
        os.unlink(argfile)


def exiftool_write(
    target: Path,
    assignments: Sequence[str],
    dry_run: bool,
) -> bool:
    """Apply tag assignments to one sidecar, preserving its modification time.

    exiftool's own -P keeps whole seconds but truncates the sub-second part of
    the timestamp, so the original atime/mtime are captured up front and
    restored at nanosecond precision afterwards.
    """
    if not assignments:
        return True
    if dry_run:
        for item in assignments:
            LOG.info("    [dry-run] %s %s", target.name, item)
        return True

    existed = target.exists()
    times = None
    if existed:
        st = target.stat()
        times = (st.st_atime_ns, st.st_mtime_ns)

    proc = run_exiftool(
        ["-P", "-overwrite_original", "-m", *assignments, str(target)]
    )
    if proc.returncode != 0:
        LOG.error("exiftool write failed for %s: %s", target, proc.stderr.strip())
        return False

    if times is not None and target.exists():
        os.utime(target, ns=times)
    return True


# ---------------------------------------------------------------------------
# ffmpeg / ffprobe
# ---------------------------------------------------------------------------


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


def scale_filter(long_edge: int) -> str:
    """Downscale to long_edge on the longer side, never upscaling."""
    return (
        f"scale='if(gt(iw,ih),min({long_edge},iw),-2)'"
        f":'if(gt(iw,ih),-2,min({long_edge},ih))'"
    )


def sample_timestamps(duration: float | None, interval: float, max_frames: int) -> list[float]:
    """Pick sample points, evenly spread and biased away from the very edges.

    A clip shorter than one interval still yields one frame, taken from the
    middle. When the interval would produce more frames than the cap, the cap
    is spread across the whole clip rather than truncating to the opening.
    """
    if duration is None:
        return [0.0]
    count = int(duration // interval)
    count = max(1, min(max_frames, count))
    return [(index + 0.5) * duration / count for index in range(count)]


def extract_one_frame(
    video: Path,
    timestamp: float,
    dest: Path,
    long_edge: int,
    quality: int,
) -> bool:
    """Extract a single frame using input seeking (decodes from the keyframe)."""
    cmd = [
        "ffmpeg", "-v", "error", "-nostdin", "-y",
        "-ss", f"{timestamp:.3f}",
        "-i", str(video),
        "-frames:v", "1",
        "-vf", scale_filter(long_edge),
        "-q:v", str(quality),
        str(dest),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, errors="replace")
    if proc.returncode != 0 or not dest.exists() or dest.stat().st_size == 0:
        if proc.stderr.strip():
            LOG.debug("ffmpeg: %s", proc.stderr.strip())
        dest.unlink(missing_ok=True)
        return False
    return True


def extract_sharpest_frame(
    video: Path,
    timestamp: float,
    dest: Path,
    long_edge: int,
    quality: int,
    candidates: int,
    window: float,
) -> bool:
    """Extract several frames around a timestamp and keep the sharpest.

    Sharpness is scored by encoded JPEG size at fixed quality. Measured against
    a real variance-of-Laplacian score on this archive's footage, the two rank
    candidates almost identically (Spearman rho 0.99), and byte size costs
    nothing extra to compute -- no numpy or Pillow needed.
    """
    start = max(0.0, timestamp - window / 2.0)
    tmpdir = Path(tempfile.mkdtemp(prefix="vft-cand-", dir=str(dest.parent)))
    try:
        pattern = tmpdir / "c_%03d.jpg"
        cmd = [
            "ffmpeg", "-v", "error", "-nostdin", "-y",
            "-ss", f"{start:.3f}",
            "-i", str(video),
            "-t", f"{window:.3f}",
            "-vf", f"fps={candidates / window:.4f},{scale_filter(long_edge)}",
            "-frames:v", str(candidates),
            "-q:v", str(quality),
            str(pattern),
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, errors="replace")
        shots = sorted(tmpdir.glob("c_*.jpg"))
        if proc.returncode != 0 or not shots:
            if proc.stderr.strip():
                LOG.debug("ffmpeg: %s", proc.stderr.strip())
            return extract_one_frame(video, timestamp, dest, long_edge, quality)
        best = max(shots, key=lambda p: p.stat().st_size)
        shutil.move(str(best), str(dest))
        return True
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


# ---------------------------------------------------------------------------
# optional face pre-filter
# ---------------------------------------------------------------------------


_FACE_LOCAL = threading.local()


def face_filter_available() -> tuple[bool, str]:
    """Report whether the face pre-filter can run, and why not if it cannot."""
    try:
        import cv2  # noqa: F401
    except ImportError:
        return False, (
            f"opencv is not installed (see {REQUIREMENTS_NAME})"
        )
    if not hasattr(cv2, "FaceDetectorYN_create"):
        return False, "this opencv build has no FaceDetectorYN"
    if not FACE_MODEL_PATH.exists():
        return False, f"model not downloaded (run: {Path(sys.argv[0]).name} fetch-model)"
    return True, ""


def face_filter_setup_hint() -> list[str]:
    """The exact commands still needed to enable the face pre-filter."""
    steps: list[str] = []
    try:
        import cv2  # noqa: F401

        have_cv2 = hasattr(cv2, "FaceDetectorYN_create")
    except ImportError:
        have_cv2 = False

    if not have_cv2:
        # The requirements file ships beside the script; give its real path so
        # the suggested command is copy-pasteable from any directory.
        requirements = SCRIPT_DIR / REQUIREMENTS_NAME
        target = requirements if requirements.exists() else REQUIREMENTS_NAME
        venv = VENV_DIR
        steps.append(f"python3 -m venv {venv}")
        steps.append(f"{venv}/bin/pip install -r {target}")
    if not FACE_MODEL_PATH.exists():
        steps.append(f"{Path(sys.argv[0]).name} fetch-model")
    return steps


def get_face_detector(threshold: float):
    """Return a per-thread YuNet detector.

    One instance per worker thread: the detector carries mutable input-size and
    threshold state, so sharing it across the extraction pool would race.
    """
    detector = getattr(_FACE_LOCAL, "detector", None)
    if detector is None:
        import cv2

        detector = cv2.FaceDetectorYN_create(
            str(FACE_MODEL_PATH), "", (320, 320), threshold, 0.3, 5000
        )
        _FACE_LOCAL.detector = detector
    return detector


def frame_has_face(path: Path, threshold: float) -> bool:
    """True if YuNet finds at least one face in the frame.

    A read failure counts as a face so the frame is kept: dropping a frame we
    could not inspect would silently lose data, which is the one outcome worth
    avoiding here.
    """
    import cv2

    image = cv2.imread(str(path))
    if image is None:
        LOG.debug("face filter could not read %s; keeping it", path.name)
        return True
    height, width = image.shape[:2]
    detector = get_face_detector(threshold)
    detector.setScoreThreshold(threshold)
    detector.setInputSize((width, height))
    _, faces = detector.detect(image)
    return faces is not None and len(faces) > 0


def download_face_model(dry_run: bool) -> int:
    """Fetch the YuNet model into the config directory, verifying its checksum."""
    import urllib.request

    if FACE_MODEL_PATH.exists():
        digest = hashlib.sha256(FACE_MODEL_PATH.read_bytes()).hexdigest()
        if digest == FACE_MODEL_SHA256:
            LOG.info("model already present and verified: %s", FACE_MODEL_PATH)
            return 0
        LOG.warning("existing model has unexpected checksum; re-downloading")

    LOG.info("downloading %s", FACE_MODEL_URL)
    if dry_run:
        LOG.info("  [dry-run] would save to %s", FACE_MODEL_PATH)
        return 0

    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    try:
        with urllib.request.urlopen(FACE_MODEL_URL, timeout=60) as response:
            payload = response.read()
    except Exception as exc:  # noqa: BLE001 - network failures are expected here
        LOG.error("download failed: %s", exc)
        return 1

    digest = hashlib.sha256(payload).hexdigest()
    if digest != FACE_MODEL_SHA256:
        LOG.error(
            "checksum mismatch: expected %s, got %s", FACE_MODEL_SHA256, digest
        )
        return 1

    FACE_MODEL_PATH.write_bytes(payload)
    LOG.info("saved %s (%d bytes, checksum verified)", FACE_MODEL_PATH, len(payload))
    return 0


def cmd_fetch_model(args: argparse.Namespace) -> int:
    return download_face_model(args.dry_run)


# ---------------------------------------------------------------------------
# archive walking
# ---------------------------------------------------------------------------


def sidecar_for(media: Path) -> Path:
    """digiKam-style sidecar name: '<full filename>.xmp'."""
    return media.with_name(media.name + ".xmp")


def iter_candidate_files(scan_path: Path) -> Iterator[Path]:
    for dirpath, dirnames, filenames in os.walk(scan_path):
        dirnames[:] = sorted(d for d in dirnames if not d.startswith("."))
        for name in sorted(filenames):
            if name.startswith("."):
                continue
            yield Path(dirpath) / name


def discover_videos(
    scan_path: Path,
    probe_all: bool,
    jobs: int,
    stats: Stats,
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
            for path, info in zip(to_probe, pool.map(ffprobe_video, to_probe)):
                if info is not None:
                    videos.append(path)
                    stats.bump("videos found by probing")

    return sorted(set(videos))


def read_markers(videos: Sequence[Path]) -> dict[Path, str]:
    """Map video path -> marker value, for videos already carrying one."""
    sidecars = [sidecar_for(v) for v in videos]
    existing = [s for s in sidecars if s.exists()]
    records = exiftool_read(existing, [MARKER_TAG])
    markers: dict[Path, str] = {}
    for video, sidecar in zip(videos, sidecars):
        rec = records.get(sidecar) or records.get(Path(os.path.normpath(sidecar)))
        if not rec:
            continue
        value = rec.get(MARKER_TAG)
        if value:
            markers[video] = str(value)
    return markers


# ---------------------------------------------------------------------------
# frame naming and sidecars
# ---------------------------------------------------------------------------


def frame_stem(video: Path) -> tuple[str, str]:
    """Return (hash, filename prefix) for a video's frames.

    The hash covers the video's absolute path. Hashing a path relative to some
    archive root would make the digest depend on which root was passed, so
    narrowing --path between phases would change every hash; an absolute path
    is the same string no matter how the run was scoped.
    """
    digest = path_hash(str(video.resolve()))
    return digest, f"{ascii_slug(video.stem)}__{digest}"


FRAME_HASH_RE = re.compile(r"__([0-9a-f]{10})_\d+" + re.escape(FRAME_EXT) + r"$")


def frame_hash_from_name(name: str) -> str | None:
    """Recover the source-video hash from a frame or frame-sidecar filename.

    Accepts both 'stem__<hash>_007.jpg' and its sidecar 'stem__<hash>_007.jpg.xmp'.
    """
    if name.endswith(".xmp"):
        name = name[: -len(".xmp")]
    match = FRAME_HASH_RE.search(name)
    return match.group(1) if match else None


def frame_sidecar_xml(video_path: str) -> str:
    """Minimal XMP sidecar recording which video a frame came from.

    Written directly rather than through exiftool: the content is fully known,
    these files are disposable, and skipping ~24k exiftool startups saves the
    better part of an hour on a full-archive run.
    """
    from xml.sax.saxutils import escape

    value = escape(video_path)
    return (
        '<?xpacket begin="\ufeff" id="W5M0MpCehiHzreSzNTczkc9d"?>\n'
        '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="video_face_tagger.py">\n'
        ' <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">\n'
        '  <rdf:Description rdf:about=""\n'
        '    xmlns:xmpMM="http://ns.adobe.com/xap/1.0/mm/"\n'
        f'    xmlns:{VF_PREFIX}="{VF_NAMESPACE_URI}">\n'
        '   <xmpMM:DerivedFrom rdf:parseType="Resource">\n'
        f'    <stRef:filePath xmlns:stRef="http://ns.adobe.com/xap/1.0/sType/ResourceRef#">{value}</stRef:filePath>\n'
        '   </xmpMM:DerivedFrom>\n'
        f'   <{VF_PREFIX}:SourceVideo>{value}</{VF_PREFIX}:SourceVideo>\n'
        '  </rdf:Description>\n'
        ' </rdf:RDF>\n'
        '</x:xmpmeta>\n'
        '<?xpacket end="w"?>\n'
    )


# ---------------------------------------------------------------------------
# phase 1 -- extract
# ---------------------------------------------------------------------------


@dataclass
class ExtractResult:
    video: Path
    frames: int = 0
    discarded: int = 0
    error: str | None = None
    skipped: str | None = None


def extract_video(
    video: Path,
    work: Path,
    args: argparse.Namespace,
    face_filter: bool,
) -> ExtractResult:
    info = ffprobe_video(video)
    if info is None:
        return ExtractResult(video, error="no usable video stream")

    digest, prefix = frame_stem(video)
    frames_present = sorted(work.glob(f"*__{digest}_*{FRAME_EXT}"))
    # Sidecars are written only once a video's frames are all extracted and
    # filtered, so their presence is what marks the video complete. Judging by
    # the JPEGs alone would treat a run interrupted mid-video as finished, and
    # those frames would never gain sidecars, never reach phase 3, and never be
    # retried.
    done = any(work.glob(f"*__{digest}_*{FRAME_EXT}.xmp"))

    if done and not args.force:
        return ExtractResult(
            video, frames=len(frames_present), skipped="frames present"
        )

    if frames_present and not args.dry_run:
        # Either --force, or a partial extraction to discard and redo.
        for stale in frames_present:
            stale.unlink(missing_ok=True)
            sidecar_for(stale).unlink(missing_ok=True)

    timestamps = sample_timestamps(info.duration, args.interval, args.max_frames)

    if args.dry_run:
        LOG.info(
            "  [dry-run] %s -> %d frame(s) (%s)",
            video.name,
            len(timestamps),
            human_duration(info.duration or 0),
        )
        return ExtractResult(video, frames=len(timestamps))

    extracted: list[Path] = []
    for index, timestamp in enumerate(timestamps, start=1):
        dest = work / f"{prefix}_{index:03d}{FRAME_EXT}"
        if args.select == "sharpest":
            ok = extract_sharpest_frame(
                video, timestamp, dest, args.long_edge, args.quality,
                args.candidates, args.candidate_window,
            )
        else:
            ok = extract_one_frame(
                video, timestamp, dest, args.long_edge, args.quality
            )
        if ok:
            extracted.append(dest)

    if not extracted:
        return ExtractResult(video, error="no frames extracted")

    discarded = 0
    keep = extracted
    if face_filter:
        keep = [p for p in extracted if frame_has_face(p, args.face_threshold)]
        if not keep and args.keep_min > 0:
            # Every frame was rejected. Keep the sharpest few anyway, so the
            # video still appears in the work directory and phase 3 can mark it
            # as processed rather than silently skipping it forever.
            keep = sorted(
                extracted, key=lambda p: p.stat().st_size, reverse=True
            )[: args.keep_min]
        for path in extracted:
            if path not in keep:
                path.unlink(missing_ok=True)
                discarded += 1

    for path in keep:
        sidecar_for(path).write_text(
            frame_sidecar_xml(str(video.resolve())), encoding="utf-8"
        )

    return ExtractResult(video, frames=len(keep), discarded=discarded)


def cmd_extract(args: argparse.Namespace) -> int:
    scan_path = resolve_scope(args)
    work: Path = args.work
    stats = Stats()

    face_filter = False
    if args.face_filter != "off":
        ok, reason = face_filter_available()
        if ok:
            face_filter = True
            LOG.info(
                "face pre-filter: ON (threshold %.2f, keeping >=%d frame(s) per video)",
                args.face_threshold, args.keep_min,
            )
        elif args.face_filter == "on":
            LOG.error("--face-filter on, but it is unavailable: %s", reason)
            return 1
        else:
            LOG.warning("")
            LOG.warning("face pre-filter is OFF: %s", reason)
            LOG.warning(
                "Extraction will still work, but expect roughly twice as many "
                "frames for digiKam to index."
            )
            hint = face_filter_setup_hint()
            if hint:
                LOG.warning("To enable it:")
                for step in hint:
                    LOG.warning("    %s", step)
            LOG.warning("Pass --face-filter off to silence this.")
            LOG.warning("")

    LOG.info("scanning %s", scan_path)
    videos = discover_videos(scan_path, args.probe_all, args.jobs, stats)
    LOG.info("found %d video file(s)", len(videos))
    if not videos:
        stats.report("Phase 1 (extract) summary")
        return 0

    if args.force:
        pending = videos
        LOG.info("--force: ignoring existing markers")
    else:
        LOG.info("checking processing markers...")
        markers = read_markers(videos)
        pending = [v for v in videos if v not in markers]
        stats.bump("skipped (already scanned)", len(markers))
        LOG.info("%d already marked, %d to process", len(markers), len(pending))

    if args.dry_run and face_filter:
        LOG.info(
            "note: dry-run frame counts are BEFORE face filtering; the real "
            "run will keep roughly half of them"
        )

    if not args.dry_run:
        work.mkdir(parents=True, exist_ok=True)

    total = len(pending)
    done = 0
    started = dt.datetime.now()

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = {
            pool.submit(extract_video, video, work, args, face_filter): video
            for video in pending
        }
        for future in concurrent.futures.as_completed(futures):
            video = futures[future]
            done += 1
            try:
                result = future.result()
            except Exception as exc:  # noqa: BLE001 - one bad file must not stop the run
                LOG.error("  FAILED %s: %s", video.name, exc)
                stats.bump("failed")
                continue

            if result.error:
                LOG.error("  FAILED %s: %s", video.name, result.error)
                stats.bump("failed")
            elif result.skipped:
                stats.bump("skipped (frames present)")
            else:
                stats.bump("videos processed")
                stats.bump("frames extracted", result.frames)
                if result.discarded:
                    stats.bump("frames discarded (no face)", result.discarded)

            if done % args.progress_every == 0 or done == total:
                elapsed = (dt.datetime.now() - started).total_seconds()
                rate = done / elapsed if elapsed > 0 else 0
                remaining = (total - done) / rate if rate > 0 else 0
                LOG.info(
                    "  [%d/%d] %.1f/s  frames=%d  eta=%s",
                    done, total, rate,
                    stats.get("frames extracted"),
                    human_duration(remaining),
                )

    stats.report("Phase 1 (extract) summary")
    if not args.dry_run and stats.get("frames extracted"):
        LOG.info("")
        LOG.info("Next: add %s to digiKam as a collection, run", work)
        LOG.info("face detection + recognition, confirm the faces, then run:")
        LOG.info("  %s collect", Path(sys.argv[0]).name)
    return 0


# ---------------------------------------------------------------------------
# phase 3 -- collect
# ---------------------------------------------------------------------------


def person_names_from_record(record: dict, people_root: str) -> set[str]:
    """Pull confirmed person names out of one frame's sidecar record.

    Two independent sources are unioned, because which of them digiKam writes
    depends on its metadata settings:

      - mwg-rs region names (what face tagging produces directly)
      - tag list entries under the People root

    Placeholder names are dropped. digiKam does not write unconfirmed
    suggestions to XMP at all, but a face explicitly marked as ignored is
    written out under the name 'Ignored' (676 sidecars in this archive carry
    one), and without filtering that would become a person tag.
    """
    names: set[str] = set()

    for value in as_list(record.get("XMP-mwg-rs:RegionName")):
        names.add(value)

    prefix = people_root + "/"
    for entry in as_list(record.get(TAGSLIST_TAG)):
        if entry.startswith(prefix):
            leaf = entry[len(prefix):]
            if leaf:
                names.add(leaf)

    prefix_bar = people_root + "|"
    for entry in as_list(record.get(HIERARCHICAL_TAG)):
        if entry.startswith(prefix_bar):
            leaf = entry[len(prefix_bar):]
            if leaf:
                names.add(leaf)

    cleaned = set()
    for name in names:
        name = name.strip()
        if not name or name.lower() in NON_PERSON_NAMES:
            continue
        # A nested face tag such as 'People/Family/Ivan' should contribute the
        # person, not the intermediate group.
        cleaned.add(nfc(name.split("/")[-1].split("|")[-1].strip()))
    return {n for n in cleaned if n and n.lower() not in NON_PERSON_NAMES}


def build_hash_map(scan_path: Path, jobs: int) -> dict[str, Path]:
    """Build a frame-hash -> video map by walking the archive.

    Only needed to recover frames whose sidecar no longer names its source
    video, so it is built lazily rather than on every run.
    """
    mapping: dict[str, Path] = {}
    stats = Stats()
    for video in discover_videos(scan_path, False, jobs, stats):
        digest, _ = frame_stem(video)
        mapping[digest] = video
    return mapping


def group_frames_by_video(
    work: Path,
    root_for_map: Path,
    jobs: int,
    people_root: str,
    stats: Stats,
) -> dict[Path, set[str]]:
    """Read every frame sidecar and group confirmed names by source video."""
    frame_sidecars = sorted(work.glob(f"*{FRAME_EXT}.xmp"))
    if not frame_sidecars:
        return {}

    LOG.info("reading %d frame sidecar(s)...", len(frame_sidecars))
    records = exiftool_read(
        frame_sidecars,
        [
            "XMP-mwg-rs:RegionName",
            TAGSLIST_TAG,
            HIERARCHICAL_TAG,
            SOURCE_VIDEO_TAG,
            DERIVED_FROM_TAG,
        ],
    )

    grouped: dict[Path, set[str]] = {}
    hash_map: dict[str, Path] | None = None

    for sidecar in frame_sidecars:
        record = records.get(sidecar, {})
        video: Path | None = None

        # The sidecar names its source video outright, so no archive walk is
        # needed in the normal case.
        recorded = record.get(SOURCE_VIDEO_TAG) or record.get(DERIVED_FROM_TAG)
        if recorded:
            candidate = Path(str(recorded))
            if candidate.exists():
                video = candidate

        if video is None:
            # Either digiKam dropped the field when it rewrote the sidecar, or
            # the video moved. The hash embedded in the frame filename cannot
            # be destroyed by a metadata tool, so fall back to matching that
            # against the archive. Built once, only if actually needed.
            digest = frame_hash_from_name(sidecar.name)
            if digest:
                if hash_map is None:
                    LOG.info(
                        "some frames do not name their source video; "
                        "rebuilding the map from %s...", root_for_map
                    )
                    hash_map = build_hash_map(root_for_map, jobs)
                    LOG.info("mapped %d video(s)", len(hash_map))
                video = hash_map.get(digest)
                if video is not None:
                    stats.bump("frames recovered via filename hash")

        if video is None:
            stats.bump("frames with unresolvable source video")
            LOG.warning("  cannot resolve source video for %s", sidecar.name)
            continue

        grouped.setdefault(video, set())
        names = person_names_from_record(record, people_root)
        if names:
            stats.bump("frames with confirmed faces")
            grouped[video] |= names
        else:
            stats.bump("frames without faces")

    return grouped


def merge_person_tags(
    video: Path,
    names: set[str],
    args: argparse.Namespace,
    stats: Stats,
) -> bool:
    """Merge person names into a video's sidecar and stamp the marker.

    Existing tags are read first and only genuinely new entries are appended,
    so unrelated tags in the sidecar are left exactly as they were. A video
    whose frames yielded no faces still gets the marker, so it is not
    reprocessed on the next run.
    """
    sidecar = sidecar_for(video)
    people_root = args.people_root

    fields = [TAGSLIST_TAG, HIERARCHICAL_TAG, SUBJECT_TAG]
    if args.extra_tag_fields:
        fields += [LASTKEYWORD_TAG, CATALOGSETS_TAG]

    current: dict[str, list[str]] = {f: [] for f in fields}
    if sidecar.exists():
        records = exiftool_read([sidecar], fields)
        record = records.get(sidecar, {})
        for f in fields:
            current[f] = as_list(record.get(f))

    assignments: list[str] = []
    added = 0

    for name in sorted(names):
        wanted = {
            TAGSLIST_TAG: f"{people_root}/{name}",
            HIERARCHICAL_TAG: f"{people_root}|{name}",
            SUBJECT_TAG: name,
            LASTKEYWORD_TAG: f"{people_root}/{name}",
            CATALOGSETS_TAG: f"{people_root}|{name}",
        }
        new_for_name = False
        for f in fields:
            value = wanted[f]
            if value not in current[f]:
                assignments.append(f"-{f}+={value}")
                current[f].append(value)
                new_for_name = True
        if new_for_name:
            added += 1

    today = dt.date.today().isoformat()
    assignments.append(f"-{MARKER_TAG}={MARKER_PREFIX}{today}")
    assignments.append(f"-{FACE_COUNT_TAG}={len(names)}")

    if names:
        LOG.info(
            "  %s: %d name(s) [%s]%s",
            video.name,
            len(names),
            ", ".join(sorted(names)),
            "" if added else " (all already present)",
        )
    else:
        LOG.info("  %s: no faces, marker only", video.name)

    ok = exiftool_write(sidecar, assignments, args.dry_run)
    if ok:
        stats.bump("videos marked")
        if names:
            stats.bump("videos with faces")
            stats.bump("person tags added", added)
        else:
            stats.bump("videos without faces")
    else:
        stats.bump("failed")
    return ok


def cmd_collect(args: argparse.Namespace) -> int:
    scan_path = resolve_scope(args)
    work: Path = args.work
    stats = Stats()

    if not work.exists():
        LOG.error("work directory does not exist: %s", work)
        return 1

    grouped = group_frames_by_video(
        work, scan_path, args.jobs, args.people_root, stats
    )
    if not grouped:
        LOG.warning("no frame sidecars found in %s", work)
        stats.report("Phase 3 (collect) summary")
        return 0

    # Honour --path by restricting to videos under the requested subtree.
    grouped = {
        v: n for v, n in grouped.items()
        if scan_path == v or scan_path in v.parents
    }

    LOG.info("")
    LOG.info("merging names into %d video sidecar(s)", len(grouped))
    for video in sorted(grouped):
        merge_person_tags(video, grouped[video], args, stats)

    stats.report("Phase 3 (collect) summary")
    face_totals = sorted(
        ((len(n), v) for v, n in grouped.items() if n), reverse=True
    )
    if face_totals:
        LOG.info("")
        LOG.info("Per-video face counts (top 20):")
        for count, video in face_totals[:20]:
            LOG.info("  %2d  %s", count, video.name)
    return 0


# ---------------------------------------------------------------------------
# phase 4 -- clean
# ---------------------------------------------------------------------------


def cmd_clean(args: argparse.Namespace) -> int:
    scan_path = resolve_scope(args)
    work: Path = args.work
    stats = Stats()

    if not work.exists():
        LOG.error("work directory does not exist: %s", work)
        return 1

    frames = sorted(work.glob(f"*{FRAME_EXT}"))
    if not frames:
        LOG.info("no frames in %s", work)
        return 0

    if args.all:
        targets = frames
        LOG.info("--all: removing every frame in %s", work)
    else:
        LOG.info("determining which videos have been processed...")
        hash_map = build_hash_map(scan_path, args.jobs)
        videos = sorted(set(hash_map.values()))
        markers = read_markers(videos)
        processed_hashes = {
            digest for digest, video in hash_map.items() if video in markers
        }
        targets = []
        for frame in frames:
            digest = frame_hash_from_name(frame.name)
            if digest and digest in processed_hashes:
                targets.append(frame)
            else:
                stats.bump("frames kept (video not yet processed)")
        LOG.info("%d of %d video(s) carry the marker", len(markers), len(videos))

    for frame in targets:
        if args.dry_run:
            LOG.info("  [dry-run] rm %s", frame.name)
        else:
            frame.unlink(missing_ok=True)
            sidecar_for(frame).unlink(missing_ok=True)
        stats.bump("frames removed")

    if not args.dry_run:
        try:
            next(work.iterdir())
        except StopIteration:
            LOG.info("work directory is now empty: %s", work)

    stats.report("Phase 4 (clean) summary")
    return 0


# ---------------------------------------------------------------------------
# status
# ---------------------------------------------------------------------------


def cmd_status(args: argparse.Namespace) -> int:
    scan_path = resolve_scope(args)
    work: Path = args.work
    stats = Stats()

    videos = discover_videos(scan_path, args.probe_all, args.jobs, stats)
    LOG.info("videos under %s: %d", scan_path, len(videos))

    markers = read_markers(videos)
    stats.bump("videos total", len(videos))
    stats.bump("videos scanned (marker present)", len(markers))
    stats.bump("videos pending", len(videos) - len(markers))

    by_date: dict[str, int] = {}
    for value in markers.values():
        match = MARKER_DATE_RE.match(str(value))
        key = match.group(1) if match else "unparsed"
        by_date[key] = by_date.get(key, 0) + 1

    if work.exists():
        frames = list(work.glob(f"*{FRAME_EXT}"))
        stats.bump("frames in work directory", len(frames))
        digests = set()
        for frame in frames:
            digest = frame_hash_from_name(frame.name)
            if digest:
                digests.add(digest)
        stats.bump("videos represented in work directory", len(digests))

    stats.report("Status")
    if by_date:
        LOG.info("")
        LOG.info("Marker dates:")
        for key in sorted(by_date):
            LOG.info("  %s : %d", key, by_date[key])
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


# Settings that name a filesystem location. argparse's type= conversion does
# not run on values injected as defaults, so these are converted by hand.
PATH_SETTINGS = frozenset({"path", "work", "log"})

CONFIG_TEMPLATE = """\
# Configuration for video_face_tagger.py
#
# Every setting here is optional and simply changes a default; anything passed
# on the command line still wins. Keys match the long option names with the
# leading dashes removed and hyphens turned into underscores, so --max-frames
# becomes max_frames.

# Applied to every subcommand.
[defaults]
# path = "~/Photo"
# work = "~/video_face_tagger_work"
# jobs = 6
# people_root = "People"

# Applied to 'extract' only, and takes precedence over [defaults].
[extract]
# interval = 5.0
# max_frames = 40
# long_edge = 1280
# select = "sharpest"
# face_filter = "auto"
# face_threshold = 0.6
# keep_min = 1

# Applied to 'collect' only.
[collect]
# extra_tag_fields = false
"""


def load_config(path: Path) -> dict[str, Any]:
    """Read the TOML config, returning {} when absent or unreadable.

    A broken config must not stop a long archive run, so parse errors are
    reported and then ignored rather than raised.
    """
    if not path.is_file():
        return {}
    try:
        import tomllib
    except ImportError:  # Python < 3.11
        print(
            f"warning: ignoring {path} (this Python has no tomllib)",
            file=sys.stderr,
        )
        return {}
    try:
        with path.open("rb") as handle:
            return tomllib.load(handle)
    except Exception as exc:  # noqa: BLE001 - a bad config should not be fatal
        print(f"warning: ignoring {path}: {exc}", file=sys.stderr)
        return {}


def config_has_settings(config: dict[str, Any]) -> bool:
    """True only if some table actually carries a key.

    A freshly written template parses into empty tables, which must not be
    reported as though settings had been loaded.
    """
    return any(
        isinstance(table, dict) and table for table in config.values()
    )


def config_defaults_for(config: dict[str, Any], command: str) -> dict[str, Any]:
    """Merge [defaults] with the command's own table, the latter winning."""
    merged: dict[str, Any] = {}
    for section in ("defaults", command):
        table = config.get(section)
        if isinstance(table, dict):
            merged.update(table)
    return merged


def apply_config_defaults(
    parser: argparse.ArgumentParser,
    config: dict[str, Any],
    command: str,
) -> list[str]:
    """Override a subparser's defaults from config; return unknown keys."""
    settings = config_defaults_for(config, command)
    if not settings:
        return []

    known = {
        action.dest for action in parser._actions if action.dest != "help"
    }
    accepted: dict[str, Any] = {}
    unknown: list[str] = []
    for key, value in settings.items():
        if key not in known:
            unknown.append(key)
            continue
        if key in PATH_SETTINGS and isinstance(value, str):
            value = Path(value).expanduser()
        accepted[key] = value

    if accepted:
        parser.set_defaults(**accepted)
    return unknown


def cmd_config(args: argparse.Namespace) -> int:
    """Show where config is read from, or write a commented template."""
    path: Path = args.config
    if args.init:
        if path.exists() and not args.force:
            LOG.error("%s already exists (use --force to overwrite)", path)
            return 1
        if args.dry_run:
            LOG.info("[dry-run] would write template to %s", path)
            return 0
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(CONFIG_TEMPLATE, encoding="utf-8")
        LOG.info("wrote template: %s", path)
        return 0

    LOG.info("config file : %s", path)
    LOG.info("exists      : %s", "yes" if path.is_file() else "no")
    config = load_config(path)
    if config_has_settings(config):
        LOG.info("")
        LOG.info("Parsed contents:")
        for section, table in config.items():
            LOG.info("  [%s]", section)
            if isinstance(table, dict):
                for key, value in table.items():
                    LOG.info("    %s = %r", key, value)
    elif path.is_file():
        LOG.info("")
        LOG.info("No settings active (every key is commented out).")
    else:
        LOG.info("")
        LOG.info("No config file. Create one with:")
        LOG.info("  %s config --init", Path(sys.argv[0]).name)
    return 0


def resolve_scope(args: argparse.Namespace) -> Path:
    """Return the directory to process, honouring --path."""
    scan_path = Path(args.path).expanduser().resolve()
    if not scan_path.is_dir():
        raise SystemExit(f"--path not found: {scan_path}")
    return scan_path


def setup_logging(logfile: Path | None, verbose: bool) -> None:
    LOG.setLevel(logging.DEBUG if verbose else logging.INFO)
    LOG.handlers.clear()

    console = logging.StreamHandler(sys.stdout)
    console.setFormatter(logging.Formatter("%(message)s"))
    console.setLevel(logging.DEBUG if verbose else logging.INFO)
    LOG.addHandler(console)

    if logfile:
        logfile.parent.mkdir(parents=True, exist_ok=True)
        handler = logging.FileHandler(logfile, encoding="utf-8")
        handler.setFormatter(
            logging.Formatter("%(asctime)s %(levelname)-7s %(message)s")
        )
        handler.setLevel(logging.DEBUG)
        LOG.addHandler(handler)
        LOG.debug("logging to %s", logfile)


def check_dependencies() -> None:
    missing = [t for t in ("exiftool", "ffmpeg", "ffprobe") if not shutil.which(t)]
    if missing:
        raise SystemExit(
            "missing required tool(s): "
            + ", ".join(missing)
            + "\ninstall with: brew install exiftool ffmpeg"
        )


def build_parser(config: dict[str, Any] | None = None) -> argparse.ArgumentParser:
    config = config or {}
    parser = argparse.ArgumentParser(
        prog="video_face_tagger.py",
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
        "--work", type=Path, default=DEFAULT_WORK,
        help=f"frame working directory (default: {DEFAULT_WORK})",
    )
    common.add_argument(
        "--jobs", type=int, default=max(1, min(6, (os.cpu_count() or 4))),
        help="parallel workers (default: 6 on this machine; ffmpeg is already "
             "multi-threaded, so more is usually slower)",
    )
    common.add_argument(
        "--log", type=Path, default=None,
        help="append a detailed log here (default: <work>/logs/<phase>.log)",
    )
    common.add_argument("--verbose", action="store_true", help="debug output")
    common.add_argument(
        "--config", type=Path, default=CONFIG_FILE,
        help=f"TOML config supplying defaults (default: {CONFIG_FILE})",
    )
    common.add_argument(
        "--probe-all", action="store_true",
        help="ffprobe every file instead of trusting known extensions",
    )
    common.add_argument(
        "--people-root", default="People",
        help="root tag people live under (default: People)",
    )
    common.add_argument(
        "--progress-every", type=int, default=25,
        help="emit a progress line every N videos (default: 25)",
    )

    writing = argparse.ArgumentParser(add_help=False)
    writing.add_argument(
        "--dry-run", action="store_true",
        help="show what would change without writing anything",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    extract = subparsers.add_parser(
        "extract", parents=[common, writing],
        help="phase 1: sample frames from videos into the work directory",
    )
    extract.add_argument(
        "--interval", type=float, default=5.0,
        help="seconds between sampled frames (default: 5)",
    )
    extract.add_argument(
        "--max-frames", type=int, default=40,
        help="cap on frames per video (default: 40)",
    )
    extract.add_argument(
        "--long-edge", type=int, default=1280,
        help="downscale frames to this long edge (default: 1280)",
    )
    extract.add_argument(
        "--quality", type=int, default=2,
        help="ffmpeg JPEG quality, lower is better (default: 2)",
    )
    extract.add_argument(
        "--select", choices=("uniform", "sharpest"), default="sharpest",
        help="frame picking strategy (default: sharpest)",
    )
    extract.add_argument(
        "--candidates", type=int, default=3,
        help="candidates per sample point when --select sharpest (default: 3)",
    )
    extract.add_argument(
        "--candidate-window", type=float, default=1.0,
        help="seconds spanned by the candidates (default: 1.0)",
    )
    extract.add_argument(
        "--force", action="store_true",
        help="re-extract even for videos already carrying the marker",
    )
    extract.add_argument(
        "--face-filter", choices=("auto", "on", "off"), default="auto",
        help="discard frames with no detectable face before digiKam sees them. "
             "auto (default) uses it when opencv and the model are available, "
             "on fails if they are not, off disables it",
    )
    extract.add_argument(
        "--face-threshold", type=float, default=0.6,
        help="YuNet score threshold (default: 0.6, measured at 100%% recall "
             "against digiKam-confirmed faces on this archive)",
    )
    extract.add_argument(
        "--keep-min", type=int, default=1,
        help="frames to keep per video even when none contain a face, so the "
             "video still gets marked in phase 3 (default: 1)",
    )
    extract.set_defaults(func=cmd_extract)

    collect = subparsers.add_parser(
        "collect", parents=[common, writing],
        help="phase 3: merge confirmed names into video sidecars",
    )
    collect.add_argument(
        "--extra-tag-fields", action="store_true",
        help="also update XMP-microsoft:LastKeywordXMP and "
             "XMP-mediapro:CatalogSets, which digiKam maintains too",
    )
    collect.set_defaults(func=cmd_collect)

    clean = subparsers.add_parser(
        "clean", parents=[common, writing],
        help="phase 4: remove work frames for processed videos",
    )
    clean.add_argument(
        "--all", action="store_true",
        help="remove every frame, processed or not",
    )
    clean.set_defaults(func=cmd_clean)

    fetch = subparsers.add_parser(
        "fetch-model", parents=[common, writing],
        help="download the YuNet face model used by --face-filter",
    )
    fetch.set_defaults(func=cmd_fetch_model)

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

    status = subparsers.add_parser(
        "status", parents=[common],
        help="report how many videos are scanned, pending, or staged",
    )
    status.set_defaults(func=cmd_status, dry_run=True)

    if config_has_settings(config):
        every_option: set[str] = set()
        for name, sub in subparsers.choices.items():
            apply_config_defaults(sub, config, name)
            every_option.update(action.dest for action in sub._actions)

        # A setting no subcommand accepts is almost certainly a typo. Settings
        # that merely do not apply to every subcommand (interval, say) are
        # fine and must not warn.
        configured: set[str] = set()
        for section in ("defaults", *subparsers.choices):
            table = config.get(section)
            if isinstance(table, dict):
                configured.update(table)
        for key in sorted(configured - every_option):
            print(f"warning: unknown config setting: {key}", file=sys.stderr)

    return parser


def main(argv: Sequence[str] | None = None) -> int:
    # --config has to be known before the real parser is built, since it
    # supplies that parser's defaults.
    pre = argparse.ArgumentParser(add_help=False)
    pre.add_argument("--config", type=Path, default=CONFIG_FILE)
    pre_args, _ = pre.parse_known_args(argv)
    config = load_config(pre_args.config.expanduser())

    parser = build_parser(config)
    args = parser.parse_args(argv)

    args.work = args.work.expanduser()
    logfile = args.log or (args.work / "logs" / f"{args.command}.log")
    setup_logging(logfile, args.verbose)

    LOG.debug(
        "interpreter: %s (virtualenv: %s)",
        sys.executable,
        sys.prefix if sys.prefix != sys.base_prefix else "none",
    )

    check_dependencies()
    ensure_exiftool_config()

    started = dt.datetime.now()
    LOG.info("=== video_face_tagger.py %s: %s ===", args.command, started.isoformat(timespec="seconds"))
    if config_has_settings(config):
        LOG.info("config: %s", pre_args.config.expanduser())
    if getattr(args, "dry_run", False):
        LOG.info("DRY RUN -- nothing will be written")

    try:
        rc = args.func(args)
    except KeyboardInterrupt:
        LOG.warning("interrupted; re-run to resume")
        return 130

    LOG.info("")
    LOG.info("elapsed: %s", human_duration((dt.datetime.now() - started).total_seconds()))
    return rc


if __name__ == "__main__":
    sys.exit(main())
