#! /usr/bin/env bash
# Calculate time delta

for i in "$@"; do
    if ! validate_time_format "$i"; then exit 1; fi
done
fh="$(echo "$1" | cut -d: -f1)"
fm="$(echo "$1" | cut -d: -f2)"
fs="$(echo "$1" | cut -d: -f3)"
sh="$(echo "$2" | cut -d: -f1)"
sm="$(echo "$2" | cut -d: -f2)"
ss="$(echo "$2" | cut -d: -f3)"
fd="$(( 10#$fh * 3600 + 10#$fm * 60 + 10#$fs ))"
sd="$(( 10#$sh * 3600 + 10#$sm * 60 + 10#$ss ))"
rd="$(( sd - fd ))"
if [ "$rd" -lt 0 ]; then rd="$(( 24 * 3600 + 10#$rd ))"; fi
rh="$(( 10#$rd/3600 ))"
rm="$(( (10#$rd - 10#$rh * 3600)/60 ))"
rs="$(( 10#$rd - 10#$rh * 3600 - 10#$rm * 60 ))"
printf "%02d:%02d:%02d\n" "$rh" "$rm" "$rs"
