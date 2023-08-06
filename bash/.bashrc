# Enable the subsequent settings only in interactive sessions
case $- in
    *i*) ;;
    *) return ;;
esac

# Path to your oh-my-bash installation.
export OSH='/home/andrei/.oh-my-bash'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
___BRAINY_TOP_LEFT="dir scm"
___BRAINY_TOP_RIGHT="user_info python ruby todo clock battery"
THEME_PROMPT_CHAR_PS1="❯"

OSH_THEME="brainy"

# Uncomment the following line to use case-sensitive completion.
# OMB_CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
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
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you don't want the repository to be considered dirty
# if there are untracked files.
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
OMB_DEFAULT_ALIASES="check"

# Would you like to use another custom folder than $OSH/custom?
# OSH_CUSTOM=/path/to/new-custom-folder

# To disable the uses of "sudo" by oh-my-bash, please set "false" to
# this variable.  The default behavior for the empty value is "true".
OMB_USE_SUDO=true

# To enable/disable display of Python virtualenv and condaenv
OMB_PROMPT_SHOW_PYTHON_VENV=true  # enable
# OMB_PROMPT_SHOW_PYTHON_VENV=false # disable

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
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
plugins=(
    git
    bashmarks
    progress
    fasd
    sudo
)

# Which plugins would you like to conditionally load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format:
#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

source "$OSH"/oh-my-bash.sh

# User configuration

# Override brainy theme functions
function ___brainy_prompt_user_info {
    color=$_omb_prompt_bold_navy
    if [ "$THEME_SHOW_SUDO" == "true" ]; then
        if [ "$(sudo -n id -u 2>&1 | grep 0)" ]; then
            color=$_omb_prompt_bold_brown
        fi
    fi
    box=""
    info="$USER@$(hostname | awk -F'.' '{print $1}')"
    if [ "$SSH_CLIENT" != "" ]; then
        printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
    else
        printf "%s|%s" "$color" "$info"
    fi
}

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

if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# Define default editor nvim, vim, vi or nano
if command -v nvim &> /dev/null; then
    export EDITOR='nvim'
    alias vimdiff="nvim -d"
    # alias vim="nvim"
elif command -v vim &> /dev/null; then
    export EDITOR='vim'
elif command -v vi &> /dev/null; then
    export EDITOR='vi'
else
    export EDITOR='nano'
fi

export TERM=xterm-256color

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/fzf-marks/fzf-marks.plugin.bash ] && source ~/fzf-marks/fzf-marks.plugin.bash

if [ -d "$HOME/.local/bin" ] &&
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

alias v="$EDITOR"

# Repeat given char N times using shell function
rep(){
    local start=1
    local end=${1:-80}
    local str="${2:-=}"
    printf "$str%0.s" {"$start..$end"}
}

# Go to the given number of levels up
up(){
    local num=${1:-1}
    if [[ ! $num =~ ^[0-9]+$ ]]; then
        echo "Invalid input of the number of levels to go up."
        return
    fi
    eval "$(echo -n 'cd '; rep "$num" '../')"
}

# Store the terraform cache in a shared directory between all projects
if command -v terraform &> /dev/null; then
    tf_cache_path="$HOME/.cache/tf-plugins-cache"
    [ -d "$tf_cache_path" ] || mkdir -p "$tf_cache_path"
    export TF_PLUGIN_CACHE_DIR="$tf_cache_path"
    unset tf_cache_path
fi

if command -v aws-vault &> /dev/null; then
    export AWS_VAULT_BACKEND=file
fi

command -v terraform &> /dev/null && alias tf="terraform"
command -v terragrunt &> /dev/null && alias tg="terragrunt"

alias activate="python3.11 -m venv .venv && source .venv/bin/activate"

alias c="eval ${VSCODE_GIT_ASKPASS_NODE%/node}/bin/remote-cli/code"
alias vf="fd --type f --hidden --exclude .git | fzf --reverse | xargs -o $EDITOR"
alias cf="fd --type f --hidden --exclude .git | fzf --reverse | xargs ${VSCODE_GIT_ASKPASS_NODE%/node}/bin/remote-cli/code"
