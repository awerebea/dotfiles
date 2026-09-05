#!/usr/bin/env python3

"""
normalize_names_nfc.py

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

Run this on the machine that owns the storage. The macOS SMB and AFP
clients convert names to NFD on the wire, so names can never be
normalized through such a mount, and the script will refuse to keep going
once it detects that.

Where both spellings of one name exist side by side, the collision is
reported with a comparison of the two objects. Use --resolve-duplicates
to delete a non-NFC object whose contents are already present in full
under the NFC name.

By default the script performs a dry run. Use --apply to actually rename.

Examples:

    normalize_names_nfc.py /mnt/tank/photo

    normalize_names_nfc.py --apply /mnt/tank/photo

    normalize_names_nfc.py --resolve-duplicates --apply /mnt/tank/photo

    normalize_names_nfc.py --help
"""

import argparse
import hashlib
import os
import shutil
import stat
import sys
from pathlib import Path

# Run from a source checkout as well as through the symlink on PATH: the
# package lives one directory up from this entry point either way, and
# resolve() follows the symlink to get there.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from photo_archive.util import nfc


def parse_args():
    parser = argparse.ArgumentParser(
        prog="normalize_names_nfc.py",
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

    parser.add_argument(
        "--resolve-duplicates",
        action="store_true",
        help=(
            "delete non-NFC objects whose contents already exist in full "
            "under the colliding NFC name (default: report and stop)"
        ),
    )

    return parser.parse_args()


def find_changes(root):
    """
    Return [(source, target), ...] for objects whose names are not NFC.

    Objects are returned deepest-first so that directory renames do not
    invalidate paths that still need to be processed.

    Some filesystems list the same directory entry more than once; macOS
    smbfs in particular can repeat an entry across a readdir boundary.
    Identical paths are collapsed so that a doubled listing does not look
    like two objects competing for one target name.
    """
    changes = []
    seen = set()

    for path in sorted(
        root.rglob("*"),
        key=lambda p: len(p.parts),
        reverse=True,
    ):
        if str(path) in seen:
            continue

        seen.add(str(path))

        normalized_name = nfc(path.name)

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


def is_same_object(left, right):
    """
    Report whether two paths name one and the same filesystem object.

    Normalization-insensitive filesystems (APFS, SMB shares) resolve both
    the NFC and the NFD spelling of a name to a single inode. A target
    that "already exists" on such a filesystem is usually just the source
    seen under its other spelling, not a second object standing in the way.
    """
    try:
        left_stat = left.lstat()
        right_stat = right.lstat()
    except OSError:
        return False

    return (
        left_stat.st_dev == right_stat.st_dev
        and left_stat.st_ino == right_stat.st_ino
    )


def file_digest(path):
    """Return the SHA-256 of a file, read in chunks."""
    digest = hashlib.sha256()

    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)

    return digest.hexdigest()


def tree_summary(root):
    """
    Map every object under root to (kind, size, relative path).

    The key is the NFC-normalized relative path, so that a subtree stored
    decomposed can be compared against the same subtree stored composed.
    The unnormalized relative path is kept alongside so the real on-disk
    object can still be opened.
    """
    entries = {}

    for dirpath, dirnames, filenames in os.walk(root):
        parent = os.path.relpath(dirpath, root)

        for name, kind in [(n, "dir") for n in dirnames] + [
            (n, "file") for n in filenames
        ]:
            relative = name if parent == "." else os.path.join(parent, name)

            try:
                size = os.lstat(os.path.join(dirpath, name)).st_size
            except OSError:
                size = -1

            key = nfc(relative)
            entries[key] = (kind, size, relative)

    return entries


def compare_trees(source, target):
    """
    Compare two directory trees by name, size, and content.

    Returns (only_in_source, only_in_target, differing). Files that agree
    on name and size are hashed, so "identical" means identical bytes and
    not merely a matching listing.
    """
    source_tree = tree_summary(source)
    target_tree = tree_summary(target)

    only_in_source = sorted(set(source_tree) - set(target_tree))
    only_in_target = sorted(set(target_tree) - set(source_tree))
    differing = []

    for key in sorted(set(source_tree) & set(target_tree)):
        source_kind, source_size, source_relative = source_tree[key]
        target_kind, target_size, target_relative = target_tree[key]

        if source_kind != target_kind:
            differing.append(key)
            continue

        if source_kind != "file":
            # A directory's own st_size tracks its entry count, which says
            # nothing about whether its contents match; the entries are
            # compared on their own keys anyway.
            continue

        if source_size != target_size:
            differing.append(key)
            continue

        try:
            if file_digest(source / source_relative) != file_digest(
                target / target_relative
            ):
                differing.append(key)
        except OSError:
            differing.append(key)

    return only_in_source, only_in_target, differing


def classify_collision(source, target):
    """
    Work out whether a real target collision can be resolved by deleting
    the non-NFC source, and describe what was found.

    Returns (is_resolvable, detail_lines). The source is only reported as
    resolvable when every byte it holds is already present under the
    target, so that removing it cannot lose data.
    """
    try:
        source_stat = source.lstat()
        target_stat = target.lstat()
    except OSError as exc:
        return False, [f"  Cannot inspect: {exc}"]

    source_is_dir = stat.S_ISDIR(source_stat.st_mode)
    target_is_dir = stat.S_ISDIR(target_stat.st_mode)

    if source_is_dir != target_is_dir:
        return False, ["  One side is a directory and the other is a file."]

    if not source_is_dir:
        details = [
            f"  Both are files: FROM {source_stat.st_size} bytes, "
            f"TO {target_stat.st_size} bytes."
        ]

        if source_stat.st_size != target_stat.st_size:
            return False, details + ["  Sizes differ, so these are two different files."]

        try:
            identical = file_digest(source) == file_digest(target)
        except OSError as exc:
            return False, details + [f"  Cannot compare contents: {exc}"]

        if identical:
            return True, details + ["  Contents are identical."]

        return False, details + ["  Same size but different contents."]

    only_in_source, only_in_target, differing = compare_trees(source, target)

    details = [
        f"  Both are directories: "
        f"{len(only_in_source)} entries only in FROM, "
        f"{len(only_in_target)} only in TO, "
        f"{len(differing)} differing."
    ]

    for key in (only_in_source + differing)[:5]:
        details.append(f"    needs review: {key}")

    if only_in_source or differing:
        return False, details + ["  FROM holds data that TO does not."]

    if only_in_target:
        return True, details + ["  Everything in FROM is already in TO."]

    return True, details + ["  The two trees are identical."]


def verify_stored_name(target):
    """
    Confirm the filesystem really stored the NFC spelling after a rename.

    The macOS SMB and AFP clients decompose names on the wire, so a rename
    to NFC is accepted and then silently discarded: the entry keeps its
    decomposed name. Renaming under such a mount can never converge, so it
    is worth detecting on the first rename instead of after thousands.
    """
    try:
        entries = {entry.name for entry in target.parent.iterdir()}
    except OSError:
        return True

    return target.name in entries


def check_collisions(changes):
    """
    Detect cases where two source paths would end up with the same target
    path, or where the target already exists as a different filesystem
    object.

    Returns (errors, resolvable). A resolvable entry is a real collision
    whose source is fully redundant: every byte under it already exists
    under the target, so deleting the source resolves the collision
    without losing anything.
    """
    errors = []
    resolvable = []

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
        if not os.path.lexists(target):
            continue

        if target in change_sources:
            continue

        if is_same_object(source, target):
            continue

        is_resolvable, details = classify_collision(source, target)

        errors.append(
            "Target already exists:\n"
            f"  FROM: {source}\n"
            f"  TO:   {target}\n" + "\n".join(details)
        )

        if is_resolvable:
            resolvable.append((source, target))

    return errors, resolvable


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

    collisions, resolvable = check_collisions(changes)

    if collisions and not (resolvable and args.resolve_duplicates):
        print("ERROR: normalization collisions detected.")
        print()
        for error in collisions:
            print(error)
            print()

        if resolvable:
            print(
                f"{len(resolvable)} of these can be resolved automatically: "
                f"the non-NFC object is fully redundant. Re-run with "
                f"--resolve-duplicates to delete those sources."
            )
            print()

        print("No changes were made.")
        return 1

    if resolvable:
        blocking = len(collisions) - len(resolvable)

        if blocking:
            print("ERROR: normalization collisions detected.")
            print()
            for error in collisions:
                print(error)
                print()

            print(
                f"{blocking} collision(s) need manual resolution, so no "
                f"duplicates were deleted either."
            )
            print()
            print("No changes were made.")
            return 1

        print(f"Redundant non-NFC objects to delete: {len(resolvable)}")
        print()

        for source, target in resolvable:
            print("DELETE (already present under the NFC name):")
            print(f"  DELETE: {source}")
            print(f"  KEEPS:  {target}")
            print()

        if not args.apply:
            print("Dry run: no changes were made.")
            print()
            print("Run again with --apply to delete these and normalize the rest.")
            return 0

        for source, _ in resolvable:
            try:
                if source.is_dir() and not source.is_symlink():
                    shutil.rmtree(source)
                else:
                    source.unlink()
            except OSError as exc:
                print(
                    f"ERROR: failed to delete:\n  {source}\n  {exc}\n",
                    file=sys.stderr,
                )
                return 1

        print(f"Deleted {len(resolvable)} redundant object(s).")
        print()

        changes = find_changes(root)

        if not changes:
            print(f"No non-NFC names remain under: {root}")
            return 0

        collisions, resolvable = check_collisions(changes)

        if collisions:
            print("ERROR: collisions remain after deleting duplicates.")
            print()
            for error in collisions:
                print(error)
                print()

            print("No renames were made.")
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
    verified = False

    for source, target in changes:
        try:
            source.rename(target)
            renamed += 1

            if not verified:
                verified = True

                if not verify_stored_name(target):
                    print(
                        f"ERROR: the filesystem did not keep the NFC name:\n"
                        f"  {target}\n"
                        f"  It is still stored decomposed after a successful "
                        f"rename. The macOS SMB and AFP clients convert names "
                        f"to NFD on the wire, so names can never be normalized "
                        f"through such a mount. Run this script directly on the "
                        f"server, against the local path of the dataset.\n",
                        file=sys.stderr,
                    )
                    return 1
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
