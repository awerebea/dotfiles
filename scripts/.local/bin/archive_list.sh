#!/usr/bin/env bash
# Backup and restore files while syncyng the same OS between devices

# Canonical program name for the version output (GNU: a constant, never
# derived from $0); usage and error messages use the invoked name instead.
readonly PROG_NAME="archive_list.sh"
# Semantic version: MAJOR for breaking CLI or behavior changes, MINOR for new
# features, PATCH for fixes. Bump it with every change to this script.
readonly VERSION="1.0.0"

# Generate default file list
TMP_FILE=$(mktemp)
cat <<-EOF >"${TMP_FILE}"
/etc/autofs
/etc/autofs.conf
/etc/exports
/etc/fstab
/etc/hostname
/etc/hosts
/etc/samba/smb.conf
EOF

# Define global variables
SRC_PATH=
DST_PATH=
FILE_LIST=

# Define colors
RED='\e[1;31m'
GRN='\e[1;32m'
END='\e[0m' # No Color

# Clean up environment and exit
function clean_and_exit() {
    unset FILE_LIST TMP_FILE SRC_PATH DST_PATH GRN RED END
    exit "${1}"
}

# Exit on error
error_quit() {
    echo -e "Snapshot ${RED}failed${END}"
    clean_and_exit 1
}

# Usage message
usage() {
    local MESSAGE=
    read -r -d '' MESSAGE <<__EOM__ || true
${PROG_NAME} ${VERSION}
usage: ${0} [list] src=root/of/filelist dst=target/path

Archive files from the file list from the src root prefix to the dst path.

  list          Path to the list of files for the archive.
                If not specified, the default list is used.

  src           Root directory (prefix) for entries from the file list.

  dst           The path where to archive files.


  -h, --help    Print this help message and exit
      --version Print the version and exit
__EOM__
    echo "${MESSAGE}"
    return
}

# Exit with an error if option $1 has no value ($2: number of arguments left)
function require_value() {
    if [ "$2" -lt 2 ]; then
        echo "Option '$1' requires a value" >&2
        usage >&2
        clean_and_exit 1
    fi
    return
}

# Check if the specified path exists and is a directory
function validate_path_d() {
    if [ ! -d "$1" ]; then
        echo "Path: ${RED}${1}${END} is not a valid directory" >&2
        clean_and_exit 1
    fi
    return
}

# Check if the specified path exists and is a regular file
function validate_path_f() {
    if [ ! -f "$1" ]; then
        echo "Path: ${RED}${1}${END} is not a valid file" >&2
        clean_and_exit 1
    fi
    return
}

# Process command line options
while [ $# -gt 0 ]; do
    case "$1" in
        --version)
            printf '%s %s\n' "$PROG_NAME" "$VERSION"
            clean_and_exit 0
            ;;
        -h | --help)
            usage
            clean_and_exit 0
            ;;
        src | src=* | source | source=*)
            if [ "$1" = "src" ] || [ "$1" = "source" ]; then
                require_value "$1" "$#"
                shift
                SRC_PATH="$1"
            else
                SRC_PATH="${1#*=}"
            fi
            validate_path_d "${SRC_PATH}"
            ;;
        dst | dst=* | dest | dest=* | destination | destination=*)
            if [ "$1" = "dst" ] || [ "$1" = "dest" ] || [ "$1" = "destination" ]; then
                require_value "$1" "$#"
                shift
                DST_PATH="$1"
            else
                DST_PATH="${1#*=}"
            fi
            validate_path_d "${DST_PATH}"
            ;;
        list | list=*)
            if [ "$1" = "list" ]; then
                require_value "$1" "$#"
                shift
                FILE_LIST="$1"
            else
                FILE_LIST="${1#*=}"
            fi
            validate_path_f "${FILE_LIST}"
            ;;
        *)
            usage >&2
            clean_and_exit 1
            ;;
    esac
    shift
done

# Check if paths are specified
if [[ -z "${SRC_PATH}" ]] || [[ -z "${DST_PATH}" ]]; then
    usage >&2
    error_quit
fi

# The function requires 3 arguments: file list, source root, destination path.
sync() {
    # Synchronize files from the list to the target directory
    sudo rsync --archive --verbose --recursive --stats --sparse \
        --files-from="${1}" \
        "${2}/" "${3}/" || error_quit
    echo -e "Archiving completed ${GRN}successfully${END}"
    return
}

sync "${FILE_LIST:-${TMP_FILE}}" "${SRC_PATH}/" "${DST_PATH}/"
rm "${TMP_FILE}"
