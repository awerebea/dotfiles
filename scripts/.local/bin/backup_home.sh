#!/usr/bin/env bash

trap cleanup INT TERM

# Define global variables
readonly SOURCE_PATH="/home/andrei"
readonly SNAPSHOT_PATH="/media/andrei/bckp/home_backup"

# Name of the subdirectory in the snapshot directory to save the data
readonly DATA_DIR_NAME="home"

# Names of generated files
readonly LOG_FILENAME="rsync-log"
readonly SUCCESS_FILE="completed_successfully"

# Define colors
readonly COL_RESET='\033[0m'
readonly COL_R='\033[31m'
readonly COL_G='\033[32m'
readonly COL_Y='\033[33m'
# readonly COL_B='\033[34m'
# readonly COL_M='\033[35m'
# readonly COL_BOLD='\033[1m'
# readonly COL_R_BOLD='\033[1;31m'
# readonly COL_G_BOLD='\033[1;32m'
# readonly COL_Y_BOLD='\033[1;33m'
# readonly COL_B_BOLD='\033[1;34m'

# Snapshot name pattern
# shellcheck disable=2155
readonly SNAPSHOT_NAME=$(date +%Y-%m-%d_%H-%M-%S)
# Just a split of too long line)
readonly SNAPSHOT_NAME_PATTERN="^${SNAPSHOT_PATH}/\
20([0-9]{2})-(0[1-9]|1[0-2])-\
(0[1-9]|[1-2][0-9]|3[0-1])_(0[0-9]|1[0-9]|2[0-3])-\
([0-5][0-9])-([0-5][0-9])$"

# Default values that can be overridden by command line argument
g_force=             # -f, --force
g_snapshots_to_keep= # -k NUM, --keep=NUM
auto_confirm=        # -y, --yes
# Minimal timeout in minutes (6 hours)
g_snapshot_timeout=$((60 * 60 * 6)) # -t MIN, --timeout=MIN

# Define functions
exit_err() {
    echo -e "${COL_R}ERR:${COL_RESET} Snapshot creation failed." >&2
    exit 1
}

# Get the list of directories with a name matches the snapshot name pattern
generate_snapshot_list() {
    find "$SNAPSHOT_PATH" -maxdepth 1 -type d | sort -rn |
        grep -P "$SNAPSHOT_NAME_PATTERN" | sed -e "s|^${SNAPSHOT_PATH}/||"
}

confirmation_dialog() {
    # Confirmation dialog with a single 'y' character to accept

    local user_prompt="${1:-Are you sure?}"
    echo -en "$user_prompt (y|N): "

    local ANS
    if [[ -n "${ZSH_VERSION-}" ]]; then
        read -rk 1 ANS
    else
        read -rn 1 ANS
    fi
    echo # Move to the next line for a cleaner output

    case "$ANS" in
    [yY]) return 0 ;;
    *) return 1 ;;
    esac
}

delete_snapshots() {
    local -a non_writable_dirs
    local dir
    for i in "$@"; do
        echo "Deleting snapshot: $i"
        # make read-only directories writable before deletion
        # TODO: check if it works correctly as the logic was changed
        mapfile -t non_writable_dirs < <(find "${SNAPSHOT_PATH:?}/$i" -type d ! -writable)
        for dir in "${non_writable_dirs[@]}"; do
            sudo chmod u+w "$dir"
        done
        rm -rf "${SNAPSHOT_PATH:?}/$i" || (
            echo -e "${COL_R}ERR:${COL_RESET} Deletion of snapshot $i failed" >&2 && exit 1
        )
    done
}

remove_old_snapshots() {
    [ "$g_snapshots_to_keep" = "" ] && return

    local -a snapshots_to_delete_list
    while IFS= read -r line; do
        snapshots_to_delete_list+=("$line")
    done < <(generate_snapshot_list |
        tail -n +"$(("$g_snapshots_to_keep" + 1))" | nl | sort -nr | cut -f 2-)

    [ "${#snapshots_to_delete_list[@]}" -eq 0 ] && return

    # List snapshots will be deleted
    echo "This snapshot(s) will be deleted:"
    printf '%s\n' "${snapshots_to_delete_list[@]}"
    # Delete listed snapshots
    if [ "$auto_confirm" = "" ] && ! confirmation_dialog ""; then
        echo "Snapshot(s) deletion canceled."
        return
    fi
    echo "Please wait..."
    delete_snapshots "${snapshots_to_delete_list[@]}"
    echo "Snapshot(s) deletion is complete."
}

# Delete interrupted or marked for deletion snapshots
remove_interrupded_snapshots() {
    local -a snapshots_to_delete_list
    while IFS= read -r line; do
        if [ ! -f "${SNAPSHOT_PATH}/$line/${SUCCESS_FILE}" ]; then
            snapshots_to_delete_list+=("$line")
        fi
    done < <(generate_snapshot_list)
    delete_snapshots "${snapshots_to_delete_list[@]}"
}

create_snapshot() {
    # Create exclude list
    TMP_FILE=$(mktemp)

    cat <<-EOF >"${TMP_FILE}"
	*/.terraform.lock.hcl
	*/.terraform/
	.cache
	.cargo
	.config/Code
	.config/Slack
	.config/coc
	.config/google-chrome
	.config/joplin-desktop
	.config/skypeforlinux
	.joplin
	.local/share/nvim
	.mozilla
	.npm
	.nvm
	.rustup
	.tfenv
	.tgenv
	.thunderbird
	.vim
	.vscode
	Documents
	Downloads
	Timeshift_exclude/
	build
	go
	migration
	pCloudDrive/
	vm
	EOF

    echo "Create differential snapshot: $SNAPSHOT_NAME"
    mkdir -p "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}"
    # Create differential snapshot
    rsync \
        --archive \
        --recursive \
        --delete \
        --force \
        --sparse \
        --log-file="${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${LOG_FILENAME}" \
        --exclude-from="$TMP_FILE" \
        --include="/*/.*" \
        --include="/.*" \
        --info=stats2 \
        "${SOURCE_PATH}/" "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${DATA_DIR_NAME}/"
    local exit_code="$?"
    rm "$TMP_FILE"
    [[ "$exit_code" -eq 0 ]] || exit_err
    local MESSAGE=
    read -r -d '' MESSAGE <<__EOM__
Snapshot creation started:  ${SNAPSHOT_NAME}
Snapshot creation finished: $(date +%Y-%m-%d_%H-%M-%S)

More info in ${LOG_FILENAME}.

BE CAREFUL!
If you rename or delete this file,
the directory in which it is located will also be deleted
during the next launch.
__EOM__
    echo "$MESSAGE" >"${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${SUCCESS_FILE}"
    touch "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}"
}

link_prev_snapshot() {
    local last_snapshot="$1"

    echo "Create links from previous snapshot: ${last_snapshot}"
    echo "Please wait..."
    mkdir -p "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}"
    rsync \
        --archive \
        --exclude="/${LOG_FILENAME}" \
        --exclude="/${SUCCESS_FILE}" \
        --link-dest="${SNAPSHOT_PATH}/${last_snapshot}" \
        "${SNAPSHOT_PATH}/${last_snapshot}/" \
        "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/" || exit_err
}

# Usage message
usage() {
    local MESSAGE=
    read -r -d '' MESSAGE <<__EOM__
usage: ${0} [OPTIONS]
Create differential backup of "${SOURCE_PATH}" directory into
"${SNAPSHOT_PATH}" directory using rsync.
Create snapshot only if last snapshot is older than TIMEOUT minutes.

OPTIONS:
    -f, --force
                        Ignore timeout

    -y, --yes
                        Confirm all warnings automatically

    -t MIN, --timeout=MIN
                        Minimal timeout in minutes from last SNAPSHOT allowed
                        (unsigned integer value, default 360)

    -k NUM, --keep=NUM
                        Number of snapshots to keep
                        (unsigned integer value, default keep all snapshots)

    -h, --help
                        Print this help message and exit
__EOM__
    echo "$MESSAGE"
}

process_cmd_options() {
    # Process and validate input command line arguments

    local num

    __undefined_value() {
        echo -e "${COL_R}ERR:${COL_RESET} Undefined value for argument ${1}." >&2
        exit 1
    }

    __is_positive_num() {
        [ "${1}" -gt 0 ] 2>/dev/null || return 1
    }

    __check_if_var_is_num() {
        if ! __is_positive_num "$1"; then
            usage >&2
            exit 1
        fi
    }

    while [[ -n "$1" ]]; do
        case "$1" in
        -f | --force)
            g_force="1"
            ;;
        -t | --timeout)
            [ $# -lt 2 ] && __undefined_value "${1}"
            shift && g_snapshot_timeout="${1}"
            __check_if_var_is_num "$g_snapshot_timeout"
            g_snapshot_timeout="$((g_snapshot_timeout * 60))"
            ;;
        --timeout=*)
            [[ -z "${1#*=}" ]] && __undefined_value "${1}"
            g_snapshot_timeout="${1#*=}"
            __check_if_var_is_num "$g_snapshot_timeout"
            g_snapshot_timeout="$((g_snapshot_timeout * 60))"
            ;;
        -k | --keep)
            [ $# -lt 2 ] && __undefined_value "${1}"
            shift && g_snapshots_to_keep="${1}"
            __check_if_var_is_num "$g_snapshots_to_keep"
            ;;
        --keep=*)
            [[ -z "${1#*=}" ]] && __undefined_value "${1}"
            g_snapshots_to_keep="${1#*=}"
            __check_if_var_is_num "$g_snapshots_to_keep"
            ;;
        -y | --yes)
            auto_confirm="1"
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 1
            ;;
        esac
        shift
    done
}

# Get the newest directory (by the last modified time) from an array of directories
get_newest_dir() {
    local -a snapshots_list
    while IFS= read -r line; do
        snapshots_list+=("$line")
    done < <(generate_snapshot_list)

    local modify_time last_modify_time newest_dir
    i="${#snapshots_list[@]}"
    if [ "$i" -gt 0 ]; then
        i=$((i - 1))
        last_modify_time=$(stat -c %Y "${SNAPSHOT_PATH}/${snapshots_list[$i]}")
        newest_dir="${snapshots_list[$i]}"
        while [ "$i" -gt 0 ]; do
            i=$((i - 1))
            modify_time=$(stat -c %Y "${SNAPSHOT_PATH}/${snapshots_list[$i]}")
            if [ "$modify_time" -gt "$last_modify_time" ]; then
                last_modify_time="$modify_time"
                newest_dir="${snapshots_list[$i]}"
            fi
        done
    fi
    echo "$newest_dir"
}

process_snapshot() {
    # Get the last valid snapshot
    local last_snapshot snapshot_time current_time
    last_snapshot="$(generate_snapshot_list | sort -rn | head -n 1)"

    if [ "$last_snapshot" != "" ]; then
        if [[ -z ${g_force} ]]; then
            # Get time of last snapshot and current time for comparison
            # snapshot_time=$(stat --format='%Y' "${SNAPSHOT_PATH}/${last_snapshot}")
            # Get the date of the most recent snapshot from its directory name
            snapshot_time=$(date -d "$(sed 's/_/ /;s/-/:/3;s/-/:/3' <<<"$last_snapshot")" +%s)
            current_time=$(date +%s)
            if ((current_time < (snapshot_time + g_snapshot_timeout))); then
                echo -e "Snapshot creation ${COL_Y}skipped${COL_RESET} by timeout"
                return
            fi
        fi
        link_prev_snapshot "$last_snapshot"
    fi
    create_snapshot
}

cleanup() {
    echo -e "${COL_Y}WRN:${COL_RESET} Snapshot creation interrupted. Proceeding with cleanup."
    rm -rf "${SNAPSHOT_PATH}/${SNAPSHOT_NAME:?}"
}

main() {
    # Start program here

    process_cmd_options "$@"

    remove_interrupded_snapshots

    process_snapshot

    remove_old_snapshots

    echo -e "Snapshot completed ${COL_G}successfully${COL_RESET}"
}

main "$@"
