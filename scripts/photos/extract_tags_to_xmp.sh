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
mapfile -d $'\0' file_list < <( find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

i=0
echo "Processing files..."
while [ $i -lt "${#file_list[@]}" ]; do
    if [ ! -f "${file_list[$i]}.xmp" ]; then
        progress-bar $(( i + 1 )) ${#file_list[@]} \
            "$(echo -n "${file_list[$i]}: "; exiftool -tagsfromfile "${file_list[$i]}" "${file_list[$i]}.xmp")"
        touch -r "${file_list[$i]}" "${file_list[$i]}.xmp"
    fi
    i=$(( i + 1 ))
done
printf '\nFinished!\n'

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
