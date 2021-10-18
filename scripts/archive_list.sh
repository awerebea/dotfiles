#!/usr/bin/env bash
# Backup and restore files while syncyng the same OS between devices


# Generate default file list
TMP_FILE=$(mktemp)
cat <<- EOF > "${TMP_FILE}"
/etc/autofs
/etc/autofs.conf
/etc/exports
/etc/fstab
/etc/hostname
/etc/hosts
/etc/samba/smb.conf
EOF


# Setup colors
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_DFLT='\033[0m' # No Color


# Usage message
usage () {
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__ || true
usage: ${0} [list] src=root/of/filelist dst=target/path

Archive files from the file list from the src root prefix to the dst path.

  list          List of files to archive.
                If not specified, the default list is used.

  src           Root directory (prefix) for entries from the file list.

  dst           The path where to archive files.


  -h, --help    Print this help message and exit
__EOM__
    echo "${MESSAGE}"
    return
}


# Command line options variables
SRC_PATH=
DST_PATH=


# Check if the specified path exists and is a directory
function validate_path() {
    if [ ! -d "$1" ]; then
        echo "Path: ${COLOR_RED}${1}${COLOR_DFLT} is not a valid directory" >&2
        exit 1
    fi
    return
}


# Process command line options
while [[ -n "$1" ]]; do
    case "$1" in
    -h | --help)
        usage
        exit
        ;;
    src | src=* | source | source=*)
        if [ "$1" = "src" ] || [ "$1" = "source" ]; then
            shift
            SRC_PATH="$1"
            validate_path "${SRC_PATH}"
        else
            SRC_PATH=$(echo "$1" | cut -d '=' -f 2-)
            validate_path "${SRC_PATH}"
        fi
        ;;
    dst | dst=* | dest | dest=* | destination | destination=*)
        if [ "$1" = "dst" ] || [ "$1" = "dest" ] || [ "$1" = "destination" ]
        then
            shift
            DST_PATH="$1"
            validate_path "${DST_PATH}"
        else
            DST_PATH=$(echo "$1" | cut -d '=' -f 2-)
            validate_path "${DST_PATH}"
        fi
        ;;
    *)
        usage >&2
        exit 1
        ;;
    esac
    shift
done


# Check if paths are specified
if [[ -z "${SRC_PATH}" ]] || [[ -z "${DST_PATH}" ]]; then
    usage >&2
    error_quit
fi


# Exit on error
error_quit() {
    echo -e "Snapshot ${COLOR_RED}failed${COLOR_DFLT}"
    exit 1
}


# The function requires 3 arguments: file list, source root, destination path.
sync() {
    # Synchronize files from the list to the target directory
    sudo rsync --archive --verbose --recursive --stats --sparse \
        --files-from="${1}" \
        "${2}/" "${3}/" || error_quit
    echo -e "Archiving completed ${COLOR_GREEN}successfully${COLOR_DFLT}"
    return
}

sync "${FILE_LIST:-${TMP_FILE}}" "${SRC_PATH}/" "${DST_PATH}/"
rm "${TMP_FILE}"

# Unset global variables
unset TMP_FILE SRC_PATH DST_PATH COLOR_GREEN COLOR_RED COLOR_DFLT
