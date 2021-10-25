#!/usr/bin/env bash
# Backup and restore device partitions to an image file using the dd utility.

# Define global variables
ACTION=
ANS=
ANS2=
BACKUP_PATH=
COMMAND=
IMAGES=()
INPUT_PATH=
OUTPUT_PATH=
PARTITIONS=()


# Define colors
RED='\e[1;31m'
GRN='\e[1;32m'
YEL='\e[1;33m'
BLU='\e[1;34m'
END='\e[0m' # No Color


# Define main command
COMMAND="sudo dd bs=16M status=progress"


# Clean up environment and exit
function clean_and_exit() {
    unset ACTION ANS ANS2 BACKUP_PATH END GRN RED COMMAND IMAGES INPUT_PATH \
        LAUNCH_CMD MESSAGE OUTPUT_PATH PARTITIONS
    exit "${1}"
}


# Check if the specified path exists and is a directory
function validate_path_d() {
    if [ ! -d "$1" ]; then
        echo -en "${RED}ERR:${END} Path ${RED}${1}${END} " >&2
        echo "is not a valid directory" >&2
        false
    fi
    return
}


# Check if the specified path exists and is a regular file
function validate_path_f() {
    if [ ! -f "$1" ]; then
        echo -en "${RED}ERR:${END} Path ${RED}${1}${END} " >&2
        echo "is not a valid file" >&2
        false
    fi
    return
}


# Check if the specified path exists and is a regular file
function validate_path_b() {
    if [ ! -b "$1" ]; then
        echo -en "${RED}ERR:${END} Path ${RED}${1}${END} " >&2
        echo "is not a valid block special file (device partition)" >&2
        false
    fi
    return
}


# Usage message
usage () {
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__ || true
usage: ${0} [OPTIONS]

Backup and restore device partitions to an image file using the dd utility.
Paths to target partition(s) and image name(s) are entered interactively.

OPTIONS:
  -b, --backup      Create backup of given partition(s) to an image(s)

  -r, --restore     Restore given partition(s) from an image(s)

  -p, --path        Path to backup image(s) storage


  -h, --help        Print this help message and exit
__EOM__
    echo -e "${MESSAGE}"
    return
}


# Process command line options
while [[ -n "$1" ]]; do
    case "$1" in
    -h | --help)
        usage
        clean_and_exit 0
        ;;
    -b | --backup)
        ACTION="backup"
        ;;
    -r | --restore)
        ACTION="restore"
        ;;
    -p | --path | --path=*)
        if [ "$1" = "-p" ] || [ "$1" = "--path" ]; then
            shift
            BACKUP_PATH="$1"
            validate_path_d "${BACKUP_PATH}"
        else
            BACKUP_PATH=$(echo "$1" | cut -d '=' -f 2-)
            validate_path_d "${BACKUP_PATH}"
        fi
        ;;
    *)
        usage >&2
        clean_and_exit 1
        ;;
    esac
    shift
done

# Define action if no command line parameters were passed
if [ -z "${ACTION}" ]; then
    printf "Do you want to backup or restore a partition from an image?\n"
    PS3="Please select an option: "
    options=(backup restore help)
    select menu in "${options[@]}"; do
        case $menu in
            backup)
                ACTION="backup"
                break
                ;;
            restore)
                ACTION="restore"
                break
                ;;
            help)
                usage
                clean_and_exit 0
                ;;
        esac
    done
fi
echo -en "${GRN}INF:${END} "
echo -e "Selected option: ${BLU}${ACTION}${END}"


# Define backup path if no command line parameters were passed
if [ -z "${BACKUP_PATH}" ]; then
    if [ "${ACTION}" = "backup" ]; then
        MESSAGE="to store backup image(s)"
    elif [ "${ACTION}" = "restore" ]; then
        MESSAGE="of backup image(s)"
    fi
    while true; do
        read -r -p "Please enter the path ${MESSAGE}: " BACKUP_PATH
        validate_path_d "${BACKUP_PATH}"
        if [ $? -eq 1 ]; then
            echo -en "${YEL}WRN:${END} Do you want to try again? (y|n): "
            read -r ANS
            case "${ANS}" in
            [yY] | [yY][eE][sS])
                continue
                ;;
            *)
                echo -e "${YEL}WRN:${END} Operation aborted"
                clean_and_exit 0
                ;;
            esac
        else
            break
        fi
    done
fi
echo -e "${GRN}INF:${END} Backup image(s) path: ${BLU}${BACKUP_PATH}${END}"


# Loop to input partitions and images names
while true; do
    if [ "${#PARTITIONS[@]}" -eq 0 ]; then
        ANS="yes"
    else
        echo -en "${YEL}WRN:${END} Add one more target (y|n): "
        read -r ANS
    fi
    case "${ANS}" in
    [yY] | [yY][eE][sS])
        while true; do
            read -r -p "Input full partition name in format /dev/sdXY: " ANS
            validate_path_b "${ANS}"
            if [ $? -eq 1 ]; then
                echo -en "${YEL}WRN:${END} Do you want to try again? (y|n): "
                read -r ANS
                case "${ANS}" in
                [yY] | [yY][eE][sS])
                    continue
                    ;;
                *)
                    echo -e "${YEL}WRN:${END} Operation aborted"
                    clean_and_exit 0
                    ;;
                esac
            else
                break
            fi
        done
        PARTITIONS+=("${ANS}")
        while true; do
            read -r -p "Input image file name: " ANS2
            if [ "${ACTION}" = "restore" ]; then
                validate_path_f "${BACKUP_PATH}"/"${ANS2}"
                if [ $? -eq 1 ]; then
                    echo -en "${YEL}WRN:${END} Do you want to try again? (y|n): "
                    read -r ANS2
                    case "${ANS2}" in
                    [yY] | [yY][eE][sS])
                        continue
                        ;;
                    *)
                        echo -e "${YEL}WRN:${END} Operation aborted"
                        clean_and_exit 0
                        ;;
                    esac
                fi
            fi
            break
        done
        IMAGES+=("${ANS2}")
        echo -en "${GRN}INF:${END} Added target pair: "
        echo -en "partition ${BLU}${ANS}${END}, "
        echo -e "image name ${BLU}${ANS2}${END}"
        ;;
    *)
        break
        ;;
    esac
done


# Define warning message
ANS="BE CAREFUL, ALL DATA ON TARGET PARTITIONS WILL BE COMPLETELY OVERWRITTEN"
read -r -d '' MESSAGE << __EOM__ || true
+----------------------------------------------------------------------------------+
| ${RED}!!! ${ANS} !!!${END} |
+----------------------------------------------------------------------------------+
__EOM__


# Show a message with a command queue and confirm the launch
function preview_and_confirm() {
    echo -e "${GRN}INF:${END} These operations will be performed:\n"
    for idx in "${!PARTITIONS[@]}"; do
        PART=${PARTITIONS[$idx]}
        IMG=${IMAGES[$idx]}
        if [ "${ACTION}" = "backup" ]; then
            INPUT_PATH="${PART}"
            OUTPUT_PATH="${BACKUP_PATH}"/"${IMG}"
        elif [ "${ACTION}" = "restore" ]; then
            INPUT_PATH="${BACKUP_PATH}"/"${IMG}"
            OUTPUT_PATH="${PART}"
        fi
        LAUNCH_CMD="${COMMAND} if=${INPUT_PATH} of=${OUTPUT_PATH}"
        echo -e "${YEL}${LAUNCH_CMD}${END}"
    done
    if [ "${ACTION}" = "restore" ]; then
        echo -e "\n${MESSAGE}"
    fi
    echo -en "\n${YEL}WRN:${END} Are you sure (y|n): "
    read -r ANS
    case "${ANS}" in
    [yY] | [yY][eE][sS])
        return
        ;;
    *)
        echo -e "${YEL}WRN:${END} Operation aborted"
        clean_and_exit 0
        ;;
    esac
}
preview_and_confirm


# Main loop with commands execution
for idx in "${!PARTITIONS[@]}"; do
    PART=${PARTITIONS[$idx]}
    IMG=${IMAGES[$idx]}
    if [ "${ACTION}" = "backup" ]; then
        INPUT_PATH="${PART}"
        OUTPUT_PATH="${BACKUP_PATH}"/"${IMG}"
    elif [ "${ACTION}" = "restore" ]; then
        INPUT_PATH="${BACKUP_PATH}"/"${IMG}"
        OUTPUT_PATH="${PART}"
    fi
    LAUNCH_CMD="${COMMAND} if=${INPUT_PATH} of=${OUTPUT_PATH}"
    ${LAUNCH_CMD}
done
echo -en "${GRN}INF:${END} "
echo -e "All operations completed ${GRN}successfully${END}"
