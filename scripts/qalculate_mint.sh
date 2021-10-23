#! /bin/bash

if [ `wmctrl -xl | grep -c qalculate-gtk` != 0 ]; then
    window_id=`xdotool search --onlyvisible --classname qalculate-gtk`
    if [ `xprop -id $window_id | grep -c "_NET_WM_STATE_HIDDEN"` == 0 ]; then
        xdotool search --onlyvisible --classname --sync qalculate-gtk windowminimize
    else
        wmctrl -a Qalculate!
    fi
else
    qalculate-gtk
fi
