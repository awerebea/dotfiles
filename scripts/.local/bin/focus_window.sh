#!/usr/bin/env bash

[[ $# -lt 1 ]] && exit 1
xdotool windowactivate "$(xdotool search --classname "$1" | sort -h | head -n 1)"
