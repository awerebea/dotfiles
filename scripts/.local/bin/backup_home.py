#!/usr/bin/env python3
"""backup_home.py - thin wrapper around backup_snapshot.py for the home directory.

All options of backup_snapshot.py are accepted and override the defaults set
here, because later arguments win. To back up the home directory without the
built-in exclude list, pass --exclude-preset=none.
"""

from __future__ import annotations

import sys
from collections.abc import Sequence
from pathlib import Path

# The real directory of this file, so that the import also works when the
# script is started through a symlink (e.g. from ~/.local/bin)
sys.path.insert(0, str(Path(__file__).resolve().parent))

import backup_snapshot

DEFAULT_SOURCE = "/home/andrei"
DEFAULT_DEST = "/media/andrei/bckp/home_backup"


def main(argv: Sequence[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    defaults = [
        f"--source={DEFAULT_SOURCE}",
        f"--dest={DEFAULT_DEST}",
        "--exclude-preset=home",
    ]
    return backup_snapshot.main([*defaults, *argv])


if __name__ == "__main__":
    sys.exit(main())
