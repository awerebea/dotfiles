#!/usr/bin/env bash
# Save the current name of each media file into the XMP-xmpMM:PreservedFileName
# tag of its XMP sidecar, or read that tag back from all sidecars in a path.

# Usage message
usage() {
    local MESSAGE=
    read -r -d '' MESSAGE <<__EOM__ || true
usage: ${0##*/} <COMMAND> [OPTIONS]

Save the current name of each media file into the XMP-xmpMM:PreservedFileName
tag of its XMP sidecar, or read that tag back. XMP files are searched
recursively in the given path.

COMMANDS:
  save            Write the media file name to the tag of every sidecar that
                  does not have it yet. Existing values are never overwritten.

  read            Print the path, the current media file name and the name
                  preserved in the tag for every sidecar.

OPTIONS:
  -p, --path      Directory to process (Default value: .).

  -d, --dry-run   Show what 'save' would write without changing any file.

  -h, --help      Print this help message and exit
__EOM__
    echo "${MESSAGE}"
    return
}

# Define colors
RED='\e[1;31m'
GRN='\e[1;32m'
YEL='\e[1;33m'
END='\e[0m' # No Color

TAG="XMP-xmpMM:PreservedFileName"
# Placeholder exiftool prints for a missing tag in tabular output
MISSING="<none>"

# Check if the specified path exists and is a directory
function validate_path_d() {
    if [ ! -d "$1" ]; then
        echo -e "Path: ${RED}${1}${END} is not a valid directory" >&2
        exit 1
    fi
    return
}

# Print the name of the media file that belongs to the given sidecar.
# Sidecars named "name.ext.xmp" map to "name.ext"; sidecars named "name.xmp"
# map to the only non-XMP file "name.*" next to them. Returns 1 when there is
# no such file, 2 when the match is ambiguous.
function resolve_media() {
    local XMP="$1"
    local BASE="${XMP%.*}"
    local CANDIDATES=()
    local FILE

    if [ -f "${BASE}" ]; then
        echo "${BASE##*/}"
        return 0
    fi
    shopt -s nullglob
    for FILE in "${BASE}".*; do
        [ "${FILE}" = "${XMP}" ] && continue
        [[ "${FILE,,}" == *.xmp ]] && continue
        CANDIDATES+=("${FILE}")
    done
    shopt -u nullglob
    case "${#CANDIDATES[@]}" in
    0) return 1 ;;
    1) echo "${CANDIDATES[0]##*/}" ;;
    *) return 2 ;;
    esac
    return 0
}

# Print rows of tab-separated fields as columns aligned to the longest value.
# Widths are counted in characters, so non-ASCII names stay aligned.
function print_table() {
    local ROWS=()
    local WIDTHS=()
    local ROW FIELDS i PAD

    while IFS= read -r ROW; do
        ROWS+=("${ROW}")
        IFS=$'\t' read -r -a FIELDS <<<"${ROW}"
        for ((i = 0; i < ${#FIELDS[@]}; i++)); do
            [ "${#FIELDS[i]}" -gt "${WIDTHS[i]:-0}" ] && WIDTHS[i]=${#FIELDS[i]}
        done
    done
    for ROW in "${ROWS[@]}"; do
        IFS=$'\t' read -r -a FIELDS <<<"${ROW}"
        for ((i = 0; i < ${#FIELDS[@]}; i++)); do
            if [ "${i}" -eq $((${#FIELDS[@]} - 1)) ]; then
                printf '%s\n' "${FIELDS[i]}"
            else
                PAD=$((WIDTHS[i] - ${#FIELDS[i]} + 2))
                printf '%s%*s' "${FIELDS[i]}" "${PAD}" ""
            fi
        done
    done
    return
}

# Print "directory<TAB>sidecar name<TAB>tag value" for every sidecar in the
# root, sorted by path
function scan_sidecars() {
    exiftool -r -ext xmp -q -q -m -T -api "MissingTagValue=${MISSING}" \
        -Directory -FileName "-${TAG}" "${ROOT}" | sort
    return "${PIPESTATUS[0]}"
}

# Print the directory relative to the root, "." for the root itself
function relative_dir() {
    local REL="${1#"${ROOT}"}"
    REL="${REL#/}"
    echo "${REL:-.}"
    return
}

# Show the current and the preserved name of every sidecar
function cmd_read() {
    local DIR XMP VALUE MEDIA TOTAL=0 UNSET=0

    {
        printf 'PATH\tCURRENT NAME\tPRESERVED NAME\n'
        while IFS=$'\t' read -r DIR XMP VALUE; do
            TOTAL=$((TOTAL + 1))
            MEDIA=$(resolve_media "${DIR}/${XMP}")
            case "$?" in
            0) ;;
            1) MEDIA="${XMP%.*} (no media file)" ;;
            *) MEDIA="${XMP%.*} (ambiguous media file)" ;;
            esac
            if [ "${VALUE}" = "${MISSING}" ]; then
                VALUE="-"
                UNSET=$((UNSET + 1))
            fi
            printf '%s\t%s\t%s\n' "$(relative_dir "${DIR}")" "${MEDIA}" "${VALUE}"
        done < <(scan_sidecars)
        echo "${TOTAL} ${UNSET}" >"${COUNTS}"
    } | print_table
    read -r TOTAL UNSET <"${COUNTS}"
    echo
    echo -e "Sidecars: ${TOTAL}, with tag: $((TOTAL - UNSET)), ${YEL}without tag: ${UNSET}${END}"
    return
}

# Write the media file name to every sidecar that does not have the tag yet
function cmd_save() {
    local DIR XMP VALUE MEDIA STATUS
    local TODO=0 SKIPPED=0 KEPT=0 RC=0

    : >"${ARGFILE}"
    {
        printf 'PATH\tSIDECAR\tNAME TO PRESERVE\n'
        while IFS=$'\t' read -r DIR XMP VALUE; do
            if [ "${VALUE}" != "${MISSING}" ]; then
                KEPT=$((KEPT + 1))
                continue
            fi
            MEDIA=$(resolve_media "${DIR}/${XMP}")
            STATUS=$?
            case "${STATUS}" in
            0)
                TODO=$((TODO + 1))
                printf -- '-%s=%s\n%s\n-execute\n' "${TAG}" "${MEDIA}" "${DIR}/${XMP}" >>"${ARGFILE}"
                ;;
            1) MEDIA="- (skipped: no media file)" ;;
            *) MEDIA="- (skipped: ambiguous media file)" ;;
            esac
            [ "${STATUS}" -ne 0 ] && SKIPPED=$((SKIPPED + 1))
            printf '%s\t%s\t%s\n' "$(relative_dir "${DIR}")" "${XMP}" "${MEDIA}"
        done < <(scan_sidecars)
        echo "${TODO} ${SKIPPED} ${KEPT}" >"${COUNTS}"
    } | print_table
    read -r TODO SKIPPED KEPT <"${COUNTS}"
    echo

    if [ "${DRY_RUN}" = true ]; then
        echo -e "${YEL}Dry run:${END} ${TODO} to save, ${SKIPPED} skipped, ${KEPT} already set"
        return
    fi
    if [ "${TODO}" -gt 0 ]; then
        # -if guards against overwriting a value set since the scan; exit code 2
        # only means some files did not pass that condition. "length" is used
        # instead of "defined" because -m turns missing tags into empty strings
        exiftool -@ "${ARGFILE}" -common_args -q -q -m -P -overwrite_original \
            -if "not length \$${TAG}" || RC=$?
        if [ "${RC}" -ne 0 ] && [ "${RC}" -ne 2 ]; then
            echo -e "${RED}exiftool failed with exit code ${RC}${END}" >&2
            exit 1
        fi
    fi
    echo -e "${GRN}Saved: ${TODO}${END}, skipped: ${SKIPPED}, already set: ${KEPT}"
    return
}

# Short options that require a value. Used by the squash-expansion below to
# stop mid-token once one of these is hit: a value-taking short option
# consumes the rest of its token (or the next argv item, if nothing is
# left) as its value, and nothing after it is treated as more flags -- same
# GNU/POSIX convention as `tar -xvf file` (note -f must come last).
VALUE_OPTS="p"

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
    -p | --path | --path=*)
        if [ "$1" = "-p" ] || [ "$1" = "--path" ]; then
            shift
            ROOT="$1"
        else
            ROOT=$(echo "$1" | cut -d '=' -f 2-)
        fi
        validate_path_d "${ROOT}"
        ;;
    -d | --dry-run)
        DRY_RUN=true
        ;;
    save | read)
        if [ -n "${COMMAND}" ]; then
            usage >&2
            exit 1
        fi
        COMMAND="$1"
        ;;
    *)
        usage >&2
        exit 1
        ;;
    esac
    shift
done

# Main script
if [ -z "${COMMAND}" ]; then
    usage >&2
    exit 1
fi
if ! command -v exiftool >/dev/null 2>&1; then
    echo -e "${RED}exiftool${END} is not installed" >&2
    exit 1
fi
ROOT=${ROOT:-.}
# Strip trailing slashes so relative paths are computed consistently
[ "${ROOT}" != "/" ] && ROOT="${ROOT%"${ROOT##*[!/]}"}"
DRY_RUN=${DRY_RUN:-false}
ARGFILE=$(mktemp)
COUNTS=$(mktemp)
trap 'rm -f "${ARGFILE}" "${COUNTS}"' EXIT

case "${COMMAND}" in
save) cmd_save ;;
read) cmd_read ;;
esac
