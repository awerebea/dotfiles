#!/usr/bin/env bash
# Transfer dotfiles from local host to remote using scp utility

# define users data
USER_0="awerebea"
EMAIL_0="awerebea.21@gmail.com"
USER_1="awerebea (pc-home)"
EMAIL_1="awerebea.21@gmail.com"
USER_2="awerebea (laptop-acer)"
EMAIL_2="awerebea.21@gmail.com"
USER_3="Andrei Bulgakov"
EMAIL_3="awerebea.21@gmail.com"
USER_4="Andrei Bulgakov"
EMAIL_4="awerebea.21@gmail.com"

# Usage message
usage () {
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__ || true
usage: ${0} [USERNAME] [-h|--help]
Setup git username and email for current git repository.

USERNAME:
  0, awerebea       User data: ${USER_0} <${EMAIL_0}>

  1, pc-home        User data: ${USER_1} <${EMAIL_1}>

  2, laptop-acer    User data: ${USER_2} <${EMAIL_2}>

  3, work           User data: ${USER_3} <${EMAIL_3}>

  4, realname       User data: ${USER_4} <${EMAIL_4}>


  -h, --help
            Print this help message and exit
__EOM__
    echo "${MESSAGE}"
    return
}

# variables list
USERNAME=
USEREMAIL=

# Process command line options
while [[ -n "$1" ]]; do
    case "$1" in
    0 | awerebea)
        USERNAME="${USER_0}"
        USEREMAIL="${EMAIL_0}"
        ;;
    1 | pc-home)
        USERNAME="${USER_1}"
        USEREMAIL="${EMAIL_1}"
        ;;
    2 | laptop-acer)
        USERNAME="${USER_2}"
        USEREMAIL="${EMAIL_2}"
        ;;
    3 | work)
        USERNAME="${USER_3}"
        USEREMAIL="${EMAIL_3}"
        ;;
    4 | realname)
        USERNAME="${USER_4}"
        USEREMAIL="${EMAIL_4}"
        ;;
    -h | --help)
        usage
        exit
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done

# check if all required arguments are specified
if [[ -z ${USERNAME} ]]; then
    usage
    exit 1;
fi


git config --local user.name "${USERNAME}"
git config --local user.email "${USEREMAIL}"

git config --list --show-origin | grep -e user.name -e user.email
