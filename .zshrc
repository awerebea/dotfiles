# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# ZSH_DISABLE_COMPFIX="true"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

if [[ `uname -n` == *"21-school"* ]]; then
  # School
  export ZSH="/Users/awerebea/.oh-my-zsh"
  export DOCKER_CMD_FOR_ALIAS="docker"
  export GIT_DOTFILES="/Users/awerebea/Documents/Github/dotfiles"
  export GIT_WORKSPACE="/Users/awerebea/Documents/Github/workspace"
  alias norminette='/Users/awerebea/.scripts/colorised_norm.sh'
  alias o='a -e open' # quick opening files with open
  google() {
    search=""
    for term in $@; do
    search="$search%20$term"
    done
    open "http://www.google.com/search?q=$search" >/dev/null 2>&1
  }

  PATH=~/.local/bin:$PATH
  PATH=~/Library/Python/2.7/bin:$PATH
  source $HOME/.brewconfig.zsh
  alias ffoxprofile='/Volumes/Firefox/Firefox.app/Contents/MacOS/firefox-bin -P'
  alias ffox='open -n -a /Volumes/Firefox/Firefox.app --args -P awerebea'
  alias init_docker=". ${HOME}/42toolbox/init_docker.sh"
  alias settings_init=". ${HOME}/Documents/Github/dotfiles/school/init_school_settings.sh"
  alias init_minikube=". ${HOME}/Documents/Github/dotfiles/school/init_minikube.sh"
elif [[ `uname -n` == "pc-home" ]] || [[ `uname -n` == "laptop-acer" ]]; then
  os=`uname`
  if [[ `uname` == "Linux" ]]; then
    # Home Manjaro
    export ZSH="/home/andrei/.oh-my-zsh"
    export DOCKER_CMD_FOR_ALIAS="sudo docker"
    export GIT_DOTFILES="/run/media/andrei/awerebea/Github/dotfiles"
    export GIT_WORKSPACE="/run/media/andrei/awerebea/Github/workspace"
    alias norminette='/home/andrei/.config/.scripts/colorised_norm.sh'
    alias o='a -e xdg-open >/dev/null 2>&1' # quick opening files with xdg-open
    google() {
      search=""
      for term in $@; do
      search="$search%20$term"
      done
      xdg-open "http://www.google.com/search?q=$search" >/dev/null 2>&1
    }

    alias open='xdg-open >/dev/null 2>&1' # quick opening files with xdg-open
    alias tmpunlink="sudo rm -f /var/tmp && sleep 1 && sudo mkdir /var/tmp"
    alias tmprelink="sudo rm -rf /var/tmp && sleep 1 && sudo ln -s /run/media/andrei/Data/Temp-lin/var/tmp/ /var/tmp"
    # The 1st command is to map CAPSLOCK to ESC whereas the 2nd one takes care of CTRL pressed with other keys
    # setxkbmap -option ctrl:nocaps
    # xcape -e 'Control_L=Escape'
  elif [[ `uname` == "Darwin" ]]; then
    # Home macOS
    export ZSH="/Users/andrei/.oh-my-zsh"
    export DOCKER_CMD_FOR_ALIAS="docker"
    export GIT_DOTFILES="/Volumes/awerebea/Github/dotfiles"
    export GIT_WORKSPACE="/Volumes/awerebea/Github/workspace"
    alias norminette='/Users/andrei/.scripts/colorised_norm.sh'
    alias o='a -e open' # quick opening files with open
    google() {
      search=""
      for term in $@; do
      search="$search%20$term"
      done
      open "http://www.google.com/search?q=$search" >/dev/null 2>&1
    }

    alias keesync="cp -f /Volumes/Data/Distrib/_Personal\ Software/KeePass/keepass_Andrei.kdbx ~/Google\ Drive/Mobile/Keepass/"
    alias sudoedit="sudo vim"
  fi
else
  export ZSH="$HOME/.oh-my-zsh"
  export GIT_DOTFILES="$HOME/Github/dotfiles"
  export GIT_WORKSPACE="$HOME/Github/workspace"
  alias o='a -e xdg-open >/dev/null 2>&1' # quick opening files with xdg-open
  google() {
    search=""
    for term in $@; do
    search="$search%20$term"
    done
    xdg-open "http://www.google.com/search?q=$search" >/dev/null 2>&1
  }

  alias open='xdg-open >/dev/null 2>&1' # quick opening files with xdg-open
fi


# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins to load?
plugins=(\
          colored-man-pages \
          git \
          history-substring-search \
          history-sync \
          k \
          sudo \
          tmux \
          vi-mode \
          zsh-autosuggestions \
          zsh-completions \
          zsh-syntax-highlighting \
  )

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# blinking block
printf '\e[1 q'
# steady block
# printf '\e[2 q'
# blinking underscore
# printf '\e[3 q'
# steady underscore
# printf '\e[4 q'
# blinking bar
# printf '\e[5 q'
# steady bar
# printf '\e[6 q'

#export WINEPREFIX=/run/media/andrei/Data/Distrib/Linux/Apps/wine/
#export WINEPREFIX=/home/andrei/.wine/
#export WINEARCH=win32


# Personal aliases
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.vimrc"
alias rangerconfig="vim ~/.config/ranger/rc.conf"
alias zhistedit="vim ~/.zsh_history"
alias zhistclr="cat -n ${HOME}/${ZSH_HISTORY_FILE_NAME} | LC_ALL=C sort -hr | LC_ALL=C sort -t ';' -uk2 | LC_ALL=C sort -nk1 | LC_ALL=C cut -f2- > ${HOME}/${ZSH_HISTORY_FILE_NAME}_short && mv ${HOME}/${ZSH_HISTORY_FILE_NAME}_short ${HOME}/${ZSH_HISTORY_FILE_NAME}"
# alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR" > /dev/null 2>&1'
alias rr='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR" > /dev/null 2>&1'

alias cls="clear"
alias -g G='| grep -i'
alias dir='dirs -v | head -20'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
alias 10='cd -10'
alias 11='cd -11'
alias 12='cd -12'
alias 13='cd -13'
alias 14='cd -14'
alias 15='cd -15'
alias 16='cd -16'
alias 17='cd -17'
alias 18='cd -18'
alias 19='cd -19'

# docker aliases
alias dcksa="${DOCKER_CMD_FOR_ALIAS} stop \$(${DOCKER_CMD_FOR_ALIAS} ps -qa)"
alias dckrc="${DOCKER_CMD_FOR_ALIAS} rm \$(${DOCKER_CMD_FOR_ALIAS} container ls -qa)"
alias dckri="${DOCKER_CMD_FOR_ALIAS} rmi \$(${DOCKER_CMD_FOR_ALIAS} image ls -qa)"
alias dckreset="dcksa && dckrc && dckri"

# Copy vim tags plugins (indexer, vimprj) config dir to project root
function vimprj() {
  mkdir -p .vimprj && for f in `ls -A ${GIT_DOTFILES}/Vim/.vimprj | grep -v '.indexer_files_tags'`; do cp -- ${GIT_DOTFILES}/Vim/.vimprj/$f .vimprj/$f; done
}

# fix oh-my-zsh history-sync plugin
function zhistsyncplugfix() {
  sed -i "s/add\ \*/\"\$ZSH_HISTORY_FILE_ENC_NAME\"/" $ZSH/custom/plugins/history-sync/history-sync.plugin.zsh
  sed -i "s/GIT_COMMIT_MSG=\"latest \$(date)\"/GIT_COMMIT_MSG=\"Sync\ zsh\ history\"/" $ZSH/custom/plugins/history-sync/history-sync.plugin.zsh
  export GIT_COMMIT_MSG="Sync zsh history"
}

# fasd history sync via GitHub
function fhistsync() {
  echo "\e[1;33mNeed to pull before sync? (y/N)\e[0m"
  while true; do
    read -r input
    case $input in
        [yY][eE][sS]|[yY])
     git -C ${GIT_WORKSPACE} pull; break;;
        [nN][oO]|[nN])
     echo "\e[1;33mLocal file used\e[0m"; break;;
        *)
     echo "\e[1;33mIncorrect input. Need to pool? Answer: \e[1;32mYes\e[1;33m/\e[1;31mNo \e[1;32my\e[1;33m/\e[1;31mn \e[1;32mY\e[1;33m/\e[1;31mN\e[0m";;
    esac
  done
  cat ${HOME}/.fasd >> ${GIT_WORKSPACE}/.fasd
  cat ${GIT_WORKSPACE}/.fasd | sort -t $'\|' -rk2 | awk -F"[|]" '!a[$1]++' > ${GIT_WORKSPACE}/.fasd_
  rm -f ${GIT_WORKSPACE}/.fasd ${HOME}/.fasd
  mv ${GIT_WORKSPACE}/.fasd_ ${GIT_WORKSPACE}/.fasd
  cp -rf ${GIT_WORKSPACE}/.fasd ${HOME}/.fasd
  git -C ${GIT_WORKSPACE} add .fasd
  git -C ${GIT_WORKSPACE} commit -m "Sync fasd history"
  echo "\e[1;33mfasd synced history commited, need to push? (y/N)\e[0m"
  while true; do
    read -r input
    case $input in
        [yY][eE][sS]|[yY])
     git -C ${GIT_WORKSPACE} push origin; break;;
        [nN][oO]|[nN])
     break;;
        *)
     echo "\e[1;33mIncorrect input. Need to push? Answer: \e[1;32mYes\e[1;33m/\e[1;31mNo \e[1;32my\e[1;33m/\e[1;31mn \e[1;32mY\e[1;33m/\e[1;31mN\e[0m";;
    esac
  done
}

# tmux ressurection layout sync via GitHub
function trb() {
  cp ~/.tmux/resurrect/last ${GIT_WORKSPACE}/tmux_ressurection_backup.txt
  git -C ${GIT_WORKSPACE} add tmux_ressurection_backup.txt
  git -C ${GIT_WORKSPACE} commit -m "Backup tmux ressurect"
  echo "\e[1;33mtmux ressurect backup commited, need to push? (y/N)\e[0m"
  while true; do
    read -r input
    case $input in
        [yY][eE][sS]|[yY])
     git -C ${GIT_WORKSPACE} push origin; break;;
        [nN][oO]|[nN])
     break;;
        *)
     echo "\e[1;33mIncorrect input. Need to push? Answer: \e[1;32mYes\e[1;33m/\e[1;31mNo \e[1;32my\e[1;33m/\e[1;31mn \e[1;32mY\e[1;33m/\e[1;31mN\e[0m";;
    esac
  done
}

function trr() {
  echo "\e[1;33mNeed to pull before restore? (y/N)\e[0m"
  while true; do
    read -r input
    case $input in
        [yY][eE][sS]|[yY])
     git -C ${GIT_WORKSPACE} pull; break;;
        [nN][oO]|[nN])
     echo "\e[1;33mLocal file used\e[0m"; break;;
        *)
     echo "\e[1;33mIncorrect input. Need to pool? Answer: \e[1;32mYes\e[1;33m/\e[1;31mNo \e[1;32my\e[1;33m/\e[1;31mn \e[1;32mY\e[1;33m/\e[1;31mN\e[0m";;
    esac
  done
  tmp_file="${GIT_WORKSPACE}/tmux_ressurection_backup.tmp"
  cp ${GIT_WORKSPACE}/tmux_ressurection_backup.txt $tmp_file
  home_school="\/Users\/awerebea"
  home_pc_home_linux="\/home\/andrei"
  home_pc_home_mac="\/Users\/andrei\/"
  projects_school="\/Users\/awerebea\/projects"
  projects_pc_home_linux="\/run\/media\/andrei\/awerebea\/school-21\/projects"
  projects_pc_home_mac="\/Volumes\/awerebea\/school-21\/projects"
  documents_school="\/Users\/awerebea\/Documents"
  documents_pc_home_linux="\/run\/media\/andrei\/Data\/Documents"
  documents_pc_home_mac="\/Volumes\/Data\/Documents"
  github_school="\/Users\/awerebea\/Documents\/Github"
  github_pc_home_linux="\/run\/media\/andrei\/awerebea\/Github"
  github_pc_home_mac="\/Volumes\/awerebea\/Github\/"
  rm -f ~/.tmux/resurrect/last
  if [[ `uname -n` == *"21-school"* ]]; then
    sed -i '' "s/$github_pc_home_linux/$github_school/" $tmp_file
    sed -i '' "s/$documents_pc_home_linux/$documents_school/" $tmp_file
    sed -i '' "s/$projects_pc_home_linux/$projects_school/" $tmp_file
    sed -i '' "s/$home_pc_home_linux/$home_school/" $tmp_file

    sed -i '' "s/$github_pc_home_mac/$github_school/" $tmp_file
    sed -i '' "s/$documents_pc_home_mac/$documents_school/" $tmp_file
    sed -i '' "s/$projects_pc_home_mac/$projects_school/" $tmp_file
    sed -i '' "s/$home_pc_home_mac/$home_school/" $tmp_file
  elif [[ `uname -n` == "pc-home" ]]; then
    if [[ `uname` == "Linux" ]]; then
      sed -i "s/$github_school/$github_pc_home_linux/" $tmp_file
      sed -i "s/$documents_school/$documents_pc_home_linux/" $tmp_file
      sed -i "s/$projects_school/$projects_pc_home_linux/" $tmp_file
      sed -i "s/$home_school/$home_pc_home_linux/" $tmp_file

      sed -i "s/$github_pc_home_mac/$github_pc_home_linux/" $tmp_file
      sed -i "s/$documents_pc_home_mac/$documents_pc_home_linux/" $tmp_file
      sed -i "s/$projects_pc_home_mac/$projects_pc_home_linux/" $tmp_file
      sed -i "s/$home_pc_home_mac/$home_pc_home_linux/" $tmp_file
    elif [[ `uname` == "Darwin" ]]; then
      sed -i '' "s/$github_school/$github_pc_home_mac/" $tmp_file
      sed -i '' "s/$documents_school/$documents_pc_home_mac/" $tmp_file
      sed -i '' "s/$projects_school/$projects_pc_home_mac/" $tmp_file
      sed -i '' "s/$home_school/$home_pc_home_mac/" $tmp_file

      sed -i '' "s/$github_pc_home_linux/$github_pc_home_mac/" $tmp_file
      sed -i '' "s/$documents_pc_home_linux/$documents_pc_home_mac/" $tmp_file
      sed -i '' "s/$projects_pc_home_linux/$projects_pc_home_mac/" $tmp_file
      sed -i '' "s/$home_pc_home_linux/$home_pc_home_mac/" $tmp_file
    fi
  fi
  mv $tmp_file ~/.tmux/resurrect/tmux_ressurection_restore.txt
  ln -s ~/.tmux/resurrect/tmux_ressurection_restore.txt ~/.tmux/resurrect/last
}

# enable fasd
eval "$(fasd --init auto)"
alias v='f -e vim' # quick opening files with vim

# git add all changed files and commit
function gac() {
  git add .
  git commit -m "$1"
}
# git add all changed files, commit and push
function gacp() {
  git add .
  git commit -m "$1"
  git push
}

# zsh_history settings and sync via GitHub
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
export ZSH_HISTORY_FILE_NAME=".zsh_history"
export ZSH_HISTORY_FILE="${HOME}/${ZSH_HISTORY_FILE_NAME}"
export ZSH_HISTORY_PROJ="${GIT_WORKSPACE}"
export ZSH_HISTORY_FILE_ENC_NAME="zsh_history.gpg"
export ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"
export GIT_COMMIT_MSG="Sync zsh history"

# "Forget" last N commands from history
# Put a space at the start of a command to make sure it doesn't get added to the history.
alias frgt=' my_remove_last_history_entry' # Added a space in 'my_remove_last_history_entry' so that zsh forgets the 'forget' command :).
my_remove_last_history_entry() {
    # This sub-function checks if the argument passed is a number.
    # Thanks to @yabt on stackoverflow for this :).
    is_int() ( return $(test "$@" -eq "$@" > /dev/null 2>&1); )
    # Set history file's location
    history_file="${ZSH_HISTORY_FILE}"
    history_temp_file="${history_file}.tmp"
    # Check if the user passed a number, so we can delete N lines from history.
    if [ $# -eq 0 ]; then
        # No arguments supplied, so set to one.
        lines_to_remove=1
    else
        # An argument passed. Check if it's a number.
        if $(is_int "${1}"); then
            lines_to_remove="$1"
        else
            echo "Unknown argument passed. Exiting..."
            return
        fi
    fi
    # fc -W # write current shell's history to the history file.
    sed "$(($(wc -l < $history_file)-$lines_to_remove + 1)),\$d" $history_file > $history_temp_file 2>/dev/null
    mv "$history_temp_file" "$history_file"
    fc -R # read history file.
}
# re-read history file
alias re=" fc -R"

# auto correction
setopt CORRECT
setopt CORRECT_ALL

# ranger
export RANGER_LOAD_DEFAULT_RC=FALSE
export W3MIMGDISPLAY_PATH="${HOME}/.local/libexec/w3m/w3mimgdisplay"

# create git hooks for ctags tags update
function githooksctags() {
  touch -a .git/hooks/post-checkout
  grep -qxF '#!/bin/bash' .git/hooks/post-checkout || echo "#!/bin/bash" >> .git/hooks/post-checkout
  grep -qxF 'ctags -R --fields=+l --tag-relative=yes --exclude=.git --exclude=.gitignore --exclude=@.gitignore --exclude=@.ctagsignore -f .git/tags 2>/dev/null' .git/hooks/post-checkout || echo "ctags -R --fields=+l --tag-relative=yes --exclude=.git --exclude=.gitignore --exclude=@.gitignore --exclude=@.ctagsignore -f .git/tags 2>/dev/null" >> .git/hooks/post-checkout
  chmod +x .git/hooks/post-checkout
  touch -a .git/hooks/post-commit
  grep -qxF '#!/bin/bash' .git/hooks/post-commit || echo "#!/bin/bash" >> .git/hooks/post-commit
  grep -qxF 'ctags -R --fields=+l --tag-relative=yes --exclude=.git --exclude=.gitignore --exclude=@.gitignore --exclude=@.ctagsignore -f .git/tags 2>/dev/null' .git/hooks/post-commit || echo "ctags -R --fields=+l --tag-relative=yes --exclude=.git --exclude=.gitignore --exclude=@.gitignore --exclude=@.ctagsignore -f .git/tags 2>/dev/null" >> .git/hooks/post-commit
  chmod +x .git/hooks/post-commit
}

# set vim as the default pager for man pages
export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""

# set tab stop 4 for shell commands by default
# tabs -4

## bash and zsh only!
# functions to cd to the next or previous sibling directory, in glob order

prev () {
  # default to current directory if no previous
  local prevdir="./"
  local cwd=${PWD##*/}
  if [[ -z $cwd ]]; then
    # $PWD must be /
    echo 'No previous directory.' >&2
    return 1
  fi
  for x in ../*/; do
    if [[ ${x#../} == ${cwd}/ ]]; then
      # found cwd
      if [[ $prevdir == ./ ]]; then
        echo 'No previous directory.' >&2
        return 1
      fi
      cd "$prevdir"
      return
    fi
    if [[ -d $x ]]; then
      prevdir=$x
    fi
  done
  # Should never get here.
  echo 'Directory not changed.' >&2
  return 1
}

next () {
  local foundcwd=
  local cwd=${PWD##*/}
  if [[ -z $cwd ]]; then
    # $PWD must be /
    echo 'No next directory.' >&2
    return 1
  fi
  for x in ../*/; do
    if [[ -n $foundcwd ]]; then
      if [[ -d $x ]]; then
        cd "$x"
        return
      fi
    elif [[ ${x#../} == ${cwd}/ ]]; then
      foundcwd=1
    fi
  done
  echo 'No next directory.' >&2
  return 1
}
