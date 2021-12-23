#!/usr/bin/env zsh
# "Squash" multi-line commands in bash_history file to one line

SOURCE_FILE="zsh_history"
SOURCE_FILE="${ZSH_HISTORY_FILE}"

# Create temporary files
# TMP_FILE_1=$(mktemp)
# TMP_FILE_2=$(mktemp)
TMP_FILE_1=temp1
TMP_FILE_2=temp2
# DEBUG
# echo "${TMP_TMP_FILE_1}"
# echo "${TMP_TMP_FILE_2}"

# Generate random character sequences to replace \n and anchor the first line of a command
NL_REPLACEMENT=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
FIRST_LINE_ANCHOR=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)

# Filter out multi-line commands and save them to a separate file
grep -v -B 1 '^: [0-9]\+:[0-9]\+;' "${SOURCE_FILE}" > "${TMP_FILE_1}" && \
    grep -v -e '^--$' "${TMP_FILE_1}" > "${TMP_FILE_2}" && \
    mv "${TMP_FILE_2}" "${TMP_FILE_1}"

# Filter out multi-line commands and remove them from the original file
grep -v -x -F -f "${TMP_FILE_1}" "${SOURCE_FILE}" > "${TMP_FILE_2}" && \
    mv "${TMP_FILE_2}" "${SOURCE_FILE}"

# Add anchor before the first line of each command
sed "s/\(^: [0-9]\+:[0-9]\+;\)/${FIRST_LINE_ANCHOR} \1/" \
    "${TMP_FILE_1}" > "${TMP_FILE_2}" && mv "${TMP_FILE_2}" "${TMP_FILE_1}"

# Replace all \n with a sequence of symbols
sed ':a;N;$!ba;s/\n/'" ${NL_REPLACEMENT} "'/g' \
    "${TMP_FILE_1}" > "${TMP_FILE_2}" && mv "${TMP_FILE_2}" "${TMP_FILE_1}"

# Replace first line anchor by \n
sed "s/${FIRST_LINE_ANCHOR} \(: [0-9]\+:[0-9]\+;\)/\n\1/g" \
    "${TMP_FILE_1}" > "${TMP_FILE_2}" && mv "${TMP_FILE_2}" "${TMP_FILE_1}"

# Merge squashed multiline commands to the SOURCE_FILE
cat "${TMP_FILE_1}" >> "${SOURCE_FILE}"

# Sort SOURCE_FILE
sort -n < "${SOURCE_FILE}" > "${TMP_FILE_1}" && \
    mv "${TMP_FILE_1}" "${SOURCE_FILE}"

# Add the replacement sequence \n to use after decryption to recover
# multi-line commands
echo "${NL_REPLACEMENT}" >> "${SOURCE_FILE}"

# Get sequence of symbols to be replaced by \n
SOURCE_FILE="${ZSH_HISTORY_FILE}"
NL_REPLACEMENT=$(grep '^\([a-z|A-Z|0-9]\{32\}$\)' "${SOURCE_FILE}")

# Filter unnecessary lines from the SOURCE_FILE (the replacement sequence
# and Binary file ... matches) and save them in a separate file
TMP_FILE_1=temp1
TMP_FILE_2=temp2
grep -v '^: [0-9]\+:[0-9]\+;' "${SOURCE_FILE}" > "${TMP_FILE_1}"

# Filter out unnecessary lines and remove them from the original file
grep -v -x -F -f "${TMP_FILE_1}" "${SOURCE_FILE}" > "${TMP_FILE_2}" && \
    mv "${TMP_FILE_2}" "${SOURCE_FILE}"

# Replace sequence of symbols by \n to restore multi-line commands
sed "s/ ${NL_REPLACEMENT} /\n/g" \
    "${SOURCE_FILE}" > "${TMP_FILE_1}" && mv "${TMP_FILE_1}" "${SOURCE_FILE}"

setopt | grep extendedhistory && echo OK

grep -v '^: [0-9]\+:[0-9]\+;' zsh_history > ${TMP_FILE_1}
index=0
while read line; do
  myArray[index]="$line"
done < ${TMP_FILE_1}


IFS=$'\n' read -r -d '' -a my_array < <( grep '^\([a-z|A-Z|0-9]\{32\}$\)' "$ZSH_HISTORY_FILE" && printf '\0' )
echo ${#my_array[@]}

IFS=$'\n' array_of_lines=($( grep -v -e '^: [0-9]\+:[0-9]\+;' -e '^$' zsh_history && printf '\0' ))
my_array=("${(@f)$( grep '^\([a-z|A-Z|0-9]\{32\}$\)' "$ZSH_HISTORY_FILE" && printf '\0' )}")
