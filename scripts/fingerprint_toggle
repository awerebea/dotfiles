#!/usr/bin/env bash

PS3=$'\n'"Choose an action: "
options=(enable disable)
select menu in "${options[@]}";
do
    if [[ $menu == "enable" ]]; then
        sudo pam-auth-update --enable fprintd 2> /dev/null
        break;
    elif [[ $menu == "disable" ]]; then
        sudo pam-auth-update --remove fprintd 2> /dev/null
        break;
    else
        echo -e "\nYou picked ($REPLY), please select (1) to enable or (2) to disable"
        continue
    fi
done
