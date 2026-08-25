#!/usr/bin/env bash
# backup_home.sh - thin wrapper around backup_snapshot.sh for the home directory.
#
# All options of backup_snapshot.sh are accepted and override the defaults set
# here, because later arguments win. To back up the home directory without the
# built-in exclude list, pass --exclude-preset=none.

set -euo pipefail

DEFAULT_SOURCE="/home/andrei"
DEFAULT_DEST="/media/andrei/bckp/home_backup"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backup_snapshot="${script_dir}/backup_snapshot.sh"

if [[ ! -x "$backup_snapshot" ]]; then
    if ! backup_snapshot="$(command -v backup_snapshot.sh)"; then
        echo "ERR: backup_snapshot.sh not found next to $0 or in PATH" >&2
        exit 1
    fi
fi

exec "$backup_snapshot" \
    --source="$DEFAULT_SOURCE" \
    --dest="$DEFAULT_DEST" \
    --exclude-preset=home \
    "$@"
