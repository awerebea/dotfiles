#!/usr/bin/env bash

if [ "$(wmctrl -xl | grep -c keepass2)" != 0 ]; then
    window_id=$(xdotool search --onlyvisible --classname keepass2)
    if [ "$(xprop -id "$window_id" | grep -c '_NET_WM_STATE_HIDDEN')" == 0 ]; then
        xdotool search --onlyvisible --classname --sync keepass2 windowminimize
    else
        wmctrl -a keepass
    fi
else
    keepass2
fi
