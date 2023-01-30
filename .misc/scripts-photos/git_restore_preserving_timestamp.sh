#! /usr/bin/env bash

SCRIPT_NAME="$(basename "$0")"

SOURCE_DIR="${1:-/media/andrei/Data/Test}"
SOURCE_DIR="$(realpath "$SOURCE_DIR")"

# Define colors
GRN='\e[1;32m'
YEL='\e[1;33m'
END='\e[0m' # No Color

LOGS_DIR="$HOME/.local/log/scripts-photo"
mkdir -p "$LOGS_DIR"

START_TIME="$(date "+%Y-%m-%d %H:%M:%S")"

# Create lists
echo "Creating a list of files..."
mapfile -d $'\0' file_list < <( \
    find "$SOURCE_DIR" \
    -not \
    \( \
       -path "$SOURCE_DIR/_Inbox" -prune \
    -o -path "$SOURCE_DIR/_RAW" -prune \
    \) \
    -type f -iname "*.xmp" -print0)

BACKUP_DIR=$(mktemp -d -t script-XXXXXXXX)

backup_list=()
for f in "${file_list[@]}"; do
    # shellcheck disable=SC2001
    backup_list+=("$(echo "$f" | sed "s|$SOURCE_DIR|$BACKUP_DIR|")")
done

i=0
echo "Recreate filestructure in the temp directory in order to preserve timestamps..."
while [ $i -lt "${#file_list[@]}" ]; do
    mkdir -p "$(dirname "${backup_list[$i]}")"
    touch -r "${file_list[$i]}" "${backup_list[$i]}"
    progress-bar $(( i + 1 )) ${#file_list[@]} "${file_list[$i]}"
    i=$(( i + 1 ))
done
printf '\nBackup of files timestams finished!\n'

echo "Restore all files in a given git repository."
git -C "$SOURCE_DIR" restore .

i=0
echo "Restore files timestamps from backup..."
while [ $i -lt "${#file_list[@]}" ]; do
    touch -r "${backup_list[$i]}" "${file_list[$i]}"
    progress-bar $(( i + 1 )) ${#file_list[@]} "${file_list[$i]}"
    i=$(( i + 1 ))
done
printf '\nFiles timestams restored!\n'

echo "Remove temp directory."
rm -rf "$BACKUP_DIR"

FINISH_TIME="$(date "+%Y-%m-%d %H:%M:%S")"

START_SECONDS=$(date --date "$START_TIME" +%s)
FINISH_SECONDS=$(date --date "$FINISH_TIME" +%s)

SECONDS_ELEAPSED="$(( FINISH_SECONDS - START_SECONDS ))"

echo -e "$(date "+%Y.%m.%d %H:%M:%S") : ${GRN}Processing finished successfully.${END}"
echo "$(date "+%Y.%m.%d %H:%M:%S") : Processing finished successfully. " >> "$LOGS_DIR/$SCRIPT_NAME.log"
truncate -s-1 "$LOGS_DIR/$SCRIPT_NAME.log"
echo "Time elapsed: $(date -d@$SECONDS_ELEAPSED -u +%H:%M:%S)" | tee -a "$LOGS_DIR/$SCRIPT_NAME.log"

echo -en "${YEL}WRN:${END} "
if read -n 1 -t 60 -s -r -p "The system will be suspended after 1 minute. Press any key to prevent suspension and exit now."; then
    echo
else
    sudo pm-suspend
fi
