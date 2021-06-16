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
SNAPSHOT_TIMEOUT="21600"

SNAPSHOT_NAME=$(date +%Y-%m-%d_%H-%M-%S)
# Just a split of too long line)
SNAPSHOT_NAME_PATTERN='^20([0-9]{2})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])'
SNAPSHOT_NAME_PATTERN+='_(0[0-9]|1[0-9]|2[0-3])-([0-5][0-9])-([0-5][0-9])$'
DATA_DIR_NAME="home"

LOG_FILENAME="rsync-log"

# Define functions
exit_err () {
  echo -e "Snapshot ${RED}failed${NC}"
  exit 1
}

create_snapshot () {
  rsync -aii --recursive --verbose --delete --force --stats --sparse \
    --log-file="${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${LOG_FILENAME}" \
    --include="/*/.*" --exclude="/.*" \
    "${SOURCE_PATH}/" "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}/${DATA_DIR_NAME}/"
}

# Get the newest directory (by name) with name a name matches the snapshot name
# pattern
LAST_SNAPSHOT=$(ls -A -l -1 -r ${SNAPSHOT_PATH} | grep ^d | cut -d ' ' -f 9- |
  grep -P "${SNAPSHOT_NAME_PATTERN}" | head -n 1)

if [ -z ${LAST_SNAPSHOT} ]; then
  # Create first snapshot
  mkdir -p "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}"
  create_snapshot || exit_err
  touch ${SNAPSHOT_PATH}/${SNAPSHOT_NAME}
else
  # Get time of last snapshot and current time for comparsion
  SNAPSHOT_TIME=$(stat --format='%Y' "${SNAPSHOT_PATH}/${LAST_SNAPSHOT}")
  CURRENT_TIME=$(date +%s)
  if (( SNAPSHOT_TIME < ( CURRENT_TIME - ( SNAPSHOT_TIMEOUT ) ) )); then
    # Hardlink previous snapshot to the new one path
    cp -al "${SNAPSHOT_PATH}/${LAST_SNAPSHOT}" \
      "${SNAPSHOT_PATH}/${SNAPSHOT_NAME}" || exit_err
    # Create differential snapshot
    create_snapshot || exit_err
    touch ${SNAPSHOT_PATH}/${SNAPSHOT_NAME}
  else
    echo -e "Snapshot creation ${BROWN}skipped${NC} by timeout"
    exit 0
  fi
fi
echo -e "Snapshot completed ${GREEN}successfully${NC}"
