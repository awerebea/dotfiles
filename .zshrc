typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR='vim'

export TERM=xterm-256color

# Install oh-my-zsh if it's not there yet.
if [[ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]]; then
  echo "\033[1;31m!!! ATTENTION !!!\033[0m"
  echo -n "\033[1;34mAfter installing \033[1;32moh-my-zsh, \033[1;34mpress "
  echo "\033[1;33mCTRL+D\033[1;34m to install custom plugins and theme.\033[0m\n"
  read -t 3 -n 1 -s -r -p "Press any key to continue"
  # backup ~/.zshrc
  backup_name=".zshrc_backup_"
  backup_name+=$(date '+%F_%H-%M-%S')
  mv ~/.zshrc ~/${backup_name}
  # install oh-my-zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  mv ~/${backup_name} ~/.zshrc
fi

# Install custom plugins if they aren't there yet.
if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/history-sync/\
history-sync.plugin.zsh ]]; then
  git clone https://github.com/wulfgarpro/history-sync.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/history-sync
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/\
zsh-autosuggestions.plugin.zsh ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions/\
zsh-completions.plugin.zsh ]]; then
  git clone https://github.com/zsh-users/zsh-completions \
    ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/\
zsh-syntax-highlighting.plugin.zsh ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode/\
zsh-vi-mode.plugin.zsh ]]; then
  git clone https://github.com/jeffreytse/zsh-vi-mode \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode
fi

# fzf-fasd
if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-fasd/\
fzf-fasd.plugin.zsh ]]; then
  git clone https://github.com/wookayin/fzf-fasd \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-fasd
fi

# fzf-tab
if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab/\
fzf-tab.plugin.zsh ]]; then
  git clone https://github.com/Aloxaf/fzf-tab \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
fi
if [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab/\
fzf-tab.plugin.zsh ]]; then
  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # switch group using `,` and `.`
  zstyle ':fzf-tab:*' switch-group ',' '.'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # preview directory's content with exa when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
fi

# Install powerlevel10k theme if it's not there yet.
if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k/\
powerlevel10k.zsh-theme ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
fi

if [ -f ~/.zshscripts ]; then
    source ~/.zshscripts
else
    print "404: ~/.zshscripts not found."
fi

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins to load?
plugins=(
          aws
          colored-man-pages
          copydir
          copyfile
          docker
          docker-compose
          encode64
          extract
          fasd
          fzf-fasd
          fzf-tab
          git
          helm
          history-sync
          kubectl
          rsync
          pass
          sudo
          systemd
          terraform
          tmux
          ubuntu
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

# update oh-my-zsh and all custom plugins
function omz-update() {
  omz update
  # Setup colors
  GREEN='\033[0;32m'
  YELLOW_BOLD='\033[1;33m'
  NC='\033[0m' # No Color
  local current_pwd="$PWD"
  echo "${GREEN}Updating OMZ custom plugins:${NC}"
  cd "$ZSH/custom/plugins"
    for plugin in *; do
      if [ -d $plugin/.git ]; then
        echo "${YELLOW_BOLD}${plugin}${NC}"
        git -C "$plugin" pull
      fi
    done
    cd "$current_pwd"
}

alias rr='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; \
  cd "$LASTDIR" > /dev/null 2>&1'
alias cpmakefile="cp ${GIT_DOTFILES}/templates/Makefile ."

# exa aliases
alias l="exa --long --all --header --links --git --icons \
  --group-directories-first --color-scale"
alias lt="exa --long --all --header --links --git --icons \
  --group-directories-first --color-scale -T"
alias ll="exa --long --header --links --git --icons --group-directories-first \
  --color-scale"
alias llt="exa --long --header --links --git --icons --group-directories-first \
  --color-scale -T"

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
alias dkc=docker-compose

# kubectl aliases
alias kg="kubectl get "
alias kgw="kubectl get -o wide "
alias kgl="kubectl get --show-labels "
alias kgwl="kubectl get -o wide --show-labels "
alias ke="kubectl edit "
alias kd="kubectl describe "

# Copy vim tags plugins (indexer, vimprj) config dir to project root
function vimprj() {
  mkdir -p .vimprj && for f in `ls -A ${GIT_DOTFILES}/Vim/.vimprj | \
    grep -v '.indexer_files_tags'`; do \
    cp -- ${GIT_DOTFILES}/Vim/.vimprj/$f .vimprj/$f; done
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
export MANPAGER="/bin/sh -c \"col -b | \
  vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""

# Set Bat theme
export BAT_THEME="TwoDark"

# FZF settings
# Set fzf to find hidden files but ignore .gitignored (search with ripgrep)
export FZF_DEFAULT_COMMAND='rg --hidden --ignore .git -g ""'
# Set fzf preview options
export FZF_DEFAULT_OPTS="--height=100% --preview \
  'bat --style=numbers --color=always --line-range :500 {}' \
  --preview-window=up:60%:hidden \
  --bind=ctrl-/:toggle-preview \
  --bind=alt-j:preview-down,alt-k:preview-up \
  --bind=alt-b:preview-page-up,alt-f:preview-page-down \
  --bind=alt-u:preview-half-page-up,alt-d:preview-half-page-down \
  --bind=alt-up:preview-top,alt-down:preview-bottom \
  --bind=ctrl-space:toggle+up \
  --bind=ctrl-d:half-page-down,ctrl-u:half-page-up \
  --bind=ctrl-f:page-down,ctrl-b:page-up"
export FZF_ALT_C_COMMAND='cd $(ls -d */ | fzf)'

# ranger filemanager plugins
# fzf_marks
export FZF_MARKS_FILE="${HOME}/.fzf-marks"
export FZF_MARKS_CMD="fzf"
export FZF_FZM_OPTS="--cycle +m --ansi --bind=ctrl-o:accept,ctrl-t:toggle --select-1"
export FZF_DMARK_OPTS="--cycle -m --ansi --bind=ctrl-o:accept,ctrl-t:toggle"
# ranger_gpg
export DEFAULT_RECIPIENT="awerebea.21@gmail.com"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Pass storage path
export PASSWORD_STORE_DIR="${GIT_WORKSPACE}/.password-store"

# Create and launch python VENV
alias activate="python3 -m venv .venv && source .venv/bin/activate"

# Generate '.clang_complete' for VIM and C/CPP projects
alias clangcomplgen='find . -type f -name "*.hpp" -o -name "*.h" | \
  sed "s:[^/]*$::" | sort -u | sed "s/.*/-I\ &/" > .clang_complete'

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
ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold

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

# check daily for plugins updates
export UPDATE_ZSH_DAYS=1
ZSH_CUSTOM_AUTOUPDATE_QUIET=true

# Automatically start tmux on remote server when logging in via SSH (and only SSH)
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi
