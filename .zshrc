typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR='vim'

export TERM=xterm-256color

if [ -f ~/.zshscripts ]; then
    source ~/.zshscripts
else
    print "404: ~/.zshscripts not found."
fi

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins to load?
plugins=(
          colored-man-pages
          copydir
          copyfile
          docker
          encode64
          extract
          fasd
          git
          helm
          history-sync
          k
          kubectl
          rsync
          sudo
          systemd
          terraform
          tmux
          ubuntu
          vi-mode
          web-search
          zsh-autosuggestions
          zsh-completions
          zsh-interactive-cd
          zsh-syntax-highlighting
          zsh-vi-mode
          history-substring-search
  )

source $ZSH/oh-my-zsh.sh

# User configuration

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Personal aliases
alias zshconfig="vim ~/.zshrc"
alias zshscripts="vim ~/.zshscripts"
alias vimconfig="vim ~/.vimrc"
alias rangerconfig="vim ~/.config/ranger/rc.conf"
alias zhistedit="vim ~/.zsh_history"
alias zhistclr="cat -n ${HOME}/${ZSH_HISTORY_FILE_NAME} | LC_ALL=C sort -hr | LC_ALL=C sort -t ';' -uk2 | LC_ALL=C sort -nk1 | LC_ALL=C cut -f2- > ${HOME}/${ZSH_HISTORY_FILE_NAME}_short && mv ${HOME}/${ZSH_HISTORY_FILE_NAME}_short ${HOME}/${ZSH_HISTORY_FILE_NAME}"
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR" > /dev/null 2>&1'
alias rr='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR" > /dev/null 2>&1'
alias cpmakefile="cp ${GIT_DOTFILES}/templates/Makefile ."

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
alias dksa="${DOCKER_CMD_FOR_ALIAS} stop \$(${DOCKER_CMD_FOR_ALIAS} ps -qa)"
alias dkrc="${DOCKER_CMD_FOR_ALIAS} rm \$(${DOCKER_CMD_FOR_ALIAS} container ls -qa)"
alias dkri="${DOCKER_CMD_FOR_ALIAS} rmi \$(${DOCKER_CMD_FOR_ALIAS} image ls -qa)"
alias dkreset="dksa && dkrc && dkri"
alias dk=docker

# Copy vim tags plugins (indexer, vimprj) config dir to project root
function vimprj() {
  mkdir -p .vimprj && for f in `ls -A ${GIT_DOTFILES}/Vim/.vimprj | grep -v '.indexer_files_tags'`; do cp -- ${GIT_DOTFILES}/Vim/.vimprj/$f .vimprj/$f; done
}

# enable fasd
eval "$(fasd --init auto)"

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
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS

# setopt INC_APPEND_HISTORY_TIME
# setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
export ZSH_HISTORY_FILE_NAME=".zsh_history"
export ZSH_HISTORY_FILE="${HOME}/${ZSH_HISTORY_FILE_NAME}"
export ZSH_HISTORY_PROJ="${GIT_WORKSPACE}"
export ZSH_HISTORY_FILE_ENC_NAME="zsh_history.gpg"
export ZSH_HISTORY_FILE_ENC="${ZSH_HISTORY_PROJ}/${ZSH_HISTORY_FILE_ENC_NAME}"
export GIT_COMMIT_MSG="Sync zsh history"

# re-read history file
alias re=" fc -R"

# auto correction
setopt CORRECT
setopt CORRECT_ALL

# ranger
export RANGER_LOAD_DEFAULT_RC=FALSE
export W3MIMGDISPLAY_PATH="${HOME}/.local/libexec/w3m/w3mimgdisplay"

# set vim as the default pager for man pages
export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""

# Set Bat theme
export BAT_THEME="TwoDark"

# FZF settings
# Set fzf to find hidden files but ignore .gitignored
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
# Set fzf preview options
export FZF_DEFAULT_OPTS='--height=100% --preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window=up:60%:wrap --bind=ctrl-/:toggle-preview,alt-j:preview-down,alt-k:preview-up --bind=ctrl-space:toggle+up,ctrl-d:half-page-down,ctrl-u:half-page-up'
export FZF_ALT_C_COMMAND='cd $(ls -d */ | fzf)'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Pass storage path
export PASSWORD_STORE_DIR="${GIT_WORKSPACE}/.password-store"

# Create and launch python VENV
alias activate="python3 -m venv .venv && source .venv/bin/activate"

# Generate '.clang_complete' for VIM and C/CPP projects
alias clangcomplgen='find . -type f -name "*.hpp" -o -name "*.h" | sed "s:[^/]*$::" | sort -u | sed "s/.*/-I\ &/" > .clang_complete'

# Increase keybind timeout from 1 to 50 to fix sudo plugin
export KEYTIMEOUT=50

# zsh-vi-mode plugin
# Change to Zsh's default readkey engine
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_NEX #NEW

ZVM_KEYTIMEOUT=0.4
ZVM_ESCAPE_KEYTIMEOUT=0.03
# ZVM_VI_HIGHLIGHT_BACKGROUND=red
ZVM_VI_HIGHLIGHT_BACKGROUND=#ffd200
ZVM_VI_HIGHLIGHT_FOREGROUND=#000000

ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# docker plugin
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# history-substring-search plugin
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
