#!/usr/bin/env bash


# Define colors
GRN='\e[1;32m'
YEL='\e[1;33m'
END='\e[0m' # No Color

_delete_empty_dirs() {
    printf "%bWRN%b: These directories will be removed:\n" "${YEL}" "${END}"
    find . -empty -type d -print
    echo -en "${YEL}WRN:${END} "
    message="Press Enter to continue deleting, or CTRL+C to exit."
    read -rp "$message"
    echo -e "${GRN}REMOVED:${END} "
    find . -empty -type d -print -delete
}

_delete_empty_dirs
