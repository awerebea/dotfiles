#!/usr/bin/env bash

if sudo grep -E "^# $USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null; then
    sudo sed -i "s/^# $USER ALL = NOPASSWD: ALL/$USER ALL = NOPASSWD: ALL/" /etc/sudoers
    echo "sudo password protection DISABLED"
elif sudo grep -E "^$USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null; then
    sudo sed -i "s/^$USER ALL = NOPASSWD: ALL/# $USER ALL = NOPASSWD: ALL/" /etc/sudoers
    echo "sudo password protection ENABLED"
else
    echo "$USER ALL = NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    echo "sudo password protection DISABLED"
fi
