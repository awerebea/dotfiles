# Enable the subsequent settings only in interactive sessions
case $- in
*i*) ;;
*) return ;;
esac

# Path to your oh-my-bash installation.
export OSH="/home/$USER/.oh-my-bash"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
# shellcheck disable=2034
THEME_SHOW_SUDO="fasle"

if ! command -v "aliae" &>/dev/null; then
    curl -s https://aliae.dev/install.sh | bash -s -- -d "$HOME"/.local/bin
else
    eval "$(aliae init bash --config "$HOME"/.aliae.yaml)"
fi

# Uncomment the following line to use case-sensitive completion.
# OMB_CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# shellcheck disable=2034
OMB_HYPHEN_SENSITIVE="false"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_OSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# shellcheck disable=2034
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# shellcheck disable=2034
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you don't want the repository to be considered dirty
# if there are untracked files.
# shellcheck disable=2034
SCM_GIT_DISABLE_UNTRACKED_DIRTY="true"

# Uncomment the following line if you want to completely ignore the presence
# of untracked files in the repository.
# SCM_GIT_IGNORE_UNTRACKED="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.  One of the following values can
# be used to specify the timestamp format.
# * 'mm/dd/yyyy'     # mm/dd/yyyy + time
# * 'dd.mm.yyyy'     # dd.mm.yyyy + time
# * 'yyyy-mm-dd'     # yyyy-mm-dd + time
# * '[mm/dd/yyyy]'   # [mm/dd/yyyy] + [time] with colors
# * '[dd.mm.yyyy]'   # [dd.mm.yyyy] + [time] with colors
# * '[yyyy-mm-dd]'   # [yyyy-mm-dd] + [time] with colors
# If not set, the default value is 'yyyy-mm-dd'.
# HIST_STAMPS='yyyy-mm-dd'

# Uncomment the following line if you do not want OMB to overwrite the existing
# aliases by the default OMB aliases defined in lib/*.sh
# shellcheck disable=2034
OMB_DEFAULT_ALIASES="check"

# Would you like to use another custom folder than $OSH/custom?
# OSH_CUSTOM=/path/to/new-custom-folder

# To disable the uses of "sudo" by oh-my-bash, please set "false" to
# this variable.  The default behavior for the empty value is "true".
# shellcheck disable=2034
OMB_USE_SUDO=true

# To enable/disable display of Python virtualenv and condaenv
# shellcheck disable=2034
OMB_PROMPT_SHOW_PYTHON_VENV=true # enable
# OMB_PROMPT_SHOW_PYTHON_VENV=false # disable

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
# shellcheck disable=2034
completions=(
    awscli
    brew
    composer
    defaults
    dirs
    docker
    git
    makefile
    pip
    pip3
    projects
    rake
    ssh
    system
    terraform
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
# Custom aliases may be added to ~/.oh-my-bash/custom/aliases/
# Example format: aliases=(vagrant composer git-avh)
# Add wisely, as too many aliases slow down shell startup.
# shellcheck disable=2034
aliases=(
    chmod
    docker
    general
    ls
    misc
    package-manager
    terraform
)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# shellcheck disable=2034
plugins=(
    git
    bashmarks
    progress
    sudo
)

# Which plugins would you like to conditionally load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format:
#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

# shellcheck disable=1091
source "$OSH"/oh-my-bash.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-bash libs,
# plugins, and themes. Aliases can be placed here, though oh-my-bash
# users are encouraged to define aliases within the OSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias bashconfig="mate ~/.bashrc"
# alias ohmybash="mate ~/.oh-my-bash"

# My previous settings
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

if command -v "direnv" &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# Add neovim installation path, installed by bob
# https://github.com/MordechaiHadad/bob
if [ -d "$HOME/.local/share/bob/nvim-bin" ] &&
    [[ ":$PATH:" != *":$HOME/.local/share/bob/nvim-bin:"* ]]; then
    export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
fi

# Add neovim installation path, installed manually from release page
# https://github.com/neovim/neovim/releases
if [ -d "$HOME/.local/share/nvim-release/bin" ] &&
    [[ ":$PATH:" != *":$HOME/.local/share/nvim-release/bin:"* ]]; then
    export PATH="$HOME/.local/share/nvim-release/bin:$PATH"
fi

# Define default editor nvim, vim, vi or nano
if command -v "nvim" &>/dev/null; then
    export EDITOR='nvim'
    alias vimdiff="nvim -d"
    # alias vim="nvim"
elif command -v "vim" &>/dev/null; then
    export EDITOR='vim'
elif command -v "vi" &>/dev/null; then
    export EDITOR='vi'
else
    export EDITOR='nano'
fi

export TERM=xterm-256color

# shellcheck disable=1091
[ -f ~/.fzf.bash ] && source "$HOME"/.fzf.bash
# shellcheck disable=1091
[ -f ~/fzf-marks/fzf-marks.plugin.bash ] && source "$HOME"/fzf-marks/fzf-marks.plugin.bash

if [ -d "$HOME/.local/bin" ] &&
    [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# shellcheck disable=2139
alias v="$EDITOR"

# Repeat given char N times using shell function
rep() {
    local start=1
    local end=${1:-80}
    local str="${2:-=}"
    eval "printf '$str%0.s' {$start..$end}"
}

# Go to the given number of levels up
up() {
    local num=${1:-1}
    if [[ ! $num =~ ^[0-9]+$ ]]; then
        echo "Invalid input of the number of levels to go up."
        return
    fi
    eval "$(
        echo -n 'cd '
        rep "$num" '../'
    )"
}

# Store the terraform cache in a shared directory between all projects
if command -v "terraform" &>/dev/null; then
    tf_cache_path="$HOME/.cache/tf-plugins-cache"
    [ -d "$tf_cache_path" ] || mkdir -p "$tf_cache_path"
    export TF_PLUGIN_CACHE_DIR="$tf_cache_path"
    unset tf_cache_path
fi

if command -v "aws-vault" &>/dev/null; then
    export AWS_VAULT_BACKEND=file
fi

command -v "terraform" &>/dev/null && alias tf="terraform"
command -v "terragrunt" &>/dev/null && alias tg="terragrunt"

alias activate="python3.11 -m venv .venv && source .venv/bin/activate"

# shellcheck disable=2139
alias c="eval ${VSCODE_GIT_ASKPASS_NODE%/node}/bin/remote-cli/code"
# shellcheck disable=2139
alias vf="fd --type f --hidden --exclude .git | fzf --reverse | xargs -o $EDITOR"
# shellcheck disable=2139
alias cf="fd --type f --hidden --exclude .git | fzf --reverse | xargs ${VSCODE_GIT_ASKPASS_NODE%/node}/bin/remote-cli/code"

alias rr='ranger --choosedir=$HOME/.rangerdir; cd "$(cat $HOME/.rangerdir)" > /dev/null 2>&1'

command -v "trash" &>/dev/null && alias rm="trash-put"

# Define eza aliases conditionally
if command -v "eza" &>/dev/null; then
    alias l="eza --long --all --header --links --git --icons --color=always \
    --group-directories-first --color-scale"
    alias lle="eza --long --all --header --links --git --icons --color=always \
    --group-directories-first --color-scale | less -NR"
    alias lT="eza --long --all --header --links --git --icons --color=always \
    --group-directories-first --color-scale --tree"
    alias ll="eza --long --header --links --git --icons --color=always \
    --group-directories-first --color-scale"
    alias llT="eza --long --header --links --git --icons --color=always \
    --group-directories-first --color-scale --tree"
fi

# Load nvm if exists
if [ -d "$HOME/.nvm" ]; then
    [ "$NVM_DIR" = "" ] && export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Load rbenv if exists
if [ -d "$HOME/.rbenv/bin" ]; then
    if [[ ":$PATH:" != *":$HOME/.rbenv/bin:"* ]]; then
        export PATH="$PATH:$HOME/.rbenv/bin"
    fi
    eval "$(rbenv init - bash)"
fi
# Setup ruby environment
export_all_ruby_versions_bin_dirs() {
    local version versions
    if [ -d "$HOME/.rbenv/versions" ]; then
        read -ra versions <<<"$(find "$HOME/.rbenv/versions" -mindepth 1 -maxdepth 1 -type d)"
        for version in "${versions[@]}"; do
            if [ -d "$version/bin" ] && [[ ":$PATH:" != *":$version/bin:"* ]]; then
                export PATH="$version/bin:$PATH"
            fi
        done
    fi
}
export_all_ruby_versions_bin_dirs

# Set Bat theme
export BAT_THEME="TwoDark"

# FZF settings
if command -v "fd" &>/dev/null; then
    FD_BIN_NAME="fd"
elif command -v "fdfind" &>/dev/null; then
    FD_BIN_NAME="fdfind"
fi
if [[ -n $FD_BIN_NAME ]]; then
    # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    _fzf_compgen_path() {
        eval "$FD_BIN_NAME --strip-cwd-prefix --hidden --exclude .git --exclude .venv . \"$1\""
    }
    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
        eval "$FD_BIN_NAME --strip-cwd-prefix --type directory --hidden --exclude .git --exclude .venv . \"$1\""
    }
    FZF_DEFAULT_COMMAND="$FD_BIN_NAME --strip-cwd-prefix --follow --hidden --exclude .git --exclude .venv"
    export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type directory"
    FZF_DEFAULT_COMMAND+=" --type file --type symlink"
    export FZF_DEFAULT_COMMAND
else
    export FZF_DEFAULT_COMMAND="find . \( -path \"*/.git\" -o -path \"*/.venv\" \) \
      -prune -o -type f,l ! -name '.' -printf '%P\n' | sort -V"
    export FZF_ALT_C_COMMAND="find . \( -path \"*/.git\" -o -path \"*/.venv\" \) \
      -prune -o -type d ! -name '.' -printf '%P\n' | sort -V"
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Set fzf preview options
FZF_PREVIEW_STRING="([[ -f {} ]] && (bat --style=numbers --color=always {} \
2> /dev/null || cat --number {} 2> /dev/null)) || ([[ -d {} ]] && \
(eza --oneline --group-directories-first --color=always --color-scale --icons \
--all --git {} 2> /dev/null || tree -a -C -L 1 -v --dirsfirst {} \
2> /dev/null)) || echo {} 2> /dev/null | head -200"
export FZF_DEFAULT_OPTS=" \
  --height=100% \
  --preview '${FZF_PREVIEW_STRING/$\'\n\'/}' \
  --preview-window=up:60%:hidden \
  --bind=ctrl-/:toggle-preview \
  --bind=alt-j:preview-down,alt-k:preview-up \
  --bind=alt-b:preview-page-up,alt-f:preview-page-down \
  --bind=alt-u:preview-half-page-up,alt-d:preview-half-page-down \
  --bind=alt-up:preview-top,alt-down:preview-bottom \
  --bind=ctrl-space:toggle+up \
  --bind=ctrl-d:half-page-down,ctrl-u:half-page-up \
  --bind=ctrl-f:page-down,ctrl-b:page-up \
  "

# fzf_marks
export FZF_MARKS_FILE="$HOME/.fzf-marks"
export FZF_MARKS_CMD="fzf"
export FZF_FZM_OPTS="--cycle +m --ansi --bind=ctrl-o:accept,ctrl-t:toggle --select-1"
export FZF_DMARK_OPTS="--cycle -m --ansi --bind=ctrl-o:accept,ctrl-t:toggle"

# fzf-git-branches https://github.com/awerebea/fzf-git-branches
# Auto install
if [[ ! -f "$HOME/.fzf-git-branches/fzf-git-branches.sh" ]]; then
    git clone https://github.com/awerebea/fzf-git-branches "$HOME/.fzf-git-branches"
fi
# Lazy load
if [ -f "$HOME/.fzf-git-branches/fzf-git-branches.sh" ]; then
    lazy_fgb() {
        unset -f \
            fgb \
            gbl \
            gbm \
            gwl \
            gwa \
            gwm \
            gwt \
            lazy_fgb
        # shellcheck disable=SC1091
        if ! source "$HOME/.fzf-git-branches/fzf-git-branches.sh"; then
            echo "Failed to load fzf-git-branches" >&2
            return 1
        fi
        alias gbl='fgb branch list'
        alias gbm='fgb branch manage'
        alias gwl='fgb worktree list'
        alias gwm='fgb worktree manage'
        alias gwa='fgb worktree add --confirm'
        alias gwt='fgb worktree total --confirm'
        fgb "$@"
    }
    # unalias gwt
    # unalias gbl
    function fgb {
        lazy_fgb "$@"
    }
    function gbl {
        lazy_fgb branch list "$@"
    }
    function gbm {
        lazy_fgb branch manage "$@"
    }
    function gwl {
        lazy_fgb worktree list "$@"
    }
    function gwm {
        lazy_fgb worktree manage "$@"
    }
    function gwa {
        lazy_fgb worktree add --confirm "$@"
    }
    function gwt {
        lazy_fgb worktree total --confirm "$@"
    }
fi

# Personal aliases
alias cdq='cd "$(fd -t d . | fzf)"'

# enable zoxide
if command -v "zoxide" &>/dev/null; then
    eval "$(zoxide init bash)"
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS \
    --bind=tab:up,shift-tab:down \
    --height=40% \
    --info=inline \
    --no-sort \
    --reverse \
    --select-1 \
    "
fi

# Enable vim mode
if [[ $- == *i* ]]; then # in interactive session
    set -o vi
fi

if [[ ! -d "$HOME/IceCream-Bash" ]]; then
    git clone https://github.com/jtplaarj/IceCream-Bash.git "$HOME/IceCream-Bash"
fi
