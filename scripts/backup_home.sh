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

check_if_var_is_num () {
  local num='^[0-9]+$'
  if ! [[ "$1" =~ $num ]] ; then
     usage >&2; exit 1
  fi
}

delete_snapshots () {
  echo "Please wait..."
  echo "$SNAPSHOTS_TO_DELETE_LIST" |
    awk -v prefix="${SNAPSHOT_PATH}/" '{print prefix $0}' |
    tr '\n' '\0' | xargs -0 rm -rf --
  echo "Snapshot(s) deletion is complete."
}

remove_old_snapshots () {
  if ! [ -z ${SNAPSHOTS_TO_KEEP} ]; then
    local SNAPSHOTS_TO_DELETE_LIST=$(echo "${SNAPSHOTS_LIST}" |
      tail -n +"${SNAPSHOTS_TO_KEEP}" | nl | sort -nr | cut -f 2-)
    if ! [ -z ${SNAPSHOTS_TO_DELETE_LIST} ]; then
      # List snapshots will be deleted
      echo "This snapshot(s) will be deleted:"
      echo "$SNAPSHOTS_TO_DELETE_LIST"
      # Delete listed snapshots
      if [ -z ${AUTO_CONFIRM} ]; then
        while true; do
          read -p "Are you sure (y/n)?" yn
          case $yn in
            [Yy]* )
              delete_snapshots
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
        delete_snapshots
      fi
    fi
  fi
  return
}

create_snapshot () {
  # Create exclude list
  TMP_FILE=$(mktemp)

  cat <<- EOF > ${TMP_FILE}
	*/.terraform.lock.hcl
	*/.terraform/
	Documents/Clouds/YandexDisk
	Timeshift_exclude/.cache/mozilla/firefox/*-release/cache2
	Timeshift_exclude/.minikube/
	Timeshift_exclude/.thunderbird/*-release/ImapMail/
	Timeshift_exclude/.vscode/
	Timeshift_exclude/_config/Slack/
	Timeshift_exclude/_config/skypeforlinux/
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

# Command line options variables
FORCE=
SNAPSHOTS_TO_KEEP=
AUTO_CONFIRM=


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
      remove_old_snapshots
      exit 0
    fi
  else
      link_prev_snapshot
      create_snapshot
  fi
fi
remove_old_snapshots
echo -e "Snapshot completed ${GREEN}successfully${NC}"
