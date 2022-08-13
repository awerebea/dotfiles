#! /usr/bin/env bash

export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority

ALLOW_IDLE=2600000

if [ "$(xprintidle)" -gt $ALLOW_IDLE ]; then
    if [ "$(sudo smbstatus | grep --count DENY)" -gt 0 ] ||
    [ "$(pgrep --count rclone)" -gt 0 ]; then
        eval "$(xdotool getmouselocation --shell)"
        xdotool mousemove "$X" "$Y"
        exit 0
    fi
fi
