"""Small helpers shared by the photo-archive tools."""

from __future__ import annotations

import hashlib
import logging
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any

#: One logger for the whole package. Entry points configure it through
#: setup_logging(); every module logs into it so a single --log file captures
#: shared and tool-specific output alike.
LOG = logging.getLogger("photo_archive")


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
    """Short stable identifier for a file, derived from its path."""
    digest = hashlib.sha1(nfc(rel_path).encode("utf-8")).hexdigest()
    return digest[:10]


def ascii_slug(name: str, limit: int = 48) -> str:
    """Filesystem-safe ASCII stem, so derived names carry no Cyrillic or spaces."""
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


def human_distance(metres: float) -> str:
    """Format a distance for reports, keeping the units obvious."""
    if metres < 1000:
        return f"{metres:.0f}m"
    if metres < 100000:
        return f"{metres / 1000:.1f}km"
    return f"{metres / 1000:.0f}km"


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
