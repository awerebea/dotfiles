typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ $commands[nvim] ]]; then
  export EDITOR='nvim'
  alias vim="nvim"
elif [[ $commands[vim] ]]; then
  export EDITOR='vim'
elif [[ $commands[vi] ]]; then
  export EDITOR='vi'
else
  export EDITOR='nano'
fi

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
  git clone https://github.com/awerebea/history-sync.git \
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

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-marks/\
fzf-marks.plugin.zsh ]]; then
  git clone https://github.com/urbainvaes/fzf-marks \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-marks
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/notify/\
notify.plugin.zsh ]]; then
  git clone https://github.com/marzocchi/zsh-notify.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/notify
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-exa/\
zsh-exa.plugin.zsh ]]; then
  git clone https://github.com/ptavares/zsh-exa.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-exa
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/forgit/\
forgit.plugin.zsh ]]; then
  git clone https://github.com/wfxr/forgit.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/forgit
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-sed-sub/\
zsh-sed-sub.plugin.zsh ]]; then
  git clone https://github.com/MenkeTechnologies/zsh-sed-sub.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-sed-sub
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tipz/\
tipz.zsh ]]; then
  git clone https://github.com/molovo/tipz \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tipz
fi

if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tmux-vim-integration/\
tmux-vim-integration.plugin.zsh ]]; then
  git clone https://github.com/jsahlen/tmux-vim-integration.plugin.zsh.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tmux-vim-integration
fi

# terraform plugin with resource names detection
if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/terraform/\
terraform.plugin.zsh ]]; then
  git clone https://github.com/macunha1/zsh-terraform \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/terraform
fi

# kubectx
if [[ ! $commands[kubectx] ]] && \
  [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kubectx/\
kubectx.plugin.zsh ]]; then
  git clone https://github.com/unixorn/kubectx-zshplugin.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kubectx
  local current_pwd="$PWD"
  cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kubectx
  sed -i 's|git@github.com:|https://github.com/|' .gitmodules
  git submodule init
  git submodule update
  git submodule foreach git checkout \
    $(git symbolic-ref refs/remotes/origin/HEAD |
    sed 's@^refs/remotes/origin/@@')
  git submodule foreach git pull origin
  sed -i 's|https://github.com/|git@github.com:|' .gitmodules
  cd "$current_pwd"
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
  zstyle ':completion:*:git-branch:*' sort false
  # set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # switch group using `,` and `.`
  zstyle ':fzf-tab:*' switch-group ',' '.'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # preview directory's content with exa when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
fi

# kafka
if [[ ! -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kafka/\
kafka.plugin.zsh ]]; then
  git clone https://github.com/Dabz/kafka-zsh-completions.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kafka
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

# forgit plugin settings
# aliases
forgit_log=GLO
forgit_diff=GD
forgit_add=GA
forgit_reset_head=GRH
forgit_ignore=GI
forgit_checkout_file=GCF
forgit_checkout_branch=GCB
forgit_checkout_commit=GCO
forgit_clean=GCLEAN
forgit_stash_show=GSS
forgit_cherry_pick=GCP
forgit_rebase=GRB
forgit_fixup=GFU
# forgit fzf settings
export FORGIT_FZF_DEFAULT_OPTS="--height=100% --preview \
  'bat --style=numbers --color=always --line-range :500 {}' \
  --preview-window=up:60% \
  --bind=ctrl-/:toggle-preview \
  --bind=alt-j:preview-down,alt-k:preview-up \
  --bind=alt-b:preview-page-up,alt-f:preview-page-down \
  --bind=alt-u:preview-half-page-up,alt-d:preview-half-page-down \
  --bind=alt-up:preview-top,alt-down:preview-bottom \
  --bind=ctrl-space:toggle+up \
  --bind=ctrl-d:half-page-down,ctrl-u:half-page-up \
  --bind=ctrl-f:page-down,ctrl-b:page-up"

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
          forgit
          fzf-fasd
          fzf-tab
          git
          globalias
          helm
          history-sync
          kafka
          kubectl
          kubectx
          notify
          pass
          rsync
          sudo
          systemd
          terraform
          tmux
          tmux-vim-integration
          ubuntu
          web-search
          zsh-autosuggestions
          zsh-completions
          zsh-exa
          zsh-interactive-cd
          zsh-sed-sub
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
alias vless="/usr/local/share/vim/vim82/macros/less.sh"
alias cls="clear"
alias -g B='| bat -n'
alias -g G='| grep -i'
alias -g L="| less -NR"
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

# update oh-my-zsh and all custom plugins
function omz-update() {
  omz update
  # Setup colors
  GREEN='\033[0;32m'
  YELLOW_BOLD='\033[1;33m'
  NC='\033[0m' # No Color
  local current_pwd="$PWD"
  echo "${GREEN}Updating OMZ custom plugins:${NC}"
  cd "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"
    for plugin in *; do
      if [ -d $plugin/.git ]; then
        echo "${YELLOW_BOLD}${plugin}${NC}"
        git -C "$plugin" pull
        git -C "$plugin" submodule update
        git -C "$plugin" submodule foreach git checkout \
          $(git symbolic-ref refs/remotes/origin/HEAD |
          sed 's@^refs/remotes/origin/@@')
        git -C "$plugin" submodule foreach git pull origin
      fi
    done
    cd "$current_pwd"
}

# Store the alias command in a variable to prevent an error using the alias_for
# function.
rr='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`;'
rr+=' cd "$LASTDIR" > /dev/null 2>&1'
alias rr=${rr}
unset rr
alias cpmakefile="cp ${GIT_DOTFILES}/templates/Makefile ."

# exa aliases
alias l="exa --long --all --header --links --git --icons \
  --group-directories-first --color-scale"
alias lle="exa --long --all --header --links --git --icons --color=always \
  --group-directories-first --color-scale | less -NR"
alias lT="exa --long --all --header --links --git --icons \
  --group-directories-first --color-scale -T"
alias lTle="exa --long --all --header --links --git --icons --color=always \
  --group-directories-first --color-scale -T | less -NR"
alias ll="exa --long --header --links --git --icons --group-directories-first \
  --color-scale"
alias llle="exa --long --header --links --git --icons --group-directories-first \
  --color=always --color-scale | less -NR"
alias llT="exa --long --header --links --git --icons --group-directories-first \
  --color-scale -T"
alias llTle="exa --long --header --links --git --icons --group-directories-first \
  --color=always --color-scale -T | less -NR"

# docker aliases
alias dksa="${DOCKER_CMD_FOR_ALIAS} stop \$(${DOCKER_CMD_FOR_ALIAS} ps -qa)"
alias dkrc="${DOCKER_CMD_FOR_ALIAS} rm \$(${DOCKER_CMD_FOR_ALIAS} container ls -qa)"
alias dkri="${DOCKER_CMD_FOR_ALIAS} rmi \$(${DOCKER_CMD_FOR_ALIAS} image ls -qa)"
alias dkreset="dksa && dkrc && dkri"
alias dk=docker
alias dkc=docker-compose

# kubectl (k8s) aliases
alias kg="kubectl get"
alias kgy="kubectl get -o yaml"
alias kgw="kubectl get -o wide"
alias kgl="kubectl get --show-labels"
alias kgwl="kubectl get -o wide --show-labels"
alias ke="kubectl edit"
alias kd="kubectl describe"
alias kex="kubectl exec -it"
alias -g Y=" -o yaml | yh"
alias -g J=" -o json | jq"

alias kctx="kubectx"
alias kns="kubens"

# Source kubectl completion if exist
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Source stern completion if exist
[[ $commands[stern] ]] && source <(stern --completion=zsh)

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
HISTSIZE=100500
SAVEHIST=100000
setopt HIST_EXPIRE_DUPS_FIRST
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
if [[ $commands[fd] ]]; then
  FD_BIN_NAME="fd"
elif [[ $commands[fdfind] ]]; then
  FD_BIN_NAME="fdfind"
fi
if [[ ! -z ${FD_BIN_NAME} ]]; then
  export FZF_DEFAULT_COMMAND="${FD_BIN_NAME} --type file --follow --hidden --exclude .git"
else
  export FZF_DEFAULT_COMMAND='find . -type f,l -not -path "*/.git/*" | sed "s|^./||"'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

# notify (https://github.com/marzocchi/zsh-notify)
# custom title for error and success notifications
zstyle ':notify:*' error-title "Command failed (in #{time_elapsed} seconds)"
zstyle ':notify:*' success-title "Command finished (in #{time_elapsed} seconds)"
# set application name in notification
zstyle ':notify:*' app-name sh
# set a expire time in notifications
zstyle ':notify:*' expire-time 2500
# notifications icons for failure or success,
# path to an image, or an URL if you are on macOS
[[ -f /usr/share/icons/Mint-X/status/32/apport.png ]] && \
  zstyle ':notify:*' error-icon "/usr/share/icons/Mint-X/status/32/apport.png"
[[ -f /usr/share/icons/Mint-X/actions/32/gtk-ok.png ]] && \
  zstyle ':notify:*' success-icon "/usr/share/icons/Mint-X/actions/32/gtk-ok.png"
# have the terminal come back to front when the notification is posted
# zstyle ':notify:*' activate-terminal yes
# timeout for notifications for successful commands
# (notifications for failed commands are always posted)
zstyle ':notify:*' command-complete-timeout 15
# use the time elapsed even when the command fails
# (by default, command failure notifications are always displayed)
# zstyle ':notify:*' always-notify-on-failure no
# blacklist of commands that should never trigger notifications,
# using grep's extended regular expression syntax
# zstyle ':notify:*' blacklist-regex 'find|git'
# Enable when connected over SSH, which is disabled by default.
zstyle ':notify:*' enable-on-ssh yes
# force checking of the WINDOWID variable on every command
# zstyle ':notify:*' always-check-active-window yes

# history-substring-search plugin
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down
bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down

# check daily for plugins updates
export UPDATE_ZSH_DAYS=1
ZSH_CUSTOM_AUTOUPDATE_QUIET=true

# Automatically start tmux on remote server when logging in via SSH (and only SSH)
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi

# Automatically start tmux on local machine if not running yet
[[ -z "$SSH_CONNECTION" ]] && tmux info &> /dev/null || tmux

# Activate fzf-marks plugin
source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-marks/fzf-marks.plugin.zsh

# Emulate <C-o> vim behavior
vi-cmd () {
  local REPLY
  # Read the next keystroke, look it up in the `vicmd` keymap and, if successful,
  # evalute the widget bound to it in the context of the `vicmd` keymap.
  zle .read-command -K vicmd && 
      zle $REPLY -K vicmd
}
# Make a keyboard widget out of the function above.
zle -N vi-cmd
# Bind the widget to Ctrl-O in the `viins` keymap.
bindkey -v '^O' vi-cmd

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# zsh-sed-sub plugin
# keybindings to do global search and replace on current command line
# default Ctrl-F Ctrl-P
bindkey -M viins '^F^P' basicSedSub
bindkey -M vicmd '^F^P' basicSedSub

# Reveal Executed Alias
alias_for() {
  local cmd_alias=""
  [[ $1 =~ '[[:punct:]]' ]] && return
  local search=${1}
  local found="$( alias $search )"
  if [[ -n $found ]]; then
    found=${found//\\//} # Replace backslash with slash
    found=${found%\'} # Remove end single quote
    found=${found#"$search='"} # Remove alias name
    echo "${found} ${2}" | xargs # Return found value (with parameters)
  else
    echo ""
  fi
}
expand_command_line() {
  CYAN='\033[1;36m'
  BLUE='\033[0;34m'
  NC='\033[0m'
  excluded_commands=("nvim")
  first=$(echo "$1" | awk '{print $1;}')
  rest=$(echo ${${1}/"${first}"/})
  if [[ -n "${first//-//}" ]]; then # is not hypen
    full_cmd="$(alias_for "${first}")"
    # Check if expanded command string heve more than one word (have spaces)
    # to avoid alias=command output
    if [[ ! "${full_cmd}" =~ ' ' ]]; then
      full_cmd=$(cut -d "=" -f2- <<< "${full_cmd}")
    fi
    # Check if there's a command for the alias
    if [[ -n $full_cmd ]]; then # If there was
      # Check if the command is not in the exluded list
      if [[ ! "${excluded_commands[*]}" =~ "${full_cmd%% *}" ]]; then
        echo "  ${CYAN}↳${NC} ${BLUE}${full_cmd} ${NC}${rest:1}" # Print it
      fi
    fi
  fi
}
pre_validation() {
  [[ $# -eq 0 ]] && return                    # If there's no input, return. Else...
  expand_command_line "$@"
}
autoload -U add-zsh-hook                      # Load the zsh hook module.
add-zsh-hook preexec pre_validation           # Adds the hook
# add-zsh-hook -d preexec pre_validation        # Remove it for this hook.

# tipz plugin
if [[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tipz/tipz.zsh ]]; then
  source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tipz/tipz.zsh
  export TIPZ_TEXT='  \033[1;33m↳\033[0m'
fi

# globalias filter values (commands that should not be expanded)
export GLOBALIAS_FILTER_VALUES=(f z ls)

# fasd + fzf
zd() {
  fasdlist=$( fasd -d -l -R $1 | \
    fzf --query="$1" --select-1 --exit-0 --height=100% --reverse --no-sort --cycle) &&
    cd "$fasdlist"
}
zf() {
  fasdlist=$( fasd -f -l -R $1 | \
    fzf --query="$1" --select-1 --exit-0 --height=100% --reverse --no-sort --cycle) &&
    xdg-open "$fasdlist"
}
