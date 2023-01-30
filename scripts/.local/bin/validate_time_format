#! /usr/bin/env bash

if [[ $1 =~ ^([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})$ ]]; then
    if (( 10#${BASH_REMATCH[3]} < 60 )) && (( 10#${BASH_REMATCH[2]} < 60 )) &&
    (( 10#${BASH_REMATCH[1]} < 24 )); then
        exit 0
    fi
fi
echo "Wrong format. Please use the H[H]:M[M]:S[S]"
exit 1
