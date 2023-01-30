#!/usr/bin/env bash
# Control Foobar2000 playback if running, default behavior if not.
# Requires one of the arguments: play, stop, prev or next


if [ $# -eq 0 ]; then
    echo "Argument with the command is required"
    exit 1
else
    case "${1}" in
    play)
        FB2K_CMD="/playpause"
        DFLT_CMD="PlayPause"
        ;;
    stop)
        FB2K_CMD="/stop"
        DFLT_CMD="Stop"
        ;;
    prev)
        FB2K_CMD="/prev"
        DFLT_CMD="Previous"
        ;;
    next)
        FB2K_CMD="/next"
        DFLT_CMD="Next"
        ;;
    esac
fi


if [ "$(pgrep 'foobar2000')" ]; then
    wine /home/andrei/foobar2000/foobar2000.exe "${FB2K_CMD}"
else
    for mplayer in $(qdbus |
        grep -E 'org.mpris.MediaPlayer2|plasma-browser-integration'); do
        if [[ $(qdbus "${mplayer}" /org/mpris/MediaPlayer2 \
            org.mpris.MediaPlayer2.Player.PlaybackStatus) == 'Playing' ]]; then
            echo "${mplayer}"
        fi
    done
    dbus-send --print-reply --dest="${mplayer}" /org/mpris/MediaPlayer2 \
        org.mpris.MediaPlayer2.Player."${DFLT_CMD}"
fi

    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Prev
