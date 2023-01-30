#!/usr/bin/env bash

[[ $# -lt 1 ]] && exit 1
if pgrep -x "$1" > /dev/null; then
    xdotool windowactivate "$(xdotool search --classname "$1" | sort -h | head -n 1)"
else
    if [ "$1" == "chrome" ]; then
        google-chrome
    elif [ "$1" == "Telegram" ]; then
        /home/andrei/.telegram/Telegram -workdir /home/andrei/.local/share/TelegramDesktop/ -- %u
    else
        "$1"
    fi
fi
