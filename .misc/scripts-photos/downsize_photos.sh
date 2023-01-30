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
    \( \
       -path "$SOURCE_DIR/_Inbox" -prune \
    -o -path "$SOURCE_DIR/_RAW" -prune \
    \) -o \
    -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

resized_list=()
for f in "${file_list[@]}"; do
    # shellcheck disable=SC2001
    resized_list+=("$(echo "$f" | sed "s|$SOURCE_DIR|${SOURCE_DIR}_resized|")")
done

i=0
while [ $i -lt "${#file_list[@]}" ]; do
    # echo "${file_list[$i]}"
    if [ ! -f "${resized_list[$i]}" ]; then
        mkdir -p "$(dirname "${resized_list[$i]}")"
        progress-bar $(( i + 1 )) ${#file_list[@]} "${resized_list[$i]}"
        magick "${file_list[$i]}" -resize 3840x2560\> "${resized_list[$i]}" || exit $?
        touch -r "${file_list[$i]}" "${resized_list[$i]}"
    fi
    i=$(( i + 1 ))
done

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
