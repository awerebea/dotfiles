#!/usr/bin/env python3
"""Audit a KeePassXC XML export for UUID inconsistencies.

Reports:
  - UUIDs present both in active entries and in <DeletedObjects>
  - duplicate UUIDs among active entries
  - duplicate UUIDs within <DeletedObjects>

Privacy / safety:
  - Strictly read-only: the input file is opened in binary read mode and
    nothing is ever written to disk.
  - No network access: only standard-library modules with no network
    functionality are imported.
  - Only entry titles, group names, UUIDs and timestamps are printed.
    Passwords, usernames, URLs, notes, custom fields and attachments are
    never read into the report or printed.

UUID format (KDBX / KeePassXC):
  <UUID> elements hold Base64 of 16 raw bytes. KeePass 2 (PwUuid) stores
  the bytes as-is, and KeePassXC uses QUuid::fromRfc4122() /
  QUuid::toRfc4122() when reading/writing them, i.e. the raw bytes are in
  RFC 4122 (big-endian) order. So the canonical form is
  uuid.UUID(bytes=raw), NOT uuid.UUID(bytes_le=raw). KeePassXC displays
  UUIDs as 32 lowercase hex chars without dashes (Tools::uuidToHex), which
  is printed alongside the dashed form. Comparison is done on raw bytes,
  so the byte order only affects display, never matching.

Notes:
  - Entry/History/Entry elements are previous versions of an entry and
    share its UUID by design; they are excluded from the active set.
  - Entries inside the recycle bin group are included and flagged.

Usage:
  keepassxc_uuid_audit.py /path/to/export.xml
"""

from __future__ import annotations

import argparse
import base64
import binascii
import datetime
import struct
import sys
import uuid
import xml.etree.ElementTree as ET
from collections import defaultdict
from contextlib import suppress
from dataclasses import dataclass, field
from pathlib import Path
from typing import Final

# KDBX 4 stores times as Base64 of int64 LE seconds since 0001-01-01 UTC.
KDBX_EPOCH: Final = datetime.datetime(1, 1, 1, tzinfo=datetime.UTC)
NULL_UUID: Final = bytes(16)
UUID_LEN: Final = 16
TIME_FORMAT: Final = "%Y-%m-%d %H:%M:%S UTC"

EXIT_CLEAN: Final = 0
EXIT_FINDINGS: Final = 1
EXIT_ERROR: Final = 2


class UuidError(ValueError):
    """Raised when a <UUID> value cannot be decoded into 16 bytes."""


@dataclass(frozen=True)
class EntryInfo:
    """Non-sensitive identifying details of an active entry."""

    title: str
    group_path: str
    in_recycle_bin: bool


@dataclass(frozen=True)
class Malformed:
    """Location of an undecodable UUID; never holds the raw value."""

    location: str
    reason: str


def decode_uuid(text: str | None) -> bytes:
    """Return the 16 raw UUID bytes from a Base64 <UUID> value."""
    if text is None or not text.strip():
        raise UuidError("empty")
    try:
        raw = base64.b64decode(text.strip(), validate=True)
    except (binascii.Error, ValueError) as e:
        raise UuidError("invalid base64") from e
    if len(raw) != UUID_LEN:
        raise UuidError(f"decoded to {len(raw)} bytes, expected {UUID_LEN}")
    return raw


def fmt_uuid(raw: bytes) -> str:
    """Format raw UUID bytes as KeePassXC hex plus dashed RFC 4122 form."""
    u = uuid.UUID(bytes=raw)
    return f"{u.hex} ({u})"


def decode_time(text: str | None) -> str | None:
    """Decode a KDBX time value (ISO 8601 or KDBX 4 Base64 seconds)."""
    if text is None or not text.strip():
        return None
    text = text.strip()
    with suppress(ValueError):
        iso = text[:-1] + "+00:00" if text.endswith("Z") else text
        dt = datetime.datetime.fromisoformat(iso)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=datetime.UTC)
        return dt.astimezone(datetime.UTC).strftime(TIME_FORMAT)
    with suppress(binascii.Error, ValueError, OverflowError):
        raw = base64.b64decode(text, validate=True)
        if len(raw) == 8:
            secs: int = struct.unpack("<q", raw)[0]
            return (KDBX_EPOCH + datetime.timedelta(seconds=secs)).strftime(TIME_FORMAT)
    return "<unparseable time>"


def entry_title(entry: ET.Element) -> str:
    """Return only the Title field of an entry, nothing else."""
    for s in entry.findall("String"):
        if s.findtext("Key") == "Title":
            return s.findtext("Value") or ""
    return ""


@dataclass
class Audit:
    """UUIDs collected from the group tree and <DeletedObjects>."""

    active: defaultdict[bytes, list[EntryInfo]] = field(
        default_factory=lambda: defaultdict(list)
    )
    deleted: defaultdict[bytes, list[str | None]] = field(
        default_factory=lambda: defaultdict(list)
    )
    malformed: list[Malformed] = field(default_factory=list)
    recycle_bin: bytes | None = None
    history_count: int = 0

    def load(self, root: ET.Element) -> None:
        """Collect UUIDs from a parsed <KeePassFile> document."""
        if root.tag != "KeePassFile":
            raise SystemExit(
                f"error: root element is <{root.tag}>, expected <KeePassFile>"
            )
        self._load_recycle_bin(root.find("Meta"))

        xroot = root.find("Root")
        if xroot is None:
            raise SystemExit("error: <Root> element not found")
        for group in xroot.findall("Group"):
            self._walk_group(group, [], in_bin=False)

        dobjs = xroot.findall("DeletedObjects/DeletedObject")
        for i, dobj in enumerate(dobjs, start=1):
            try:
                raw = decode_uuid(dobj.findtext("UUID"))
            except UuidError as e:
                self.malformed.append(Malformed(f"DeletedObject #{i}", str(e)))
                continue
            self.deleted[raw].append(decode_time(dobj.findtext("DeletionTime")))

    def _load_recycle_bin(self, meta: ET.Element | None) -> None:
        if meta is None:
            return
        enabled = (meta.findtext("RecycleBinEnabled") or "").strip()
        try:
            rb = decode_uuid(meta.findtext("RecycleBinUUID"))
        except UuidError:
            return
        if rb != NULL_UUID and enabled.lower() != "false":
            self.recycle_bin = rb

    def _walk_group(self, group: ET.Element, path: list[str], in_bin: bool) -> None:
        path = [*path, group.findtext("Name") or "<unnamed>"]
        try:
            gid: bytes | None = decode_uuid(group.findtext("UUID"))
        except UuidError:
            gid = None
        in_bin = in_bin or (self.recycle_bin is not None and gid == self.recycle_bin)
        for child in group:
            if child.tag == "Entry":
                self._add_entry(child, path, in_bin)
            elif child.tag == "Group":
                self._walk_group(child, path, in_bin)

    def _add_entry(self, entry: ET.Element, path: list[str], in_bin: bool) -> None:
        group_path = "/".join(path)
        hist = entry.find("History")
        if hist is not None:
            self.history_count += len(hist.findall("Entry"))
        try:
            raw = decode_uuid(entry.findtext("UUID"))
        except UuidError as e:
            self.malformed.append(Malformed(f"entry in group '{group_path}'", str(e)))
            return
        self.active[raw].append(EntryInfo(entry_title(entry), group_path, in_bin))


def print_finding(audit: Audit, raw: bytes) -> None:
    """Print one UUID finding with its entries and deletion markers."""
    entries = audit.active.get(raw, [])
    times = audit.deleted.get(raw, [])
    print(f"  UUID: {fmt_uuid(raw)}")
    print(f"    active entries:   {len(entries)}")
    print(f"    deletion markers: {len(times)}")
    for e in entries:
        flag = " [recycle bin]" if e.in_recycle_bin else ""
        print(f"    - entry: title={e.title!r} group={e.group_path!r}{flag}")
    for t in times:
        print(f"    - deleted at: {t or '<no timestamp>'}")


def report(audit: Audit, path: Path) -> int:
    """Print the audit report and return the process exit code."""
    both = sorted(audit.active.keys() & audit.deleted.keys())
    dup_active = sorted(k for k, v in audit.active.items() if len(v) > 1)
    dup_deleted = sorted(k for k, v in audit.deleted.items() if len(v) > 1)

    n_entries = sum(len(v) for v in audit.active.values())
    n_markers = sum(len(v) for v in audit.deleted.values())
    bin_desc = fmt_uuid(audit.recycle_bin) if audit.recycle_bin else "none/disabled"

    print(f"File: {path}")
    print(
        f"Active entry UUIDs: {len(audit.active)} unique ({n_entries} entries), "
        f"history versions skipped: {audit.history_count}"
    )
    print(f"DeletedObjects:     {len(audit.deleted)} unique ({n_markers} markers)")
    print(f"Recycle bin:        {bin_desc}")
    print()
    print("Summary:")
    print(f"  In both active entries and DeletedObjects: {len(both)}")
    print(f"  Duplicate UUIDs among active entries:      {len(dup_active)}")
    print(f"  Duplicate UUIDs within DeletedObjects:     {len(dup_deleted)}")
    print(f"  Malformed UUID values:                     {len(audit.malformed)}")

    sections: list[tuple[str, list[bytes]]] = [
        ("UUIDs in both active entries and DeletedObjects", both),
        ("Duplicate UUIDs among active entries", dup_active),
        ("Duplicate UUIDs within DeletedObjects", dup_deleted),
    ]
    for header, items in sections:
        if not items:
            continue
        print()
        print(f"{header} ({len(items)}):")
        for raw in items:
            print_finding(audit, raw)

    if audit.malformed:
        print()
        print(f"Malformed UUID values ({len(audit.malformed)}):")
        for m in audit.malformed:
            print(f"  - {m.location}: {m.reason}")

    found = both or dup_active or dup_deleted or audit.malformed
    return EXIT_FINDINGS if found else EXIT_CLEAN


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Audit a KeePassXC XML export for UUID inconsistencies "
        "(read-only, offline)."
    )
    parser.add_argument("xml_file", type=Path, help="path to the KeePassXC XML export")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    """Run the audit and return the process exit code."""
    path: Path = parse_args(argv).xml_file
    if not path.is_file():
        print(f"error: not a file: {path}", file=sys.stderr)
        return EXIT_ERROR

    try:
        with path.open("rb") as fh:
            tree = ET.parse(fh)
    except ET.ParseError as e:
        # Only the position is reported, never the offending content.
        line, col = e.position
        print(f"error: XML parse failed at line {line}, column {col}", file=sys.stderr)
        return EXIT_ERROR

    audit = Audit()
    audit.load(tree.getroot())
    return report(audit, path)


if __name__ == "__main__":
    sys.exit(main())
