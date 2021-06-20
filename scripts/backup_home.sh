#! /bin/bash

# Setup colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BROWN='\033[0;33m'
NC='\033[0m' # No Color

# Setup variables
SOURCE_PATH="/home/andrei"
SNAPSHOT_PATH="/media/andrei/Data/backup"

# Minimal timeout in minutes (6 hours)
SNAPSHOT_TIMEOUT=$(( 60 * 60 * 6 ))

SNAPSHOT_NAME=$(date +%Y-%m-%d_%H-%M-%S)
# Just a split of too long line)
SNAPSHOT_NAME_PATTERN='^20([0-9]{2})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])'
SNAPSHOT_NAME_PATTERN+='_(0[0-9]|1[0-9]|2[0-3])-([0-5][0-9])-([0-5][0-9])$'

generate_snapshot_list () {
  ls -A -l -1 -r "${SNAPSHOT_PATH}" | grep ^d | tr -s ' ' | cut -d ' ' -f 9- |
    grep -P "${SNAPSHOT_NAME_PATTERN}"
  return
}

DATA_DIR_NAME="home"

LOG_FILENAME="rsync-log"
SUCCESS_FILE="completed_successfully"

# Define functions
exit_err () {
  echo -e "Snapshot ${RED}failed${NC}"
  exit 1
}

create_snapshot () {
  # Create differential snapshot
  rsync -aii --recursive --verbose --delete --force --stats --sparse \
    --log-file="${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${LOG_FILENAME}" \
    --include="/*/.*" --exclude="/.*" \
    "${SOURCE_PATH}/" "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${DATA_DIR_NAME}/" ||
    exit_err
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

link_prev_snapshot () {
  echo "Create links from previous snapshot: ${LAST_SNAPSHOT}"
  echo "Please wait..."
  rsync -a --exclude="/${LOG_FILENAME}" --exclude="/${SUCCESS_FILE}" \
    --link-dest="${SNAPSHOT_PATH}/${LAST_SNAPSHOT}" \
    "${SNAPSHOT_PATH}/${LAST_SNAPSHOT}/" \
    "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/" || exit_err
  return
}

# Usage message
usage () {
  local MESSAGE=
  read -r -d '' MESSAGE << __EOM__
usage: ${0} [OPTIONS]
Create differential backup of "${SOURCE_PATH}" directory into
"${SNAPSHOT_PATH}" directory using rsync.
Create snapshot only if last snapshot is older than TIMEOUT minutes.

OPTIONS:
  -f, --force         Ignore timeout
  -t, --timeout NUM   Minimal timeout in minutes from last SNAPSHOT allowed
                      (integer value, default 360)

  -h, --help          print this help message and exit
__EOM__
  echo "${MESSAGE}"
  return
}

# Command line options variables
FORCE=

# Process command line options
while [[ -n "$1" ]]; do
  case "$1" in
  -f | --force)
    FORCE="1"
    ;;
  -t | --timeout)
    shift
    SNAPSHOT_TIMEOUT=$(( "$1" * 60 ))
    ;;
  -h | --help)
    usage
    exit
    ;;
  *)
    usage >&2
    exit 1
    ;;
  esac
  shift
done

# Get the list of directories with a name matches the snapshot name pattern
SNAPSHOTS_LIST="$(generate_snapshot_list)"

# Clear interrupted snapshots (dirs without SUCCESS_FILE)
set -- ${SNAPSHOTS_LIST}
i=$#
while [ $i -gt 0 ]; do
  eval "SNAPSHOT=\${$i}"
  if [ ! -f "${SNAPSHOT_PATH}/${SNAPSHOT}/${SUCCESS_FILE}" ]; then
    echo -n "Deleting a snapshot that was interrupted or marked for deletion: "
    echo "${SNAPSHOT}"
    echo "Please wait..."
    rm -rf "${SNAPSHOT_PATH}/${SNAPSHOT}"
  fi
  i=$((i-1))
done

# # Get the newest directory (by name) with name a name matches the snapshot name
# # pattern
LAST_SNAPSHOT="$(generate_snapshot_list | head -n 1)"

if [ -z ${LAST_SNAPSHOT} ]; then
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
      echo -e "Snapshot creation ${BROWN}skipped${NC} by timeout"
      exit 0
    fi
  else
      link_prev_snapshot
      create_snapshot
  fi
fi
echo -e "Snapshot completed ${GREEN}successfully${NC}"
