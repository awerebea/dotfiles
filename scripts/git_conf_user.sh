#!/usr/bin/env bash
# Transfer dotfiles from local host to remote using scp utility

# define users data
USER_1="awerebea (pc-home)"
EMAIL_1="awerebea.21@gmail.com"
USER_2="awerebea (laptop-acer)"
EMAIL_2="awerebea.21@gmail.com"
USER_3="Andrei Bulgakov"
EMAIL_3="awerebea.21@gmail.com"

# Usage message
usage () {
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__ || true
usage: ${0} [USERNAME] [-h|--help]
Setup git username and email for current git repository.

USERNAME:
  1         User data "${USER_1}"

  2         User data "${USER_2}"

  3         User data "${USER_3}"


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
    1)
        USERNAME="${USER_1}"
        USEREMAIL="${EMAIL_1}"
        ;;
    2)
        USERNAME="${USER_2}"
        USEREMAIL="${EMAIL_2}"
        ;;
    3)
        USERNAME="${USER_3}"
        USEREMAIL="${EMAIL_3}"
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
