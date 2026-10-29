#!/usr/bin/env bash
set -euo pipefail

usage() {
    local MESSAGE
    read -r -d '' MESSAGE <<__EOM__ || true
Usage:
  ${0} <download|upload> [OPTIONS]

Options:
  -f, --temp-file FILE             Local file path (required)
  -r, --remote HOST                SSH host or alias (required)
  -s, --sync-destination DIR       Remote directory for the main file (required)
  -b, --backup-destination DIR     Remote directory for timestamped backups (optional)
  -n, --db-name NAME               Database filename (required)
  -h, --help                       Print this help message and exit

Short options can be combined. Options requiring values consume the remainder
of the same token, if any, or the next argument.

Examples:

  Upload with timestamped backup:
    ${0} upload \\
      --temp-file ./keepass_Andrei.kdbx \\
      --remote truenas \\
      --sync-destination /mnt/tank/backups/KeePass \\
      --backup-destination /mnt/tank/backups/KeePass/Backup \\
      --db-name keepass_Andrei.kdbx

  Upload without backup:
    ${0} upload \\
      -f ./keepass_Andrei.kdbx \\
      -r truenas \\
      -s /mnt/tank/backups/KeePass \\
      -n keepass_Andrei.kdbx

  Download the main database:
    ${0} download \\
      -f ./keepass_Andrei.kdbx \\
      -r truenas \\
      -s /mnt/tank/backups/KeePass \\
      -n keepass_Andrei.kdbx

  Show this help:
    ${0} --help
__EOM__
    printf '%s\n' "$MESSAGE"
}

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 1
fi

COMMAND=$1
shift

if [[ "$COMMAND" != "download" && "$COMMAND" != "upload" ]]; then
    echo "Error: Command must be 'download' or 'upload'." >&2
    usage >&2
    exit 1
fi

# Short options that require a value.
VALUE_OPTS="frsbn"

# Expand combined short options.
expanded=()
take_value=0
while [[ $# -gt 0 ]]; do
    if [[ "$take_value" -eq 1 ]]; then
        # Value of the previous option: keep it as-is, even if it starts
        # with '-'
        expanded+=("$1")
        take_value=0
        shift
        continue
    fi
    case "$1" in
    --)
        # End of options: keep everything after it untouched
        expanded+=("$@")
        break
        ;;
    --*)
        expanded+=("$1")
        ;;
    -?*)
        chars="${1#-}"
        for ((i = 0; i < ${#chars}; i++)); do
            c="${chars:i:1}"
            expanded+=("-$c")
            case "$VALUE_OPTS" in
            *"$c"*)
                rest="${chars:i+1}"
                if [[ -n "$rest" ]]; then
                    expanded+=("$rest")
                else
                    take_value=1
                fi
                break
                ;;
            esac
        done
        ;;
    *)
        expanded+=("$1")
        ;;
    esac
    shift
done
set -- "${expanded[@]}"

TEMP_FILE=""
REMOTE=""
SYNC_DESTINATION=""
BACKUP_DESTINATION=""
DB_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;

    -f | --temp-file | --temp-file=*)
        if [[ "$1" == "-f" || "$1" == "--temp-file" ]]; then
            [[ $# -ge 2 ]] || {
                echo "Error: $1 requires a value." >&2
                exit 1
            }
            TEMP_FILE=$2
            shift
        else
            TEMP_FILE=${1#*=}
        fi
        ;;

    -r | --remote | --remote=*)
        if [[ "$1" == "-r" || "$1" == "--remote" ]]; then
            [[ $# -ge 2 ]] || {
                echo "Error: $1 requires a value." >&2
                exit 1
            }
            REMOTE=$2
            shift
        else
            REMOTE=${1#*=}
        fi
        ;;

    -s | --sync-destination | --sync-destination=*)
        if [[ "$1" == "-s" || "$1" == "--sync-destination" ]]; then
            [[ $# -ge 2 ]] || {
                echo "Error: $1 requires a value." >&2
                exit 1
            }
            SYNC_DESTINATION=$2
            shift
        else
            SYNC_DESTINATION=${1#*=}
        fi
        ;;

    -b | --backup-destination | --backup-destination=*)
        if [[ "$1" == "-b" || "$1" == "--backup-destination" ]]; then
            [[ $# -ge 2 ]] || {
                echo "Error: $1 requires a value." >&2
                exit 1
            }
            BACKUP_DESTINATION=$2
            shift
        else
            BACKUP_DESTINATION=${1#*=}
        fi
        ;;

    -n | --db-name | --db-name=*)
        if [[ "$1" == "-n" || "$1" == "--db-name" ]]; then
            [[ $# -ge 2 ]] || {
                echo "Error: $1 requires a value." >&2
                exit 1
            }
            DB_NAME=$2
            shift
        else
            DB_NAME=${1#*=}
        fi
        ;;

    *)
        echo "Error: Unknown argument: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
done

# Validate required arguments.
if [[ -z "$TEMP_FILE" || -z "$REMOTE" ||
    -z "$SYNC_DESTINATION" || -z "$DB_NAME" ]]; then
    echo "Error: --temp-file, --remote, --sync-destination and --db-name are required." >&2
    usage >&2
    exit 1
fi

# DB_NAME must be a filename, not a path.
if [[ "$DB_NAME" == */* || "$DB_NAME" == "." || "$DB_NAME" == ".." ]]; then
    echo "Error: --db-name must be a filename, not a path." >&2
    exit 1
fi

REMOTE_FILE="${SYNC_DESTINATION%/}/$DB_NAME"

ensure_remote_dir() {
    local dir=$1
    ssh "$REMOTE" mkdir -p -- "$dir"
}

case "$COMMAND" in
upload)
    if [[ ! -f "$TEMP_FILE" ]]; then
        echo "Error: Local file not found: $TEMP_FILE" >&2
        exit 1
    fi

    # Ensure remote destination directories exist.
    ensure_remote_dir "$SYNC_DESTINATION"

    if [[ -n "$BACKUP_DESTINATION" ]]; then
        ensure_remote_dir "$BACKUP_DESTINATION"
    fi

    # Upload the main database.
    scp -- "$TEMP_FILE" "$REMOTE:$REMOTE_FILE"
    echo "Uploaded: $REMOTE_FILE"

    # Optionally upload a timestamped backup.
    if [[ -n "$BACKUP_DESTINATION" ]]; then
        TIMESTAMP=$(date +%Y%m%d%H%M%S)

        if [[ "$DB_NAME" == *.* && "$DB_NAME" != .* ]]; then
            BACKUP_NAME="${DB_NAME%.*}_${TIMESTAMP}.${DB_NAME##*.}"
        else
            BACKUP_NAME="${DB_NAME}_${TIMESTAMP}"
        fi

        REMOTE_BACKUP="${BACKUP_DESTINATION%/}/$BACKUP_NAME"

        scp -- "$TEMP_FILE" "$REMOTE:$REMOTE_BACKUP"
        echo "Backup uploaded: $REMOTE_BACKUP"
    fi
    ;;

download)
    # Ensure the local destination directory exists.
    LOCAL_DIR=$(dirname "$TEMP_FILE")
    mkdir -p -- "$LOCAL_DIR"

    scp -- "$REMOTE:$REMOTE_FILE" "$TEMP_FILE"
    echo "Downloaded: $REMOTE_FILE -> $TEMP_FILE"
    ;;
esac
