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
  write           Write the media file name to the tag of every sidecar that
                  does not have it yet. Existing values are kept unless
                  --overwrite is given.

  read            Print the path, the current media file name and the name
                  preserved in the tag for every sidecar.

OPTIONS:
  -p, --path      Directory to process (Default value: .).

  -o, --overwrite With 'write', also replace existing values that differ from
                  the current media file name. Each one is shown with its old
                  and new value and needs confirmation: [y]es, [N]o or [a]ll.

  -y, --yes       With --overwrite, replace without asking. Old and new values
                  are still printed, so they can be restored.

  -d, --dry-run   Show what 'write' would change without modifying any file.

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
    local DIR XMP VALUE MEDIA
    local ROWS=()
    local TOTAL=0 UNSET=0

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
        ROWS+=("$(relative_dir "${DIR}")"$'\t'"${MEDIA}"$'\t'"${VALUE}")
    done < <(scan_sidecars)

    {
        printf 'PATH\tCURRENT NAME\tPRESERVED NAME\n'
        [ "${#ROWS[@]}" -gt 0 ] && printf '%s\n' "${ROWS[@]}"
    } | print_table
    echo
    echo -e "Sidecars: ${TOTAL}, with tag: $((TOTAL - UNSET)), ${YEL}without tag: ${UNSET}${END}"
    return
}

# Ask on the terminal whether to overwrite one existing value. Returns 0 for
# yes; "all" also sets OVERWRITE_ALL so the remaining values are replaced
# without asking. Without a terminal the answer is no.
function confirm_overwrite() {
    local ANSWER=

    if [ "${OVERWRITE_ALL}" = true ]; then
        return 0
    fi
    if ! (: </dev/tty) 2>/dev/null; then
        echo -e "${YEL}WRN:${END} no terminal to confirm, keeping the value (use --yes)" >&2
        return 1
    fi
    printf 'Overwrite? [y]es/[N]o/[a]ll: ' >/dev/tty
    read -r ANSWER </dev/tty
    case "${ANSWER,,}" in
    y | yes)
        return 0
        ;;
    a | all)
        OVERWRITE_ALL=true
        return 0
        ;;
    esac
    return 1
}

# Write the media file name to every sidecar that does not have the tag yet,
# and with --overwrite replace values that differ from the current name
function cmd_write() {
    local DIR XMP VALUE MEDIA STATUS i
    local ROWS=() C_FILE=() C_SHOW=() C_OLD=() C_NEW=()
    local TODO=0 SKIPPED=0 KEPT=0 DIFFER=0 REPLACED=0 RC=0

    : >"${ARGFILE}"
    while IFS=$'\t' read -r DIR XMP VALUE; do
        MEDIA=$(resolve_media "${DIR}/${XMP}")
        STATUS=$?
        if [ "${VALUE}" != "${MISSING}" ]; then
            if [ "${STATUS}" -eq 0 ] && [ "${MEDIA}" != "${VALUE}" ]; then
                DIFFER=$((DIFFER + 1))
                if [ "${OVERWRITE}" = true ]; then
                    C_FILE+=("${DIR}/${XMP}")
                    C_SHOW+=("${DIR#"${ROOT}"}/${XMP}")
                    C_SHOW[-1]="${C_SHOW[-1]#/}"
                    C_OLD+=("${VALUE}")
                    C_NEW+=("${MEDIA}")
                    continue
                fi
            fi
            KEPT=$((KEPT + 1))
            continue
        fi
        case "${STATUS}" in
        0)
            TODO=$((TODO + 1))
            # -if guards against overwriting a value set since the scan.
            # "length" is used instead of "defined" because -m turns missing
            # tags into empty strings
            printf -- '-if\nnot length $%s\n-%s=%s\n%s\n-execute\n' \
                "${TAG}" "${TAG}" "${MEDIA}" "${DIR}/${XMP}" >>"${ARGFILE}"
            ;;
        1) MEDIA="- (skipped: no media file)" ;;
        *) MEDIA="- (skipped: ambiguous media file)" ;;
        esac
        [ "${STATUS}" -ne 0 ] && SKIPPED=$((SKIPPED + 1))
        ROWS+=("$(relative_dir "${DIR}")"$'\t'"${XMP}"$'\t'"${MEDIA}")
    done < <(scan_sidecars)

    if [ "${#ROWS[@]}" -gt 0 ]; then
        {
            printf 'PATH\tSIDECAR\tNAME TO PRESERVE\n'
            printf '%s\n' "${ROWS[@]}"
        } | print_table
        echo
    fi

    # Existing values that differ: always shown with old and new value, so
    # a replaced value can be restored from the output
    for ((i = 0; i < ${#C_FILE[@]}; i++)); do
        echo -e "${YEL}WRN:${END} ${C_SHOW[i]}: tag is '${C_OLD[i]}', current name is '${C_NEW[i]}'" >&2
        if [ "${DRY_RUN}" = true ]; then
            REPLACED=$((REPLACED + 1))
        elif [ "${ASSUME_YES}" = true ] || confirm_overwrite; then
            echo "  overwriting '${C_OLD[i]}' -> '${C_NEW[i]}'" >&2
            printf -- '-%s=%s\n%s\n-execute\n' \
                "${TAG}" "${C_NEW[i]}" "${C_FILE[i]}" >>"${ARGFILE}"
            REPLACED=$((REPLACED + 1))
        else
            echo "  kept '${C_OLD[i]}'" >&2
            KEPT=$((KEPT + 1))
        fi
    done
    [ "${#C_FILE[@]}" -gt 0 ] && echo >&2

    if [ "${DRY_RUN}" = true ]; then
        echo -e "${YEL}Dry run:${END} ${TODO} to write, ${REPLACED} to overwrite, ${SKIPPED} skipped, ${KEPT} already set"
    else
        if [ -s "${ARGFILE}" ]; then
            # Exit code 2 only means some files did not pass an -if condition
            exiftool -@ "${ARGFILE}" -common_args -q -q -m -P -overwrite_original || RC=$?
            if [ "${RC}" -ne 0 ] && [ "${RC}" -ne 2 ]; then
                echo -e "${RED}exiftool failed with exit code ${RC}${END}" >&2
                exit 1
            fi
        fi
        echo -e "${GRN}Written: ${TODO}${END}, overwritten: ${REPLACED}, skipped: ${SKIPPED}, already set: ${KEPT}"
    fi
    if [ "${OVERWRITE}" != true ] && [ "${DIFFER}" -gt 0 ]; then
        echo -e "${YEL}WRN:${END} ${DIFFER} existing value(s) differ from the current name, use --overwrite to review them" >&2
    fi
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
    -h | --help)
        usage
        exit 0
        ;;
    -p | --path | --path=*)
        if [ "$1" = "-p" ] || [ "$1" = "--path" ]; then
            require_value "$1" "$#"
            shift
            ROOT="$1"
        else
            ROOT="${1#*=}"
        fi
        validate_path_d "${ROOT}"
        ;;
    -o | --overwrite)
        OVERWRITE=true
        ;;
    -y | --yes)
        ASSUME_YES=true
        ;;
    -d | --dry-run)
        DRY_RUN=true
        ;;
    write | read)
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
OVERWRITE=${OVERWRITE:-false}
ASSUME_YES=${ASSUME_YES:-false}
OVERWRITE_ALL=false
if [ "${ASSUME_YES}" = true ] && [ "${OVERWRITE}" != true ]; then
    echo -e "${RED}--yes${END} only makes sense together with --overwrite" >&2
    exit 1
fi
ARGFILE=$(mktemp)
trap 'rm -f "${ARGFILE}"' EXIT

case "${COMMAND}" in
write) cmd_write ;;
read) cmd_read ;;
esac
