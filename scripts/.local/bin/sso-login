#! /usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "The AWS profile must be specified by the cmdline argument."
    exit 1
fi

aws sso login --profile="$1" 2>&1 |
    stdbuf -o 0 grep -v "^Attempting\|^If\|^Then\|^$" |
    stdbuf -o 0 sed '2 i ?user_code=' | stdbuf -o 0 tr --delete '\n'
