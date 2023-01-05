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
fd="$(( fh * 3600 + fm * 60 + fs ))"
sd="$(( sh * 3600 + sm * 60 + ss ))"
rd="$(( sd - fd ))"
if [ "$rd" -lt 0 ]; then rd="$(( 24 * 3600 + rd ))"; fi
rh="$(( rd/3600 ))"
rm="$(( (rd - rh * 3600)/60 ))"
rs="$(( rd - rh * 3600 - rm * 60 ))"
printf "%02d:%02d:%02d\n" "$rh" "$rm" "$rs"
