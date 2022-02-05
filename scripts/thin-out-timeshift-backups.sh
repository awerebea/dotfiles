#!/usr/bin/env bash

[ $# -lt 1 ] && echo "Not enough arguments" >&2 && exit 1

export SNAPSHOT_PATH="/media/andrei/bckp/timeshift"

# Find all links in the snapshots-hourly dir, make file dates match their names.
match-file-dates-with-file-names () {
    find "$SNAPSHOT_PATH/snapshots-hourly" -mindepth 1 -maxdepth 1 -type l \
        -print0 | xargs -0 -I '{}' sh -c 'sudo touch -h -t "$(basename {} |
        sed "s/\(.*\)-/\1\./;s/-//g;s/_//")" {}'
}
match-file-dates-with-file-names

# Find and delete all broken snapshot links
remove-broken-links () {
    find "$SNAPSHOT_PATH"  -mindepth 2 -maxdepth 2 -xtype l -print0 |
        xargs -0 sudo rm 2>/dev/null || true
}
remove-broken-links

# Conditional remove dereferenced link passed as an argument
remove-deref-link () {
    [ $# -lt 1 ] && echo "Not enough arguments" >&2 && return 1
    [ -z "$(jq -r ".comments" "$1/info.json")" ] &&
        [ ! -L "$SNAPSHOT_PATH/snapshots-boot/$(basename "$1")" ] &&
        [ ! -L "$SNAPSHOT_PATH/snapshots-daily/$(basename "$1")" ] &&
        [ ! -L "$SNAPSHOT_PATH/snapshots-weekly/$(basename "$1")" ] &&
        [ ! -L "$SNAPSHOT_PATH/snapshots-monthly/$(basename "$1")" ] &&
        [ ! -L "$SNAPSHOT_PATH/snapshots-ondemand/$(basename "$1")" ] &&
        echo -n "Removing snapshot: $(basename "$1") ... " &&
        sudo rm -rf "$(readlink "$1")" && echo "successful!"
}
export -f remove-deref-link

# Find and keep/remove every ${3}-th hourly snapshot newer than ${1} hours
# but older than ${2} hours, if it's not commented and if it's not a boot,
# daily, weekly, monthly or ondemand snapshot as well.
# Keep or remove policy is defined by ${4}.
thin-out-snapshots () {
    [ $# -lt 4 ] && echo "Not enough arguments" >&2 && return 1
    local OLD_PWD SED_ARGS
    OLD_PWD="$PWD"
    cd "$SNAPSHOT_PATH/snapshots-hourly" || return 1
    if [ "$4" == "keep" ]; then
        SED_ARGS=("1~$3d")
    elif [ "$4" == "remove" ]; then
        SED_ARGS=(-n "0~$3p")
    fi
    find . -mindepth 1 -maxdepth 1 -type l \
        -mmin "-$(echo "$1 * 60" | bc)" -mmin "+$(echo "$2 * 60" | bc)" \
        -printf '%h\0%d\0%p\n' | sort -t '\0' -n | awk -F'\0' '{print $3}' | \
        sed ${SED_ARGS[*]} | xargs -I '{}' bash -c 'remove-deref-link "{}"' _
    remove-broken-links
    cd "$OLD_PWD" || return 1
}

# Check if snapshot history limit exceeded
snapshot-history-limit-exceeded () {
    [ $# -lt 1 ] && echo "Not enough arguments" >&2 && return 1
    if [ "$(find "$SNAPSHOT_PATH/snapshots-hourly" -mindepth 1 -maxdepth 1 \
        -type l -printf '%h\0%d\0%p\n' | sort -t '\0' -n | \
        awk -F'\0' '{print $3}' | wc -l)" -gt "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Thin out every given time slice in a given interval
thin-out-time-slice-in-interval () {
    [ $# -lt 6 ] && echo "Not enough arguments" >&2 && return 1
    for INTRVL in $(seq "$2" "$3" "$4"); do
        if snapshot-history-limit-exceeded "$1"; then
            thin-out-snapshots "$INTRVL" "$(echo "$INTRVL + $3" | bc)" "$5" "$6"
        else
            break;
        fi
    done
}

thin-out-time-slice-in-interval "$1" 241 -4 53 2 remove
thin-out-time-slice-in-interval "$1" 241 -8 53 2 remove

# Truncate hourly snapshot history to limit
truncate-hourly-snapshots () {
    [ $# -lt 1 ] && echo "Not enough arguments" >&2 && return 1
    local SNAPSHOT
    for SNAPSHOT in "$SNAPSHOT_PATH"/snapshots-hourly/*; do
        if snapshot-history-limit-exceeded "$1"; then
            remove-deref-link "$SNAPSHOT"
            remove-broken-links
        else
            break
        fi
    done
}

truncate-hourly-snapshots "$1"
