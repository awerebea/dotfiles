#!/usr/bin/env bash

# Define colors
YEL='\e[1;33m'
GRN='\e[1;32m'
END='\e[0m' # No Color

echo -e "${YEL}Use laptop fingerprint sensor as password:${END}"
PS3=$'\n'"Choose an action, (0) to abort operation: "
options=(enable disable)
select choice in "${options[@]}";
do
    if [[ $choice == "enable" ]]; then
        sudo pam-auth-update --enable fprintd 2> /dev/null
        echo -e "Fingerprint sensor ${GRN}ENABLED${END}."
        break;
    elif [[ $choice == "disable" ]]; then
        sudo pam-auth-update --remove fprintd 2> /dev/null
        echo -e "Fingerprint sensor ${GRN}DISBLED${END}."
        break;
    elif [[ $REPLY -eq 0 ]]; then
        echo -e "Operation ${YEL}ABORTED${END}."
        break;
    else
        echo -e "\nYou picked ($REPLY), please select (1) to enable, \
(2) to disable or (0) to abort operation."
        continue
    fi
done

echo -e "\n${YEL}Promt a password by sudo command:${END}"
PS3=$'\n'"Choose an action, (0) to abort operation: "
options=(enable disable)
select choice in "${options[@]}";
do
    if [[ $choice == "enable" ]]; then
        if sudo grep -E "^$USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null
        then
            sudo sed -i \
                "s/^$USER ALL = NOPASSWD: ALL/# $USER ALL = NOPASSWD: ALL/" \
                /etc/sudoers
            echo -e "Sudo password protection ${GRN}ENABLED${END}."
        fi
        break;
    elif [[ $choice == "disable" ]]; then
        if sudo grep -E "^# $USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null
        then
            sudo sed -i \
                "s/^# $USER ALL = NOPASSWD: ALL/$USER ALL = NOPASSWD: ALL/" \
                /etc/sudoers
            echo -e "Sudo password protection ${GRN}DISABLED${END}."
        elif sudo grep -E "^$USER ALL = NOPASSWD: ALL" /etc/sudoers > /dev/null
        then
            echo -e "Sudo password protection ${GRN}DISABLED${END}."
        else
            echo "$USER ALL = NOPASSWD: ALL" | sudo tee -a /etc/sudoers
            echo -e "Sudo password protection ${GRN}DISABLED${END}."
        fi
        break;
    elif [[ $REPLY -eq 0 ]]; then
        echo -e "Operation ${YEL}ABORTED${END}."
        break;
    else
        echo -e "\nYou picked ($REPLY), please select (1) to enable, \
(2) to disable or (0) to abort operation."
        continue
    fi
done
