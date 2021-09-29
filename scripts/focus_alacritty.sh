#! bash

xdotool windowactivate `xdotool search --classname Alacritty | sort -h | head -n 1`
