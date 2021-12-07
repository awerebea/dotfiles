#!/usr/bin/env bash

# Define colors
YEL='\e[1;33m'
END='\e[0m' # No Color

function fingerprint_toggle() {
    local ACTION
    if [ "$1" == "disable" ]; then
        ACTION="remove"
    elif [ "$1" == "enable" ]; then
        ACTION="enable"
    fi
    echo -en "${YEL}WRN:${END} Do you want to $1 fingerprint? (y|n): "
    read -r ANS
    case "${ANS}" in
    [yY] | [yY][eE][sS])
        sudo pam-auth-update --"$ACTION" fprintd
        echo "Fingerprint ${ACTION}d"
        ;;
    *)
        ;;
    esac
}

if sudo grep -E "^# $USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null; then
    sudo sed -i "s/^# $USER ALL = NOPASSWD: ALL/$USER ALL = NOPASSWD: ALL/" /etc/sudoers
    echo "sudo password protection DISABLED"
    fingerprint_toggle disable
elif sudo grep -E "^$USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null; then
    sudo sed -i "s/^$USER ALL = NOPASSWD: ALL/# $USER ALL = NOPASSWD: ALL/" /etc/sudoers
    echo "sudo password protection ENABLED"
    fingerprint_toggle enable
else
    echo "$USER ALL = NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    echo "sudo password protection DISABLED"
    fingerprint_toggle disable
fi
