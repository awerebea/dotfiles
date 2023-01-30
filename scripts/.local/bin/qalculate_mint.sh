#!/usr/bin/env bash

if [ "$(wmctrl -xl | grep -c qalculate-gtk)" != 0 ]; then
    window_id=$(xdotool search --onlyvisible --classname qalculate-gtk)
    if [ "$(xprop -id "$window_id" | grep -c '_NET_WM_STATE_FOCUSED')" == 0 ]; then
        wmctrl -a Qalculate!
    else
        xdotool search --onlyvisible --classname --sync qalculate-gtk windowminimize
    fi
else
    qalculate-gtk
fi
