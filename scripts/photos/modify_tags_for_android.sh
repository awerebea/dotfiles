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
find "$SOURCE_DIR" \
    -not \
    \( \
       -path "$SOURCE_DIR/_Inbox" -prune \
    -o -path "$SOURCE_DIR/_RAW" -prune \
    \) \
    -type f -iname "*.xmp" -execdir \
    exiftool -overwrite_original "-Subject<HierarchicalSubject" '{}' +

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
