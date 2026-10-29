#!/usr/bin/env bash
# Create symbolic links for all files with the given extension from the source
# directory in the destination directory with base name only (without extension)
# Optional arguments: $1 input dir, $2 output dir, $3 file extension

# Canonical program name for the version output (GNU: a constant, never
# derived from $0); usage and error messages use the invoked name instead.
readonly PROG_NAME="ln_for_ext.sh"
# Semantic version: MAJOR for breaking CLI or behavior changes, MINOR for new
# features, PATCH for fixes. Bump it with every change to this script.
readonly VERSION="1.0.0"

# Usage message
usage() {
    local MESSAGE=
    read -r -d '' MESSAGE <<__EOM__ || true
${PROG_NAME} ${VERSION}
usage: ${0} [OPTIONS]

Create symbolic links for all files with the given extension from the source
directory in the destination directory with base name only (without extension)

OPTIONS:
  -s, --src     Source directory (Default value: $PWD).

  -d, --dst     Destination directory (Default value: source directory).

  -e, --ext     File extension (Default value: sh).


  -h, --help    Print this help message and exit
      --version Print the version and exit
__EOM__
    echo "${MESSAGE}"
    return
}

# Define colors
RED='\e[1;31m'
GRN='\e[1;32m'
END='\e[0m' # No Color

# Exit with an error if option $1 has no value ($2: number of arguments left)
function require_value() {
    if [ "$2" -lt 2 ]; then
        echo "Option '$1' requires a value" >&2
        usage >&2
        exit 1
    fi
    return
}

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
take_value=0
while [ $# -gt 0 ]; do
    if [ "$take_value" -eq 1 ]; then
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
                if [ -n "$rest" ]; then
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

# Process command line options
while [ $# -gt 0 ]; do
    case "$1" in
    --version)
        printf '%s %s\n' "$PROG_NAME" "$VERSION"
        exit 0
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -s | --src | --src=*)
        if [ "$1" = "-s" ] || [ "$1" = "--src" ]; then
            require_value "$1" "$#"
            shift
            SRC_DIR="$1"
        else
            SRC_DIR="${1#*=}"
        fi
        validate_path_d "${SRC_DIR}"
        ;;
    -d | --dst | --dst=*)
        if [ "$1" = "-d" ] || [ "$1" = "--dst" ]; then
            require_value "$1" "$#"
            shift
            DST_DIR="$1"
        else
            DST_DIR="${1#*=}"
        fi
        validate_path_d "${DST_DIR}"
        ;;
    -e | --ext | --ext=*)
        if [ "$1" = "-e" ] || [ "$1" = "--ext" ]; then
            require_value "$1" "$#"
            shift
            EXT="$1"
        else
            EXT="${1#*=}"
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
