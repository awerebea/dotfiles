#!/usr/bin/env bash
# Create symbolic links for all files with the given extension from the source
# directory in the destination directory with base name only (without extension)
# Optional arguments: $1 input dir, $2 output dir, $3 file extension

# Usage message
usage() {
    local MESSAGE=
    read -r -d '' MESSAGE <<__EOM__ || true
usage: ${0} [OPTIONS]

Create symbolic links for all files with the given extension from the source
directory in the destination directory with base name only (without extension)

OPTIONS:
  -s, --src     Source directory (Default value: $PWD).

  -d, --dst     Destination directory (Default value: source directory).

  -e, --ext     File extension (Default value: sh).


  -h, --help    Print this help message and exit
__EOM__
    echo "${MESSAGE}"
    return
}

# Define colors
RED='\e[1;31m'
GRN='\e[1;32m'
END='\e[0m' # No Color

# Check if the specified path exists and is a directory
function validate_path_d() {
    if [ ! -d "$1" ]; then
        echo "Path: ${RED}${1}${END} is not a valid directory" >&2
        exit 1
    fi
    return
}

# Short options that require a value. Used by the squash-expansion below to
# stop mid-token once one of these is hit: a value-taking short option
# consumes the rest of its token (or the next argv item, if nothing is
# left) as its value, and nothing after it is treated as more flags -- same
# GNU/POSIX convention as `tar -xvf file` (note -f must come last).
VALUE_OPTS="sde"

# Expand squashed short options into separate tokens so the parsing loop
# below can handle them one at a time, same as `ls -la`.
expanded=()
while [ $# -gt 0 ]; do
    case "$1" in
    --*)
        expanded+=("$1")
        ;;
    -?*)
        if [ "${#1}" -gt 2 ]; then
            chars="${1#-}"
            for ((i = 0; i < ${#chars}; i++)); do
                c="${chars:i:1}"
                expanded+=("-$c")
                case "$VALUE_OPTS" in
                *"$c"*)
                    rest="${chars:i+1}"
                    [ -n "$rest" ] && expanded+=("$rest")
                    break
                    ;;
                esac
            done
        else
            expanded+=("$1")
        fi
        ;;
    *)
        expanded+=("$1")
        ;;
    esac
    shift
done
set -- "${expanded[@]}"

# Process command line options
while [[ -n "$1" ]]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -s | --src | --src=*)
        if [ "$1" = "-s" ] || [ "$1" = "--src" ]; then
            shift
            SRC_DIR="$1"
            validate_path_d "${SRC_DIR}"
        else
            SRC_DIR=$(echo "$1" | cut -d '=' -f 2-)
            validate_path_d "${SRC_DIR}"
        fi
        ;;
    -d | --dst | --dst=*)
        if [ "$1" = "-d" ] || [ "$1" = "--dst" ]; then
            shift
            DST_DIR="$1"
            validate_path_d "${DST_DIR}"
        else
            DST_DIR=$(echo "$1" | cut -d '=' -f 2-)
            validate_path_d "${DST_DIR}"
        fi
        ;;
    -e | --ext | --ext=*)
        if [ "$1" = "-e" ] || [ "$1" = "--ext" ]; then
            shift
            EXT="$1"
        else
            EXT=$(echo "$1" | cut -d '=' -f 2-)
        fi
        ;;
    *)
        usage >&2
        exit 1
        ;;
    esac
    shift
done

# Main script
SRC_DIR=${SRC_DIR:-${PWD}}
DST_DIR=${DST_DIR:-${SRC_DIR}}
EXT=${EXT:-sh}
ARRAY=()
while IFS= read -r -d $'\0'; do
    ARRAY+=("$REPLY")
done < <(find "${SRC_DIR}" -type f -name "*.${EXT}" -print0)
for FILE in "${ARRAY[@]}"; do
    BASENAME=$(basename "${FILE}" ".${EXT}")
    ln -sf "${FILE}" "${DST_DIR}/${BASENAME}"
done

echo -e "All operations completed ${GRN}successfully${END}"
