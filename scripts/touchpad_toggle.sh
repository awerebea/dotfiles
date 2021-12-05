#!/usr/bin/env bash

# Define variables
if [ $# -eq 0 ]; then
    TOUCHPAD_DEVICE_NAME='SYNA30BE:00 06CB:CE09' # HP Elitebook 850 G8
else
    TOUCHPAD_DEVICE_NAME=$1
fi

declare -i ID
ID=$(xinput list | grep -Eo "$TOUCHPAD_DEVICE_NAME\s*id\=[0-9]{1,2}" | \
    tail -1 | cut -d = -f 2)
declare -i STATE
STATE=$(xinput list-props "$ID" | grep 'Device Enabled' | awk '{print $4}')
if [ "$STATE" -eq 1 ]
then
    xinput --disable "$ID"
    echo "Touchpad disabled."
    yad --timeout=1 --no-buttons --width=150 --height=30 --text-align=center \
        --title="Info" --text "Touchpad disabled."
else
    xinput --enable "$ID"
    echo "Touchpad enabled."
    yad --timeout=1 --no-buttons --width=150 --height=30 --text-align=center \
        --title="Info" --text "Touchpad enabled."
fi
