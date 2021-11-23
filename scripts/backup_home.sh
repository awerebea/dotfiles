#!/usr/bin/env bash


# Define global variables
SOURCE_PATH="/home/andrei"
SNAPSHOT_PATH="/media/andrei/bckp/backup"

# Minimal timeout in minutes (6 hours)
SNAPSHOT_TIMEOUT=$(( 60 * 60 * 6 ))

# Name of the subdirectory in the snapshot directory to save the data
DATA_DIR_NAME="home"

# Names of generated files
LOG_FILENAME="rsync-log"
SUCCESS_FILE="completed_successfully"

# Define colors
RED='\e[1;31m'
GRN='\e[1;32m'
YEL='\e[1;33m'
END='\e[0m' # No Color

# Snapshot name pattern
SNAPSHOT_NAME=$(date +%Y-%m-%d_%H-%M-%S)
# Just a split of too long line)
SNAPSHOT_NAME_PATTERN="^${SNAPSHOT_PATH}/"
SNAPSHOT_NAME_PATTERN+="20([0-9]{2})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])"
SNAPSHOT_NAME_PATTERN+="_(0[0-9]|1[0-9]|2[0-3])-([0-5][0-9])-([0-5][0-9])$"

FORCE=
SNAPSHOTS_TO_KEEP=
AUTO_CONFIRM=
SNAPSHOTS_LIST=()
LAST_SNAPSHOT=


# Clean up environment and exit
function clean_and_exit() {
    unset SOURCE_PATH SNAPSHOT_PATH SNAPSHOT_TIMEOUT DATA_DIR_NAME \
        LOG_FILENAME SUCCESS_FILE RED GRN YEL END SNAPSHOT_NAME \
        SNAPSHOT_NAME_PATTERN FORCE SNAPSHOTS_TO_KEEP AUTO_CONFIRM \
        SNAPSHOTS_LIST LAST_SNAPSHOT
    exit "${1}"
}


# Define functions
exit_err() {
    echo -e "Snapshot ${RED}failed${END}"
    clean_and_exit 1
}


delete_snapshots() {
    for i in "$@"; do
        echo "Deleting snapshot: $i"
        # make read-only directories writable before deletion
        find "${SNAPSHOT_PATH:?}/$i" -type d ! -writable -print0 | \
            xargs -0 chmod u+w
        rm -rf "${SNAPSHOT_PATH:?}/$i"
    done
}


remove_old_snapshots() {
    local -a SNAPSHOTS_TO_DELETE_LIST
    local -a SNAPSHOTS_LIST
    mapfile -t SNAPSHOTS_LIST < <( generate_snapshot_list )
    if [ -n "${SNAPSHOTS_TO_KEEP}" ]; then
        mapfile -t SNAPSHOTS_TO_DELETE_LIST < \
            <( printf '%s\n' "${SNAPSHOTS_LIST[@]}" | \
            tail -n +"${SNAPSHOTS_TO_KEEP}" | nl | sort -nr | cut -f 2- )
        if [ "${#SNAPSHOTS_TO_DELETE_LIST[@]}" -gt 0 ]; then
            # List snapshots will be deleted
            echo "This snapshot(s) will be deleted:"
            printf '%s\n' "${SNAPSHOTS_TO_DELETE_LIST[@]}"
            # Delete listed snapshots
            if [ -z "${AUTO_CONFIRM}" ]; then
                while true; do
                    read -rp "Are you sure (y/n)?" yn
                    case $yn in
                        [Yy]* )
                            echo "Please wait..."
                            delete_snapshots "${SNAPSHOTS_TO_DELETE_LIST[@]}"
                            echo "Snapshot(s) deletion is complete."
                            break
                            ;;
                        [Nn]* )
                            echo "Snapshot(s) deletion canceled."
                            break
                            ;;
                        * )
                            echo "Please answer (y)es or (n)o."
                            ;;
                    esac
                done
            else
                delete_snapshots "${SNAPSHOTS_TO_DELETE_LIST[@]}"
            fi
        fi
    fi
    return
}


# Delete interrupted or marked for deletion snapshots
remove_interrupded_snapshots() {
    local -a SNAPSHOTS_LIST
    mapfile -t SNAPSHOTS_LIST < <( generate_snapshot_list )
    for i in "${SNAPSHOTS_LIST[@]}"; do
        local -a SNAPSHOTS_TO_DELETE_LIST
        if [ ! -f "${SNAPSHOT_PATH}/$i/${SUCCESS_FILE}" ]; then
            SNAPSHOTS_TO_DELETE_LIST+=("$i")
        fi
    done
    delete_snapshots "${SNAPSHOTS_TO_DELETE_LIST[@]}"
    return
}


create_snapshot() {
    # Create exclude list
    TMP_FILE=$(mktemp)

    cat <<- EOF > "${TMP_FILE}"
	*/.terraform.lock.hcl
	*/.terraform/
	build
	Clouds
	Documents
	Downloads
	Timeshift_exclude/.cache/google-chrome/Default/Cache/
	Timeshift_exclude/.cache/google-chrome/Default/Code Cache/
	Timeshift_exclude/.cache/mozilla/firefox/*-release/cache2/
	Timeshift_exclude/.cache/thumbnails/
	Timeshift_exclude/.cache/thunderbird/*-release/cache2/
	Timeshift_exclude/.cache/nvim/log
	Timeshift_exclude/.minikube/
	Timeshift_exclude/.thunderbird/*-release/ImapMail/
	Timeshift_exclude/.vscode/
	Timeshift_exclude/_config/Code/Cache/
	Timeshift_exclude/_config/Code/CachedData/
	Timeshift_exclude/_config/Code/CachedExtensionVSIXs/
	Timeshift_exclude/_config/Code/CachedExtensions/
	Timeshift_exclude/_config/Slack/
	Timeshift_exclude/_config/coc/extensions/node_modules/
	Timeshift_exclude/_config/google-chrome/Default/Service Worker/CacheStorage/
	Timeshift_exclude/_config/skypeforlinux/
	vm
	EOF

    # Create differential snapshot
    rsync -aii --recursive --verbose --delete --force --stats --sparse \
        --log-file="${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${LOG_FILENAME}" \
        --exclude-from="${TMP_FILE}" \
        --include="/*/.*" \
        --exclude="/.*" \
        "${SOURCE_PATH}/" "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${DATA_DIR_NAME}/" ||
        exit_err
    rm "${TMP_FILE}"
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__
Snapshot creation started:  ${SNAPSHOT_NAME}
Snapshot creation finished: $(date +%Y-%m-%d_%H-%M-%S)

More info in ${LOG_FILENAME}.

BE CAREFUL!
If you rename or delete this file,
the directory in which it is located will also be deleted
during the next launch.
__EOM__
    echo "${MESSAGE}" > "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${SUCCESS_FILE}"
    touch "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}"
    return
}


link_prev_snapshot() {
    echo "Create links from previous snapshot: ${LAST_SNAPSHOT}"
    echo "Please wait..."
    rsync -a --exclude="/${LOG_FILENAME}" --exclude="/${SUCCESS_FILE}" \
        --link-dest="${SNAPSHOT_PATH}/${LAST_SNAPSHOT}" \
        "${SNAPSHOT_PATH}/${LAST_SNAPSHOT}/" \
        "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/" || exit_err
    return
}


# Usage message
usage() {
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__
usage: ${0} [OPTIONS]
Create differential backup of "${SOURCE_PATH}" directory into
"${SNAPSHOT_PATH}" directory using rsync.
Create snapshot only if last snapshot is older than TIMEOUT minutes.

OPTIONS:
    -f, --force
                        Ignore timeout

    -y, --yes
                        Confirm all warnings automatically

    -t, --timeout=NUM
                        Minimal timeout in minutes from last SNAPSHOT allowed
                        (unsigned integer value, default 360)

    -k, --keep=NUM
                        Number of snapshots to keep
                        (unsigned integer value, default keep all snapshots)

    -h, --help
                        Print this help message and exit
__EOM__
    echo "${MESSAGE}"
    return
}


check_if_var_is_num() {
    local num='^[0-9]+$'
    if ! [[ "$1" =~ $num ]] ; then
        usage >&2; clean_and_exit 1
    fi
}


# Process command line options
while [[ -n "$1" ]]; do
    case "$1" in
    -f | --force)
        FORCE="1"
        ;;
    -t | --timeout=*)
        if [ "$1" = "-t" ]; then
            shift
            SNAPSHOT_TIMEOUT="$1"
            check_if_var_is_num "${SNAPSHOT_TIMEOUT}"
            SNAPSHOT_TIMEOUT=$(( "${SNAPSHOT_TIMEOUT}" * 60 ))
        else
            SNAPSHOT_TIMEOUT=$(echo "$1" | cut -d '=' -f 2-)
            check_if_var_is_num "${SNAPSHOT_TIMEOUT}"
            SNAPSHOT_TIMEOUT=$(( "${SNAPSHOT_TIMEOUT}" * 60 ))
        fi
        ;;
    -k | --keep=*)
        if [ "$1" = "-k" ]; then
            shift
            SNAPSHOTS_TO_KEEP="$1"
            check_if_var_is_num "${SNAPSHOTS_TO_KEEP}"
            SNAPSHOTS_TO_KEEP=$(( "${SNAPSHOTS_TO_KEEP}" + 1 ))
        else
            SNAPSHOTS_TO_KEEP=$(echo "$1" | cut -d '=' -f 2-)
            check_if_var_is_num "${SNAPSHOTS_TO_KEEP}"
            SNAPSHOTS_TO_KEEP=$(( "${SNAPSHOTS_TO_KEEP}" + 1 ))
        fi
        ;;
    -y | --yes)
        AUTO_CONFIRM="1"
        ;;
    -h | --help)
        usage
        clean_and_exit 0
        ;;
    *)
        usage >&2
        clean_and_exit 1
        ;;
    esac
    shift
done


# Get the list of directories with a name matches the snapshot name pattern
generate_snapshot_list() {
    find "${SNAPSHOT_PATH}" -maxdepth 1 -type d | sort -rn | \
        grep -P "${SNAPSHOT_NAME_PATTERN}" | sed -e "s*^${SNAPSHOT_PATH}/**"
    return
}


# Get the newest directory (by the last modified time) from an array of
# directories
get_newest_dir() {
    local NEWEST_DIR=
    i="${#SNAPSHOTS_LIST[@]}"
    if [ "$i" -gt 0 ]; then
        i=$((i-1))
        LAST_MODIFY_TIME=$(stat -c %Y "${SNAPSHOT_PATH}/${SNAPSHOTS_LIST[$i]}")
        NEWEST_DIR="${SNAPSHOTS_LIST[$i]}"
        while [ $i -gt 0 ]; do
            i=$((i-1))
            MODIFY_TIME=$(stat -c %Y "${SNAPSHOT_PATH}/${SNAPSHOTS_LIST[$i]}")
            if [ "${MODIFY_TIME}" -gt "${LAST_MODIFY_TIME}" ]; then
                LAST_MODIFY_TIME="${MODIFY_TIME}"
                NEWEST_DIR="${SNAPSHOTS_LIST[$i]}"
            fi
        done
    fi
    echo "${NEWEST_DIR}"
    return
}


# Get the latest directory (by name) from an array of directories
get_latest_dir_by_name() {
    printf '%s\n' "${SNAPSHOTS_LIST[@]}" | sort -rn | head -n 1
    return
}

#-Main script body--------------------------------------------------------------

remove_interrupded_snapshots

# Get an array of valid snapshots
mapfile -t SNAPSHOTS_LIST < <( generate_snapshot_list )

# Get the last valid snapshot
LAST_SNAPSHOT="$(get_latest_dir_by_name)"

if [ -z "${LAST_SNAPSHOT}" ]; then
    # Create first snapshot
    mkdir -p "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}"
    create_snapshot
else
    if [[ -z ${FORCE} ]]; then
        # Get time of last snapshot and current time for comparison
        SNAPSHOT_TIME=$(stat --format='%X' "${SNAPSHOT_PATH}/${LAST_SNAPSHOT}")
        CURRENT_TIME=$(date +%s)
        if (( SNAPSHOT_TIME < ( CURRENT_TIME - SNAPSHOT_TIMEOUT ) )); then
            link_prev_snapshot
            create_snapshot
        else
            echo -e "Snapshot creation ${YEL}skipped${END} by timeout"
            remove_old_snapshots
            clean_and_exit 0
        fi
    else
            link_prev_snapshot
            create_snapshot
    fi
fi
remove_old_snapshots
echo -e "Snapshot completed ${GRN}successfully${END}"
