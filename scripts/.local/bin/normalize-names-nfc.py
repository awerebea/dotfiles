#!/usr/bin/env python3

"""
normalize-names-nfc

Recursively normalize file and directory names to Unicode NFC.

This is useful when files are shared between macOS and Linux/TrueNAS.
macOS commonly represents filenames using decomposed Unicode (NFD-like),
while Linux filesystems generally preserve the exact byte sequence.

For example:

    Андрей
    Андрей

look identical but are different Unicode sequences. This can cause tools
such as rsync to consider the names different and synchronize/recreate
files unnecessarily.

The script converts names to NFC so that logically identical names use
one canonical Unicode representation.

By default the script performs a dry run. Use --apply to actually rename.

Examples:

    normalize-names-nfc /mnt/tank/photo

    normalize-names-nfc --apply /mnt/tank/photo

    normalize-names-nfc --help
"""

import argparse
import sys
import unicodedata
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
        prog="normalize-names-nfc",
        description=(
            "Recursively normalize file and directory names to Unicode NFC. "
            "Useful for eliminating macOS/Linux filename normalization "
            "differences that can cause unnecessary rsync drift."
        ),
        epilog=(
            "By default this is a dry run. Use --apply to perform the "
            "renames. The script checks for normalization collisions before "
            "making any changes."
        ),
    )

    parser.add_argument(
        "path",
        metavar="PATH",
        help="directory to recursively process",
    )

    parser.add_argument(
        "--apply",
        action="store_true",
        help="actually rename files and directories (default: dry run)",
    )

    return parser.parse_args()


def find_changes(root):
    """
    Return [(source, target), ...] for objects whose names are not NFC.

    Objects are returned deepest-first so that directory renames do not
    invalidate paths that still need to be processed.
    """
    changes = []

    for path in sorted(
        root.rglob("*"),
        key=lambda p: len(p.parts),
        reverse=True,
    ):
        normalized_name = unicodedata.normalize("NFC", path.name)

        if normalized_name != path.name:
            target = path.with_name(normalized_name)
            changes.append((path, target))

    return changes


def is_orphaned_entry(path):
    """
    Detect a directory entry that the filesystem lists but cannot stat.

    This happens with corrupted exFAT/HFS+ catalog entries left behind by
    interrupted or buggy rename/move operations: the name still appears
    in the parent directory's listing, but there is no usable inode
    behind it, so operations like rename() or lstat() fail with ENOENT
    even though the name is visible.
    """
    try:
        path.lstat()
    except OSError:
        return path.name in {entry.name for entry in path.parent.iterdir()}

    return False


def check_collisions(changes):
    """
    Detect cases where two source paths would end up with the same target
    path, or where the target already exists as a different filesystem
    object.
    """
    errors = []

    target_sources = {}

    for source, target in changes:
        target_sources.setdefault(str(target), []).append(source)

    for target, sources in target_sources.items():
        if len(sources) > 1:
            errors.append(
                "Multiple objects would be renamed to the same target:\n"
                + "\n".join(f"  {source}" for source in sources)
                + f"\n  -> {target}"
            )

    change_sources = {source for source, _ in changes}

    for source, target in changes:
        if target.exists() and target not in change_sources:
            errors.append(
                f"Target already exists:\n" f"  FROM: {source}\n" f"  TO:   {target}"
            )

    return errors


def main():
    args = parse_args()

    root = Path(args.path).expanduser()

    if not root.exists():
        print(f"ERROR: path does not exist: {root}", file=sys.stderr)
        return 1

    if not root.is_dir():
        print(f"ERROR: path is not a directory: {root}", file=sys.stderr)
        return 1

    changes = find_changes(root)

    if not changes:
        print(f"No non-NFC names found under: {root}")
        return 0

    collisions = check_collisions(changes)

    if collisions:
        print("ERROR: normalization collisions detected.")
        print()
        for error in collisions:
            print(error)
            print()

        print("No changes were made.")
        return 1

    print(f"Root: {root}")
    print(f"Objects requiring normalization: {len(changes)}")
    print()

    for source, target in changes:
        print("RENAME:")
        print(f"  FROM: {source}")
        print(f"  TO:   {target}")
        print()

    if not args.apply:
        print("Dry run: no changes were made.")
        print()
        print("Run again with --apply to perform these renames.")
        return 0

    print("Applying changes...")
    print()

    renamed = 0
    skipped = 0
    failed = 0
    orphaned = []

    for source, target in changes:
        try:
            source.rename(target)
            renamed += 1
        except OSError as exc:
            if not source.exists() and target.exists():
                print(
                    f"SKIP (already renamed):\n"
                    f"  FROM: {source}\n"
                    f"  TO:   {target}\n"
                )
                skipped += 1
                continue

            if is_orphaned_entry(source):
                print(
                    f"SKIP (corrupted/orphaned directory entry, cannot rename):\n"
                    f"  FROM: {source}\n"
                    f"  This name is listed by the filesystem but has no usable "
                    f"inode (stat fails). This is filesystem-level corruption, "
                    f"not something a rename can fix. Try unmounting the volume "
                    f"and running fsck for its filesystem type, or remove the "
                    f"entry manually with sudo.\n",
                    file=sys.stderr,
                )
                skipped += 1
                orphaned.append(source)
                continue

            print(
                f"ERROR: failed to rename:\n"
                f"  FROM: {source}\n"
                f"  TO:   {target}\n"
                f"  {exc}\n",
                file=sys.stderr,
            )
            failed += 1

    print(f"Renamed {renamed} object(s), skipped {skipped}, failed {failed}.")

    if orphaned:
        print()
        print(f"Orphaned/corrupted entries ({len(orphaned)}), one path per line:")
        for path in orphaned:
            print(f"ORPHANED\t{path}")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
