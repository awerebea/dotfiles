#!/usr/bin/env bash
# Transfer dotfiles from local host to remote using scp utility

# define filenames to transfer
FILES_VIM=".vimrc"
FILES_ZSH=(".zshrc" ".zshscripts" ".p10k.zsh")
FILES_TMUX=(".tmux.conf" ".tmux.conf.local")
FILES_RANGER="ranger"

# Usage message
usage () {
    local MESSAGE=
    read -r -d '' MESSAGE << __EOM__ || true
usage: ${0} [OPTIONS] [SSH-OPTIONS] [USERNAME@]HOSTNAME
Transfer dotfiles from local host to remote using scp utility

SSH-OPTIONS Any valid modifiers for the scp command, type 'man scp' for more
            information.

USERNAME    Username on the remote machine, if not specified, the name is used
            by the local user

HOSTNAME    IP or DNS name of the remote host, required

OPTIONS:
  all       Copy ALL main dotfiles

  vim       Copy ${FILES_VIM}

  nvim      Copy ${FILES_VIM} and create symlink to ~/.config/nvim/init.vim

  zsh       Copy ${FILES_ZSH[@]}

  tmux      Copy ${FILES_TMUX[@]}

  ranger    Copy ${FILES_RANGER} directory to the ~/.config/
            and create symlinks to all ranger scripts in ~/.local/bin

  -h, --help
            Print this help message and exit

Note: HOSTNAME and at least one OPTION are required
__EOM__
    echo "${MESSAGE}"
    return
}

# variables list
VIM=
NVIM=
ZSH=
TMUX=
RANGER=
SSH_DATA=

# Process command line options
while [[ -n "$1" ]]; do
    case "$1" in
    all)
        VIM="${FILES_VIM}"
        NVIM="1"
        ZSH=("${FILES_ZSH[@]}")
        TMUX=("${FILES_TMUX[@]}")
        RANGER="${FILES_RANGER}"
        ;;
    vim)
        VIM="${FILES_VIM}"
        ;;
    nvim)
        VIM="${FILES_VIM}"
        NVIM="1"
        ;;
    zsh)
        ZSH=("${FILES_ZSH[@]}")
        ;;
    tmux)
        TMUX=("${FILES_TMUX[@]}")
        ;;
    ranger)
        RANGER="${FILES_RANGER}"
        ;;
    -h | --help)
        usage
        exit
        ;;
    *)
        SSH_DATA+=" ${1}"
    ;;
    esac
    shift
done

# functions to split ssh data to options and ssh host
get_ssh_opts() {
    echo "${@:1:$#-1}"
}
get_ssh_host() {
    echo "${@: -1}"
}

# get ssh options and host from the SSH_DATA variable
SSH_OPTS=$(get_ssh_opts "${SSH_DATA}")
SSH_HOST=$(get_ssh_host "${SSH_DATA}")

# check if all required arguments are specified
if [[ -z ${VIM} ]] && [[ -z ${ZSH[*]} ]] \
    && [[ -z ${TMUX[*]} ]] && [[ -z ${RANGER} ]] || [[ -z ${SSH_DATA} ]]; then
    usage
    exit 1;
fi

# backup current working directory path
CWD_BCKP=$(pwd)

# cd to the dotfiles directory
cd "${GIT_DOTFILES}" || exit 1

# generate a random name for file archive
ARC_NAME=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)

# pack files for transfer to a remote host into one archive
tar -czf "${ARC_NAME}".tar.gz --transform 's,^ranger,.config/ranger,' \
    ${VIM} "${ZSH[@]}" "${TMUX[@]}" ${RANGER}

# copy archive to the remote host
scp "${SSH_OPTS}" "${ARC_NAME}".tar.gz "${SSH_HOST}":~
result=$?

# remove archive from local host
rm -f "${ARC_NAME}".tar.gz
[ "${result}" -ne 0 ] && exit ${result}

# create directories on the remote host if needed
[[ -n ${NVIM} ]] && NVIM_HANDLING="&& mkdir -p ~/.config/nvim && \
    ln -s ~/.vimrc ~/.config/nvim/init.vim"
[[ -n ${RANGER} ]] && RANGER_HANDLING="&& mkdir -p ~/.local/bin && \
    ln -s ~/.config/ranger/scripts/* ~/.local/bin/"
# launch commands on the remote host
ssh -t "${SSH_OPTS}" "${SSH_HOST}" "tar -xf ${ARC_NAME}.tar.gz && \
    rm -f ${ARC_NAME}.tar.gz ${NVIM_HANDLING} ${RANGER_HANDLING}"

# cd to the previous location
cd "${CWD_BCKP}" || exit 1
echo "All done!"
