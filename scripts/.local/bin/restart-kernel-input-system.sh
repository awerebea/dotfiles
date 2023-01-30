#!/usr/bin/env bash

sudo udevadm trigger --subsystem-match=input --action=change
sleep 2
/home/andrei/.local/bin/mouse-middle-button-scroll
sleep 2
xmodmap -e 'keycode 118 = End'
