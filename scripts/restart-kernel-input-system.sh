#!/usr/bin/env bash

sudo udevadm trigger --subsystem-match=input --action=change
/home/andrei/.local/bin/mouse-middle-button-scroll
xmodmap -e 'keycode 118 = End'
