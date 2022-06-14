#! /usr/bin/env bash

mapfile -d $'\0' file_list < <(find /media/andrei/Data/Music -type f -name "*.mp3" -print0)

cptimestamp() {
  if [ -z "$2" ] ; then
    echo "usage: cptimestamp <sourcefile> <destfile>"
    exit
  fi
  touch -d @"$(stat -c "%Y" "$1")" "$2"
}

# Create empty structure of source files
empty_mirror=()
for f in "${file_list[@]}"; do
    empty_mirror+=("${f//\/media\/andrei\/Data\/Music/\/media\/andrei\/Data\/Music-EM}")
done

i=0
while [ $i -lt "${#file_list[@]}" ]; do
    # cptimestamp "${file_list[$i]}" "${empty_mirror[$i]}"
    mkdir -p "$(dirname "${empty_mirror[$i]}")"
    touch -r "${file_list[$i]}" "${empty_mirror[$i]}"
    # touch -md "$(date -R -r "${empty_mirror[$i]}") - 1 hours" "${empty_mirror[$i]}"
    touch -md "$(date -R -r "${file_list[$i]}") - 1 hours" "${file_list[$i]}"
    i=$(( i + 1 ))
done

