zmodload zsh/zprof
zstyle ':omz:update' mode disabled

[[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]] && \
    export PATH="$HOME/.local/bin:$PATH"

if [[ ! "${commands[oh-my-posh]}" ]]; then
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME"/.local/bin
else
    if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
        eval "$(oh-my-posh init zsh --config "$HOME"/.oh-my-posh.yaml)"
    fi
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
if [[ "${commands[nvim]}" ]]; then
    export EDITOR='nvim'
    alias vimdiff="nvim -d"
    # alias vim="nvim"
elif [[ "${commands[vim]}" ]]; then
    export EDITOR='vim'
elif [[ "${commands[vi]}" ]]; then
    export EDITOR='vi'
else
    export EDITOR='nano'
fi

export TERM=xterm-256color

export ZSH="$HOME/.oh-my-zsh"
ZSH_PLUGINS="$ZSH"/custom/plugins

# Install oh-my-zsh if it's not there yet.
if [[ ! -f "$ZSH/oh-my-zsh.sh" ]]; then
    printf "\033[1;31m!!! ATTENTION !!!\033[0m\n"
    printf "\033[1;34mAfter installing \033[1;32moh-my-zsh, \033[1;34mpress "
    printf "\033[1;33mCTRL+D\033[1;34m to install custom plugins and theme.\033[0m\n\n"
    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # restore config
    cp "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
fi

# Install custom plugins if they aren't there yet.
if [[ ! -f "$ZSH_PLUGINS/history-sync/history-sync.plugin.zsh" ]]; then
    git clone https://github.com/wulfgarpro/history-sync "$ZSH_PLUGINS/history-sync"
fi

if [[ ! -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/zsh-autosuggestions"
fi

if [[ ! -f "$ZSH_PLUGINS/zsh-completions/zsh-completions.plugin.zsh" ]]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_PLUGINS/zsh-completions"
fi

if [[ ! -f "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
        "$ZSH_PLUGINS/fast-syntax-highlighting"
fi

# catppuccin fast-syntax-highlighting theme
if ! ls "$HOME"/.config/fsh/catppuccin-*.ini &>/dev/null; then
    git clone https://github.com/catppuccin/zsh-fsh.git "$HOME/.config/fsh"
    for file in "$HOME"/.config/fsh/themes/catppuccin-*.ini; do
        if [ -e "$file" ]; then
            ln -s "$file" "$HOME"/.config/fsh/
        fi
    done
fi

if [[ ! -f "$ZSH_PLUGINS/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
    git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_PLUGINS/zsh-vi-mode"
fi

if [[ ! -f "$ZSH_PLUGINS/fzf-marks/fzf-marks.plugin.zsh" ]]; then
    git clone https://github.com/urbainvaes/fzf-marks "$ZSH_PLUGINS/fzf-marks"
fi

if [[ ! -f "$ZSH_PLUGINS/auto-notify/auto-notify.plugin.zsh" ]]; then
    git clone https://github.com/MichaelAquilina/zsh-auto-notify "$ZSH_PLUGINS/auto-notify"
fi

if [[ ! -f "$ZSH_PLUGINS/zsh-aliases-eza/zsh-aliases-eza.plugin.zsh" ]]; then
    git clone https://github.com/DarrinTisdale/zsh-aliases-exa "$ZSH_PLUGINS/zsh-aliases-eza"
fi

if [[ ! -f "$ZSH_PLUGINS/forgit/forgit.plugin.zsh" ]]; then
    git clone https://github.com/wfxr/forgit "$ZSH_PLUGINS/forgit"
fi

if [[ ! -f "$ZSH_PLUGINS/zsh-sed-sub/zsh-sed-sub.plugin.zsh" ]]; then
    git clone https://github.com/MenkeTechnologies/zsh-sed-sub "$ZSH_PLUGINS/zsh-sed-sub"
fi

if [[ ! -f "$ZSH_PLUGINS/tipz/tipz.zsh" ]]; then
    git clone https://github.com/molovo/tipz "$ZSH_PLUGINS/tipz"
fi

if [[ ! -f "$ZSH_PLUGINS/tmux-vim-integration/tmux-vim-integration.plugin.zsh" ]]; then
    git clone https://github.com/jsahlen/tmux-vim-integration.plugin.zsh \
        "$ZSH_PLUGINS/tmux-vim-integration"
fi

# # Lazy loading nvm  # use custom lazy loading function instead
# if [[ ! -f "$ZSH_PLUGINS/zsh-nvm/zsh-nvm.plugin.zsh" ]]; then
#     git clone https://github.com/lukechilds/zsh-nvm "$ZSH_PLUGINS/zsh-nvm"
# fi

if [[ ! -f "$ZSH_PLUGINS/zsh-bash-completions-fallback/zsh-bash-completions-fallback.plugin.zsh" ]]; then
    git clone https://github.com/3v1n0/zsh-bash-completions-fallback \
        "$ZSH_PLUGINS/zsh-bash-completions-fallback"
fi

if [[ ! -f "$ZSH_PLUGINS/zsh-edit/zsh-edit.plugin.zsh" ]]; then
    git clone https://github.com/marlonrichert/zsh-edit "$ZSH_PLUGINS/zsh-edit"
fi

if [[ ! -f "$ZSH_PLUGINS/git-extra-commands/git-extra-commands.plugin.zsh" ]]; then
    git clone https://github.com/unixorn/git-extra-commands "$ZSH_PLUGINS/git-extra-commands"
fi

if [[ ! -f "$ZSH_PLUGINS/gunstage/gunstage.plugin.zsh" ]]; then
    git clone https://github.com/LucasLarson/gunstage "$ZSH_PLUGINS/gunstage"
fi

if [[ ! -f "$ZSH_PLUGINS/blackbox/blackbox.plugin.zsh" ]]; then
    git clone https://github.com/StackExchange/blackbox "$ZSH_PLUGINS/blackbox"
fi

if [[ ! -f "$ZSH_PLUGINS/git-flow-completion/git-flow-completion.plugin.zsh" ]]; then
    git clone https://github.com/bobthecow/git-flow-completion "$ZSH_PLUGINS/git-flow-completion"
fi

if [[ ! -d "$HOME/IceCream-Bash" ]]; then
    git clone https://github.com/jtplaarj/IceCream-Bash.git "$HOME/IceCream-Bash"
fi

# terraform plugin with resource names detection
if [[ ! -f "$ZSH_PLUGINS/terraform/terraform.plugin.zsh" ]]; then
    git clone https://github.com/macunha1/zsh-terraform "$ZSH_PLUGINS/terraform"
fi

# kubectx
if [[ ! "${commands[kubectx]}" && ! -f "$ZSH_PLUGINS/kubectx/kubectx.plugin.zsh" ]]; then
    git clone https://github.com/unixorn/kubectx-zshplugin \
        "$ZSH_PLUGINS/kubectx"
    old_pwd="$PWD"
    cd "$ZSH_PLUGINS/kubectx" || exit 1
    sed -i 's|git@github.com:|https://github.com/|' .gitmodules
    git submodule init
    git submodule update
    git submodule foreach git checkout \
        "$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|^refs/remotes/origin/||')"
    git submodule foreach git pull origin
    sed -i 's|https://github.com/|git@github.com:|' .gitmodules
    cd "$old_pwd" || exit 1
    unset old_pwd
fi

# fzf-tab
if [[ ! -f "$ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh" ]]; then
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_PLUGINS/fzf-tab"
fi
if [[ -f "$ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh" ]]; then
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    zstyle ':completion:*:git-branch:*' sort false
    # set descriptions format to enable group support
    zstyle ':completion:*:descriptions' format '[%d]'
    # switch group using `,` and `.`
    zstyle ':fzf-tab:*' switch-group ',' '.'
    # set list-colors to enable filename colorizing
    # shellcheck disable=2086,2296
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # preview directory's content with eza when completing cd
    # shellcheck disable=2016
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
fi

# kafka
if [[ ! -f "$ZSH_PLUGINS/kafka/kafka.plugin.zsh" ]]; then
    git clone https://github.com/Dabz/kafka-zsh-completions "$ZSH_PLUGINS/kafka"
fi

# zsh-easy-motion
if [[ ! -f "$ZSH_PLUGINS/easy_motion/easy_motion.plugin.zsh" ]]; then
    git clone https://github.com/IngoMeyer441/zsh-easy-motion "$ZSH_PLUGINS/easy_motion"
fi

# forgit plugin settings
# aliases
# shellcheck disable=2034
forgit_log=GLO
# shellcheck disable=2034
forgit_diff=GD
# shellcheck disable=2034
forgit_add=GA
# shellcheck disable=2034
forgit_reset_head=GRH
# shellcheck disable=2034
forgit_ignore=GI
# shellcheck disable=2034
forgit_checkout_file=GCF
# shellcheck disable=2034
forgit_checkout_branch=GCB
# shellcheck disable=2034
forgit_branch_delete=GBD
# shellcheck disable=2034
forgit_checkout_tag=GCT
# shellcheck disable=2034
forgit_checkout_commit=GCO
# shellcheck disable=2034
forgit_revert_commit=GRC
# shellcheck disable=2034
forgit_clean=GCLEAN
# shellcheck disable=2034
forgit_stash_show=GSS
# shellcheck disable=2034
forgit_stash_push=GSP
# shellcheck disable=2034
forgit_cherry_pick=GCP
# shellcheck disable=2034
forgit_rebase=GRB
# shellcheck disable=2034
forgit_blame=GBL
# shellcheck disable=2034
forgit_fixup=GFU

# forgit fzf settings
export FORGIT_FZF_DEFAULT_OPTS="--height=100% --preview \
  'bat --style=numbers --color=always --line-range :500 {}' \
  --preview-window=up:60%:nohidden \
  --bind=ctrl-/:toggle-preview \
  --bind=alt-j:preview-down,alt-k:preview-up \
  --bind=alt-b:preview-page-up,alt-f:preview-page-down \
  --bind=alt-u:preview-half-page-up,alt-d:preview-half-page-down \
  --bind=alt-up:preview-top,alt-down:preview-bottom \
  --bind=ctrl-space:toggle+up \
  --bind=ctrl-d:half-page-down,ctrl-u:half-page-up \
  --bind=ctrl-f:page-down,ctrl-b:page-up"

# Set LD_LIBRARY_PATH so it includes user's private lib if it exists¬
[[ -d "$HOME/.local/lib" && ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib:"* ]] && \
    export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# zsh-autosuggestions settings
# shellcheck disable=2034
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# # Setup zsh-nvm plugin              # use custom lazy loading function instead
# export NVM_LAZY_LOAD=true
# export NVM_COMPLETION=true

# Which plugins to load?
plugins=(
    aws
    blackbox
    colored-man-pages
    command-not-found
    copyfile
    copypath
    cp
    docker
    docker-compose
    easy_motion
    encode64
    extract
    forgit
    fzf-tab
    git-flow
    git-extra-commands
    git-flow-completion
    gunstage
    globalias
    helm
    history-sync
    kafka
    kubectl
    kubectx
    # auto-notify
    pass
    rsync
    sudo
    systemd
    terraform
    # tmux
    tmux-vim-integration
    ubuntu
    vagrant
    web-search
    zsh-autosuggestions
    zsh-completions
    zsh-interactive-cd
    # zsh-nvm                   # use custom lazy loading function instead
    zsh-sed-sub
    zsh-vi-mode
    history-substring-search
    fast-syntax-highlighting
    zsh-edit
    zsh-bash-completions-fallback
)

# Load the plugin only if it will work
[[ "${commands[eza]}" ]] && plugins+=(zsh-aliases-eza)

# shellcheck disable=1091
source "$ZSH/oh-my-zsh.sh"

# User configuration

export GIT_DOTFILES="$HOME/Github/dotfiles"
export GIT_WORKSPACE="$HOME/Github/workspace"

[[ -d "$HOME/Library/Python/3.10/bin" && ":$PATH:" != *":$HOME/Library/Python/3.10/bin:"* ]] && \
    export PATH="$HOME/Library/Python/3.10/bin:$PATH"

[[ -d "/var/lib/gems/2.7.0" && ":$PATH:" != *":/var/lib/gems/2.7.0:"* ]] && \
    export PATH="/var/lib/gems/2.7.0:$PATH"

[[ -d "/opt/mssql-tools/bin" && ":$PATH:" != *":/opt/mssql-tools/bin:"* ]] && \
    export PATH="/opt/mssql-tools/bin:$PATH"

[[ -d "/usr/local/go/bin" && ":$PATH:" != *":/usr/local/go/bin:"* ]] && \
    export PATH="/usr/local/go/bin:$PATH"

[[ -d "$HOME/go/bin" && ":$PATH:" != *":$HOME/go/bin:"* ]] && export PATH="$HOME/go/bin:$PATH"

if [[ -d "$HOME/.fzf/bin" && ":$PATH:" != *":/$HOME/.fzf/bin:"* ]]; then
    export PATH="$HOME/.fzf/bin:$PATH"
elif [[ -d "$HOME/.vim/plugged/fzf/bin" && ":$PATH:" != *":$HOME/.vim/plugged/fzf/bin:"* ]]; then
    export PATH="$HOME/.vim/plugged/fzf/bin:$PATH"
fi

[[ -d "$HOME/.tfenv" && ":$PATH:" != *":$HOME/.tfenv:"* ]] && export PATH="$HOME/.tfenv/bin:$PATH"

# Detect and setup current environment
if [[ "$(uname)" == "Linux" ]]; then
    # quick opening files with xdg-open
    alias o='a -e xdg-open &>/dev/null'
    alias open='xdg-open &>/dev/null'
    # Fix history-substring-search plugin behaviour in Tmux
    # shellcheck disable=2154
    bindkey "${terminfo[kcuu1]}" history-substring-search-up
    bindkey "${terminfo[kcud1]}" history-substring-search-down
fi

if [[ "$(uname -n)" == "pc-home" && "$(uname)" == "Darwin" ]]; then
    # Home macOS
    alias o='a -e open' # quick opening files with open
    alias sudo='sudo '
    # shellcheck disable=2139
    alias sudoedit="sudo $EDITOR"
    [[ -d "$HOME/Library/Python/3.7/bin" && ":$PATH:" != *":$HOME/Library/Python/3.7/bin:"* ]] && \
        export PATH="$HOME/Library/Python/3.7/bin:$PATH"
    # Use manually installed vim
    if [ -x "$HOME/.local/bin/vim" ]; then
        # shellcheck disable=2139
        alias vim="$HOME/.local/bin/vim"
        export EDITOR="$HOME/.local/bin/vim"
    fi
    # Bundle aliases
    alias fast="bundle exec fastlane"
    alias be="bundle exec"

fi

# "Forget" last N commands from history
# Added a space in 'my_remove_last_history_entry'
# so that zsh forgets the 'forget' command :).
alias frgt=' my_remove_last_history_entry'
my_remove_last_history_entry() {
    # This sub-function checks if the argument passed is a number.
    # Thanks to @yabt on stackoverflow for this :).
    is_int() {
        [ "$*" -eq "$*" ] &>/dev/null
    }
    # Set history file's location
    local history_file history_temp_file lines_to_remove
    history_file="$ZSH_HISTORY_FILE"
    history_temp_file="$history_file.tmp"
    # Check if the user passed a number, so we can delete N lines from history.
    if [ $# -eq 0 ]; then
        # No arguments supplied, so set to one.
        lines_to_remove=1
    else
        # An argument passed. Check if it's a number.
        if is_int "$1"; then
            lines_to_remove="$1"
        else
            echo "Unknown argument passed. Exiting..."
            return
        fi
    fi
    # fc -W # write current shell's history to the history file.
    sed "$(($(wc -l < "$history_file") - lines_to_remove + 1)),\$d" \
        "$history_file" > "$history_temp_file" 2>/dev/null
    mv "$history_temp_file" "$history_file"
    fc -R # read history file.
}

# create git hooks for ctags tags update
githooksctags() {
    touch -a .git/hooks/post-checkout
    grep -qxF '#!/bin/bash' .git/hooks/post-checkout || \
        echo "#!/bin/bash" >> .git/hooks/post-checkout
    local POST_CHECKOUT_STRING=
    POST_CHECKOUT_STRING='ctags -R --fields=+l --tag-relative=yes --exclude=.git '
    POST_CHECKOUT_STRING+='--exclude=.gitignore --exclude=@.gitignore '
    POST_CHECKOUT_STRING+='--exclude=@.ctagsignore -f .git/tags 2>/dev/null'
    grep -qxF "$POST_CHECKOUT_STRING" .git/hooks/post-checkout || \
        echo "$POST_CHECKOUT_STRING" >> .git/hooks/post-checkout
    chmod +x .git/hooks/post-checkout
    touch -a .git/hooks/post-commit
    grep -qxF '#!/bin/bash' .git/hooks/post-commit || \
        echo "#!/bin/bash" >> .git/hooks/post-commit
    local POST_COMMIT_STRING=
    POST_COMMIT_STRING='ctags -R --fields=+l --tag-relative=yes --exclude=.git '
    POST_COMMIT_STRING+='--exclude=.gitignore --exclude=@.gitignore '
    POST_COMMIT_STRING+='--exclude=@.ctagsignore -f .git/tags 2>/dev/null'
    grep -qxF "$POST_COMMIT_STRING" .git/hooks/post-commit || \
        echo "$POST_COMMIT_STRING" >> .git/hooks/post-commit
    chmod +x .git/hooks/post-commit
}

## bash and zsh only!
# functions to cd to the next or previous sibling directory, in glob order {{{
prev() {
    # default to current directory if no previous
    local prevdir cwd x
    prevdir="./"
    cwd="${PWD##*/}"
    if [[ -z "$cwd" ]]; then
        # $PWD must be /
        echo 'No previous directory.' >&2
        return 1
    fi
    for x in ../*/; do
        if [[ "${x#../}" == "$cwd/" ]]; then
            # found cwd
            if [[ "$prevdir" == ./ ]]; then
                echo 'No previous directory.' >&2
                return 1
            fi
            cd "$prevdir" || return 1
            return
        fi
        if [[ -d "$x" ]]; then
            prevdir="$x"
        fi
    done
    # Should never get here.
    echo 'Directory not changed.' >&2
    return 1
}

next() {
    local foundcwd cwd x
    foundcwd=
    cwd="${PWD##*/}"
    if [[ -z "$cwd" ]]; then
        # $PWD must be /
        echo 'No next directory.' >&2
        return 1
    fi
    for x in ../*/; do
        if [[ -n "$foundcwd" ]]; then
            if [[ -d "$x" ]]; then
                cd "$x" || return 1
                return
            fi
        elif [[ "${x#../}" == "$cwd/" ]]; then
            foundcwd=1
        fi
    done
    echo 'No next directory.' >&2
    return 1
}
# }}}

# Decrypt and export in env variables secret token
# shellcheck disable=2139
alias ghtkn="gpg $GIT_WORKSPACE/github_token.gpg; \
  source $GIT_WORKSPACE/github_token; rm -f $GIT_WORKSPACE/github_token"

# Launch spotifyd with authentication
launch-spotify() {
    gpg --decrypt -r awerebea "$GIT_WORKSPACE"/spotify.sh.gpg | /bin/env bash && spt
}

# Use remote docker daemon {{{
dkremote() {
    local DEFAULT_REMOTE_HOST DEFAULT_CERT_DIR CERT_DIR
    DEFAULT_REMOTE_HOST="192.168.100.4:2376"
    DEFAULT_CERT_DIR="/home/$USER/.docker"
    [ $# -gt 0 ] && CERT_DIR="/home/$USER/.docker/ssl/$(echo "$1" | cut -d: -f1)"
    export DOCKER_TLS_VERIFY=1
    export DOCKER_HOST="tcp://${1:-$DEFAULT_REMOTE_HOST}"
    export DOCKER_CERT_PATH="${CERT_DIR:-$DEFAULT_CERT_DIR}"
}

dklocal() {
    unset DOCKER_TLS_VERIFY
    unset DOCKER_HOST
    unset DOCKER_CERT_PATH
}
# }}}

# Source broot shell script
BR_SCRIPT="$HOME/.config/broot/launcher/bash/br"
if [ -f "$BR_SCRIPT" ]; then
    # shellcheck disable=1090
    source "$BR_SCRIPT"
fi
unset BR_SCRIPT

# Personal aliases
# shellcheck disable=2139
alias zshconfig="$EDITOR ~/.zshrc"
# shellcheck disable=2139
alias vimconfig="$EDITOR ~/.vimrc"
# shellcheck disable=2139
alias rangerconfig="$EDITOR ~/.config/ranger/rc.conf"
# shellcheck disable=2139
alias zhistedit="$EDITOR ~/.zsh_history"
alias vless="/usr/local/share/vim/vim82/macros/less.sh"
alias cls="clear"
alias -g B='| bat -n'
alias -g G='| grep -i --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias -g L='| less -NR -r'
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
alias myip='curl http://ipecho.net/plain; echo'
alias h='helm'
alias vv='"$EDITOR" "$(fzf)"'
alias vvv='f -e "$EDITOR"'
# shellcheck disable=2139
alias v="$EDITOR"
# shellcheck disable=2139
alias c="eval ${VSCODE_GIT_ASKPASS_NODE%/node}/bin/remote-cli/code"
# shellcheck disable=2139
alias vf="fd --type f --hidden --exclude .git | fzf --reverse | xargs -o $EDITOR"
# shellcheck disable=2139
alias cf="fd --type f --hidden --exclude .git | fzf --reverse | xargs ${VSCODE_GIT_ASKPASS_NODE%/node}/bin/remote-cli/code"

# tmux aliases
alias tksv='tmux kill-server'
alias tksa='tmux kill-session -a' # kill other sessions except the current one
# To avoid repeating the last command if misspelled when calling the rr alias
alias r="echo \"Don't use that shit!\""
[[ "${commands[trash]}" ]] && alias rm="trash-put"
# Ripgrep alias to search in hidden files but ignore .git directory
[[ "${commands[rg]}" ]] && alias rg="rg --hidden --glob '!.git/'"
[[ "${commands[lazygit]}" ]] && alias lg="lazygit"
[[ "${commands[rover]}" ]] && alias rv="rover"
alias cdi='source cd-infra'
alias py='python'
alias cdq='cd "$(fd -t d . | fzf)"'

vs() {
    find "$GIT_DOTFILES"/scripts -type f | fzf | xargs -I {} -r "$EDITOR" '{}'
}

# terraform lint scripts
[[ "${commands[terraform-watch]}" ]] && alias tf-watch="terraform-watch"
[[ "${commands[terraform-check]}" ]] && alias tf-check="terraform-check"

# Store the terraform cache in a shared directory between all projects
if [[ "${commands[terraform]}" ]]; then
    tf_cache_path="$HOME/.cache/terraform"
    [ -d "$tf_cache_path" ] || mkdir -p "$tf_cache_path"
    export TF_PLUGIN_CACHE_DIR="$tf_cache_path"
    export TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE=true
    unset tf_cache_path
fi

if [[ "${commands[terragrunt]}" ]]; then
    alias tg="terragrunt"
    alias tgp="terragrunt plan"
    alias tga="terragrunt apply"
    alias tgo="terragrunt output"
    alias tgsl="terragrunt state list"
    alias tgss="terragrunt state show"
fi

# copy/paste to/from system clipboard
if [[ $(uname -s) = Linux ]]; then
    alias cb='xclip -selection clipboard && echo "\033[0;33mCopied to clipboard:\033[0m $(xclip -o -selection clipboard)"'
    alias pb='xclip -o -selection clipboard'
else
    alias cb='pbcopy && echo "\033[0;33mCopied to clipboard:\033[0m $(pbpaste)"'
    alias pb='pbpaste'
fi

# Find (fd) aliases
alias fdh='fd -H' # search in hidden files too

# update oh-my-zsh and all custom plugins
omz-update() {
    omz update
    # Setup colors
    local GREEN YELLOW_BOLD NC old_pwd plugin
    GREEN='\033[0;32m'
    YELLOW_BOLD='\033[1;33m'
    NC='\033[0m' # No Color
    old_pwd="$PWD"
    echo "${GREEN}Updating OMZ custom plugins:$NC"
    cd "$ZSH_PLUGINS" || return
    for plugin in *; do
        if [ -d "$ZSH_PLUGINS/$plugin/.git" ]; then
            cd "$ZSH_PLUGINS/$plugin" || return
            [ -f ./.gitmodules ] && \
                sed -i 's|git@github.com:|https://github.com/|' .gitmodules
            echo "${YELLOW_BOLD}${plugin}${NC}"
            git pull
            git submodule update
            git submodule foreach git checkout \
                "$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|^refs/remotes/origin/||')"
            git submodule foreach git pull origin
            [ -f ./.gitmodules ] && sed -i 's|https://github.com/|git@github.com:|' .gitmodules
        fi
    done
    cd "$old_pwd" || return
}

# Store the alias command in a variable to prevent an error using the alias_for
# function.
alias rr='ranger --choosedir=$HOME/.rangerdir; cd "$(cat $HOME/.rangerdir)" >/dev/null 2>&1'
# shellcheck disable=2139
alias cpmakefile="cp $GIT_DOTFILES/templates/Makefile ."

# Define eza aliases conditionally
if [ "${commands[eza]}" ]; then
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

# docker aliases
[[ -z $(groups | awk "/docker/ {print}") ]] && DOCKER_CMD="sudo docker"
# shellcheck disable=2139
alias dksa="${DOCKER_CMD:-docker} stop \$(${DOCKER_CMD:-docker} ps -q)"
# shellcheck disable=2139
alias dkrc="${DOCKER_CMD:-docker} rm \$(${DOCKER_CMD:-docker} container ls -qa)"
# shellcheck disable=2139
alias dkri="${DOCKER_CMD:-docker} rmi \$(${DOCKER_CMD:-docker} image ls -qa)"
# shellcheck disable=2139
alias dkreset="dksa && dkrc && dkri"
# shellcheck disable=2139
alias dk="${DOCKER_CMD:-docker}"
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

# kafkactl aliases
alias kafka="kafkactl"

# Lazy loading stern completions
if [ "${commands[stern]}" ]; then
    stern() {
        unfunction "$0"
        # shellcheck disable=1090
        source <(stern --completion=zsh)
        $0 "$@"
    }
fi

# Add kafka to the path if exist
if [[ -d "$HOME/.local/opt/kafka" && ":$PATH:" != *":$HOME/.local/opt/kafka"* ]]; then
    export KAFKA_HOME="$HOME/.local/opt/kafka"
    export PATH="$PATH:$KAFKA_HOME/bin"
fi

# Create kafkacl completion file if needed
if [[ "${commands[kafkactl]}" && ! -s "$ZSH/completions/_kafkactl" ]]; then
    mkdir -p "$ZSH/completions"
    kafkactl completion zsh > "$ZSH/completions/_kafkactl"
fi

# Create minikube completion file if needed
if [[ "${commands[minikube]}" && ! -e "$ZSH/completions/_minikube" ]]; then
    mkdir -p "$ZSH/completions"
    minikube completion zsh > "$ZSH/completions/_minikube"
    sed "/\t<<'BASH_COMPLETION_EOF'/i\\\t-e \
's/aliashash\\\\[\"\\\\(\\\\w\\\\+\\\\)\"\\\\]/aliashash[\\\\1]/g' \\\\" \
        "$ZSH/completions/_minikube" > "$ZSH/completions/_minikube.tmp"
    mv "$ZSH/completions/_minikube.tmp" "$ZSH/completions/_minikube"
fi

# Lazy loading vagrant completions
if [ "${commands[vagrant]}" ]; then
    vagrant() {
        unfunction "$0"
        local VAGRANT_COMPLETIONS
        VAGRANT_COMPLETIONS=$(find /opt/vagrant/ -type d \
            -path "/vagrant*/contrib/zsh" | tail -n1)
        fpath=("$VAGRANT_COMPLETIONS" "${fpath[@]}")
        compinit
        $0 "$@"
    }
fi

# Load googler @t aliases
if [ "${commands[googler]}" ] && [ -f "$ZSH/completions/googler_at" ]; then
    # shellcheck disable=1091
    source "$ZSH/completions/googler_at"
fi

# Lazy loading nvm if exists
if [ -d "$HOME/.nvm" ]; then
    lazy_nvm() {
        unset -f nvm npm node vim nvim ranger cdk github-copilot-cli # unset -f == unfunction
        [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=1091
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        # shellcheck disable=1091
        [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
        eval "$(github-copilot-cli alias -- "$0")"
    }
    nvm() {
        lazy_nvm; $0 "$@"
    }
    npm() {
        lazy_nvm; $0 "$@"
    }
    node() {
        lazy_nvm; $0 "$@"
    }
    vim() {
        lazy_nvm; $0 "$@"
    } # for node-dependent plugins to work in (n)vim
    nvim() {
        lazy_nvm; $0 "$@"
    } # for node-dependent plugins to work in (n)vim
    ranger() {
        lazy_nvm; $0 "$@"
    }
    cdk() {
        lazy_nvm; $0 "$@"
    }
    github-copilot-cli() {
        lazy_nvm; $0 "$@"
    }
fi

# Lazy loading rbenv if exists
if [ -d "$HOME/.rbenv/bin" ]; then
    lazy_rbenv() {
        unset -f bundle bundler erb gem irb racc rake rbs rdbg rdoc ri ruby typeprof
        if [[ ":$PATH:" != *":$HOME/.rbenv/bin:"* ]]; then
            export PATH="$PATH:$HOME/.rbenv/bin"
        fi
        eval "$(rbenv init - zsh)"
    }
    bundle() {
        lazy_rbenv; $0 "$@"
    }
    bundler() {
        lazy_rbenv; $0 "$@"
    }
    erb() {
        lazy_rbenv; $0 "$@"
    }
    gem() {
        lazy_rbenv; $0 "$@"
    }
    irb() {
        lazy_rbenv; $0 "$@"
    }
    racc() {
        lazy_rbenv; $0 "$@"
    }
    rake() {
        lazy_rbenv; $0 "$@"
    }
    rbs() {
        lazy_rbenv; $0 "$@"
    }
    rdbg() {
        lazy_rbenv; $0 "$@"
    }
    rdoc() {
        lazy_rbenv; $0 "$@"
    }
    ri() {
        lazy_rbenv; $0 "$@"
    }
    ruby() {
        lazy_rbenv; $0 "$@"
    }
    typeprof() {
        lazy_rbenv; $0 "$@"
    }
fi
# Setup ruby environment
export_all_ruby_versions_bin_dirs() {
    if [ -d "$HOME/.rbenv/versions" ]; then
        while IFS= read -r VERSION; do
            if [ -d "$VERSION/bin" ]; then
                [[ ":$PATH:" != *":$VERSION/bin:"* ]] &&
                export PATH="$VERSION/bin:$PATH"
            fi
        done < <(find "$HOME/.rbenv/versions" -mindepth 1 -maxdepth 1 -type d)
    fi
}
export_all_ruby_versions_bin_dirs

# Lazy loading github-copilot if exists
if [[ "${commands[github-copilot-cli]}" ]]; then
    eval "$(github-copilot-cli alias -- "$0")"
fi

# Load Homebrew for linux if installed
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$("/home/linuxbrew/.linuxbrew/bin/brew" shellenv)"
fi

# Create eksctl completion file if needed
if [[ "${commands[eksctl]}" ]] && [ ! -s "$ZSH/completions/_eksctl" ]; then
    mkdir -p "$ZSH/completions"
    eksctl completion zsh > "$ZSH/completions/_eksctl"
fi

# Create nerdctl completion file if needed
if [[ "${commands[nerdctl]}" ]] && [ ! -s "$ZSH/completions/_nerdctl" ]; then
    mkdir -p "$ZSH/completions"
    nerdctl completion zsh > "$ZSH/completions/_nerdctl"
fi

# Lazy loading nerdctl completions
if [ "${commands[nerdctl]}" ]; then
    nerdctl() {
        unfunction "$0"
        compinit
        $0 "$@"
    }
    alias docker="nerdctl"
    alias dk="nerdctl"
fi

# enable zoxide
if [[ "${commands[zoxide]}" ]]; then
    eval "$(zoxide init zsh)"
    EZA_ZOXIDE_OPTS="eza --tree --level=2 --group-directories-first --color=always --color-scale \
    --icons --all --git {2}"
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS \
    --preview '${EZA_ZOXIDE_OPTS/$\'\n\'/}' \
    --bind=tab:down,shift-tab:up \
    --height=40% \
    --info=inline \
    --no-sort \
    --reverse \
    --select-1 \
    --cycle \
    "
    alias cd="z"
fi

# git add all changed files and commit
gac() {
    git add .
    git commit -m "$1"
}
# git add all changed files, commit and push
gacp() {
    git add .
    git commit -m "$1"
    git push
}

# zsh_history settings
HISTSIZE=100500
# shellcheck disable=2034
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
export ZSH_HISTORY_FILE="$HOME/$ZSH_HISTORY_FILE_NAME"
export ZSH_HISTORY_PROJ="$GIT_WORKSPACE"
export ZSH_HISTORY_FILE_ENC_NAME="zsh_history.gpg"
export ZSH_HISTORY_FILE_ENC="$ZSH_HISTORY_PROJ/$ZSH_HISTORY_FILE_ENC_NAME"
export GIT_COMMIT_MSG="Sync zsh history"

# re-read history file
alias re=" fc -R"

# auto correction
setopt CORRECT
setopt CORRECT_ALL

# ranger
export RANGER_LOAD_DEFAULT_RC=FALSE
export W3MIMGDISPLAY_PATH="$HOME/.local/libexec/w3m/w3mimgdisplay"

# set $EDITOR as the default pager for man pages
export MANPAGER='nvim +Man!'

# Set Bat theme
if [[ "${commands[bat]}" ]]; then
    # catppuccin theme
    bat_config="$(bat --config-dir)"
    if [[ ! -d "$bat_config/catppuccin" ]]; then
        mkdir -p "$bat_config"/themes
        git clone https://github.com/catppuccin/bat.git "$bat_config"/catppuccin
        for file in "$bat_config"/catppuccin/Catppuccin-*.tmTheme; do
            if [ -e "$file" ]; then
                ln -s "$file" "$bat_config"/themes/
            fi
        done
        bat cache --build
    fi
    export BAT_THEME="Catppuccin-mocha"
fi

# FZF settings
if [[ "${commands[fd]}" ]]; then
    FD_BIN_NAME="fd"
elif [[ "${commands[fdfind]}" ]]; then
    FD_BIN_NAME="fdfind"
fi
if [[ -n $FD_BIN_NAME ]]; then
    # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
    # - The first argument to the function ($1) is the base path to start traversal
    # - See the source code (completion.{bash,zsh}) for the details.
    _fzf_compgen_path() {
        eval "$FD_BIN_NAME --hidden --exclude .git --exclude .venv . \"$1\" | sed 's|^\./||'"
    }
    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
        eval "$FD_BIN_NAME --type directory --hidden --exclude .git --exclude .venv . \"$1\" | sed 's|^\./||'"
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
2>/dev/null || cat --number {} 2>/dev/null)) || ([[ -d {} ]] && \
(eza --tree --level=2 --color=always --color-scale --icons --group-directories-first \
--all --git {} 2>/dev/null || tree -a -C -L 1 -v --dirsfirst {} \
2>/dev/null)) || echo {} 2>/dev/null | head -200"
export FZF_DEFAULT_OPTS="--height=100% \
  --inline-info \
  --ansi \
  --scheme=history \
  --preview '${FZF_PREVIEW_STRING/$\'\n\'/}' \
  --preview-window=up:60%:hidden \
  --bind=ctrl-/:toggle-preview \
  --bind=alt-j:preview-down \
  --bind=alt-k:preview-up \
  --bind=alt-b:preview-page-up \
  --bind=alt-f:preview-page-down \
  --bind=alt-u:preview-half-page-up \
  --bind=alt-d:preview-half-page-down \
  --bind=alt-up:preview-top \
  --bind=alt-down:preview-bottom \
  --bind=ctrl-space:toggle+up \
  --bind=ctrl-d:half-page-down \
  --bind=ctrl-u:half-page-up \
  --bind=ctrl-f:page-down \
  --bind=ctrl-b:page-up \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

if [[ "${commands[eza]}" ]]; then
    export FZF_CTRL_T_OPTS="--preview '${FZF_PREVIEW_STRING/$\'\n\'/}'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons --all --git {}'"

    # Advanced customization of fzf options via _fzf_comprun function
    # - The first argument to the function is the name of the command.
    # - You should make sure to pass the rest of the arguments to fzf.
    _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
            cd|z)
                EZA_OPTS="eza --tree --level=2 --group-directories-first --color=always --color-scale \
          --icons --all --git {}"
                fzf --preview "${EZA_OPTS/$\'\n\'/}" "$@"
                ;;
            export|unset)
                fzf --preview "eval 'echo \${}'" "$@"
                ;;
            ssh)
                fzf --preview "dig {}" "$@"
                ;;
            *)
                fzf --preview "${FZF_PREVIEW_STRING/$\'\n\'/}" "$@"
                ;;
        esac
    }
fi

# ranger filemanager plugins
# fzf_marks
export FZF_MARKS_FILE="$HOME/.fzf-marks"
export FZF_MARKS_CMD="fzf"
export FZF_FZM_OPTS="--cycle +m --ansi --bind=ctrl-o:accept,ctrl-t:toggle --select-1"
export FZF_DMARK_OPTS="--cycle -m --ansi --bind=ctrl-o:accept,ctrl-t:toggle"
# ranger_gpg
export DEFAULT_RECIPIENT="awerebea.21@gmail.com"

# Pass storage path
export PASSWORD_STORE_DIR="$GIT_WORKSPACE/.password-store"

# Create and launch python VENV
alias activate="python3.11 -m venv .venv && source .venv/bin/activate"
alias activate38="python3.8 -m venv .venv && source .venv/bin/activate"
alias activate39="python3.9 -m venv .venv && source .venv/bin/activate"
alias activate310="python3.10 -m venv .venv && source .venv/bin/activate"
alias activate311="python3.11 -m venv .venv && source .venv/bin/activate"

# Generate '.clang_complete' for VIM and C/CPP projects
alias clangcomplgen='find . -type f -name "*.hpp" -o -name "*.h" | \
    sed "s:[^/]*$::" | sort -u | sed "s/.*/-I\ &/" > .clang_complete'

# Increase keybind timeout from 1 to 50 to fix sudo plugin
export KEYTIMEOUT=50

# zsh-vi-mode plugin
# Change to Zsh's default readkey engine
# shellcheck disable=2034
ZVM_READKEY_ENGINE="$ZVM_READKEY_ENGINE_NEX" #NEW

# shellcheck disable=2034
ZVM_KEYTIMEOUT=0.4
# shellcheck disable=2034
ZVM_ESCAPE_KEYTIMEOUT=0.03
# # shellcheck disable=2034
# ZVM_VI_HIGHLIGHT_BACKGROUND=red
# shellcheck disable=2034
ZVM_VI_HIGHLIGHT_BACKGROUND=#ffd200
# shellcheck disable=2034
ZVM_VI_HIGHLIGHT_FOREGROUND=#000000
# shellcheck disable=2034
ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold

# shellcheck disable=2034
ZVM_NORMAL_MODE_CURSOR="$ZVM_CURSOR_BLINKING_BLOCK"
# shellcheck disable=2034
ZVM_INSERT_MODE_CURSOR="$ZVM_CURSOR_BLINKING_BEAM"
# shellcheck disable=2034
ZVM_OPPEND_MODE_CURSOR="$ZVM_CURSOR_BLINKING_UNDERLINE"

# shellcheck disable=2034
ZVM_LINE_INIT_MODE="$ZVM_MODE_INSERT"

# docker plugin
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Configurarion of auto-notify plugin
# (https://github.com/MichaelAquilina/zsh-auto-notify#configuration)
# Set threshold to 20seconds
export AUTO_NOTIFY_THRESHOLD=20
# Set notification expiry to 10 seconds
export AUTO_NOTIFY_EXPIRE_TIME=10000
# Add command(s) to list of ignored commands
AUTO_NOTIFY_IGNORE+=("rr" "ranger" "docker")

# history-substring-search plugin
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# up/down keys
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down
bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down

# Check daily for plugins updates
export UPDATE_ZSH_DAYS=1
# shellcheck disable=2034
ZSH_CUSTOM_AUTOUPDATE_QUIET=false

# # Automatically start tmux on remote server when logging in via SSH
# if [ -n "$PS1" ] && [ -n "$SSH_CONNECTION" ] && [ "${commands[tmux]}" ] &&
#   tmux -V | grep -Eo "[0-9]{1,}(\.[0-9]{1,}){0,}" | head -n1 |
#   awk -F. '{ if ($1 > 3 || ($1 == 3 && $2 >= 0) ) { exit 0 } else { exit 1 } }' &&
#   [ -z "$TMUX" ]; then
#     tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
# fi

# # Automatically start tmux on local machine if not running yet
# if [ -z "$SSH_CONNECTION" ] && [ "${commands[tmux]}" ] &&
#   tmux -V | grep -Eo "[0-9]{1,}(\.[0-9]{1,}){0,}" | head -n1 |
#   awk -F. '{ if ($1 > 3 || ($1 == 3 && $2 >= 0) ) { exit 0 } else { exit 1 } }' &&
#   ! tmux info &>/dev/null; then
#   tmux
# fi

# fzf-git
if [[ ! -f "$HOME/.fzf-git/fzf-git.sh" ]]; then
    git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/.fzf-git"
    # shellcheck disable=1091
    source "$HOME/.fzf-git/fzf-git.sh"
else
    # shellcheck disable=1091
    source "$HOME/.fzf-git/fzf-git.sh"
fi

# Lazy activate fzf-marks plugin
export FZF_MARKS_JUMP="^g^g"
fzm-lazy-load() {
    unset -f fzm-hotkey-lazy-load fzm-lazy-load fzm mark
    zle -D fzm-hotkey-lazy-load
    # shellcheck disable=1091
    source "$ZSH_PLUGINS/fzf-marks/fzf-marks.plugin.zsh"
}
# shellcheck disable=2120
fzm() {
    fzm-lazy-load; $0 "$@"
}
mark() {
    fzm-lazy-load; $0 "$@"
}
fzm-hotkey-lazy-load() {
    fzm-lazy-load
    fzm
}
# Make a keyboard widget out of the function above.
zle -N fzm-hotkey-lazy-load
# Bind the widget to Ctrl-g Ctrl-g in the `v` keymap.
bindkey -M viins '^g^g' fzm-hotkey-lazy-load # Ctrl-g is used by fzf-git
alias mm=fzm

# Emulate <C-o> vim behavior
vi-cmd() {
    local REPLY
    # Read the next keystroke, look it up in the `vicmd` keymap and, if successful,
    # evalute the widget bound to it in the context of the `vicmd` keymap.
    zle .read-command -K vicmd && zle "$REPLY" -K vicmd
}
# Make a keyboard widget out of the function above.
zle -N vi-cmd
# Bind the widget to Ctrl-o in the `viins` keymap.
bindkey -v '^o' vi-cmd

# Required for fzf-marks and fzf-git plugins.
# For some reason it must be specifically after the block above
bindkey -r '^g'

# This speeds up pasting w/ autosuggest
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
    # shellcheck disable=2296,2298
    OLD_SELF_INSERT="${${(s.:.)widgets[self-insert]}[2,3]}"
    zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}
pastefinish() {
    zle -N self-insert "$OLD_SELF_INSERT"
    unset OLD_SELF_INSERT
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
    # TODO: Check shellcheck
    # shellcheck disable=2076
    [[ $1 =~ '[[:punct:]]' ]] && return
    local search found
    search="$1"
    found="$( alias "$search" )"
    if [[ -n "$found" ]]; then
        found="${found//\\//}" # Replace backslash with slash
        found="${found%\'}" # Remove end single quote
        found="${found#"$search='"}" # Remove alias name
        echo "${found} $2" | xargs # Return found value (with parameters)
    else
        echo ""
    fi
}
expand_command_line() {
    local CYAN BLUE NC excluded_aliases first rest full_cmd
    CYAN='\033[1;36m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    excluded_aliases=(grep nvim ranger rg rr)
    first=$(echo "$1" | awk '{print $1;}')
    grep -qE '[\(\[\{]' <<< "$first" && return
    # Check if the alias is not in the exluded list
    if [[ "${excluded_aliases[*]}" != *"$first"* ]]; then
        # shellcheck disable=2298
        rest="${${1}/"${first}"/}"
        if [[ -n "${first//-//}" ]]; then # is not hypen
            full_cmd="$(alias_for "${first}")"
            # Check if expanded command string heve more than one word (have spaces)
            # to avoid alias=command output
            if [[ ! "$full_cmd" =~ ' ' ]]; then
                full_cmd="$(cut -d "=" -f2- <<< "$full_cmd")"
            fi
            # Check if there's a command for the alias
            if [[ -n "$full_cmd" ]]; then # If there was
                echo "  $CYAN↳$NC $BLUE${full_cmd} $NC${rest:1}" # Print it
            fi
        fi
    fi
}
pre_validation() {
    [[ $# -eq 0 ]] && return               # If there's no input, return. Else...
    expand_command_line "$@"
}
autoload -U add-zsh-hook                 # Load the zsh hook module.
add-zsh-hook preexec pre_validation      # Adds the hook
# add-zsh-hook -d preexec pre_validation   # Remove it for this hook.

# tipz plugin
if [[ -f "$ZSH_PLUGINS/tipz/tipz.zsh" ]]; then
    # shellcheck disable=1091
    source "$ZSH_PLUGINS/tipz/tipz.zsh"
    export TIPZ_TEXT='  \033[1;33m↳\033[0m'
fi

# Swap space keybind behavior for globalias plugin
function globalias-wrapper() {
    zle globalias
    zle backward-delete-char
    zle -U " "
}
zle -N globalias-wrapper
# control-space expands all aliases, including global
bindkey -M emacs "^ " globalias-wrapper
bindkey -M viins "^ " globalias-wrapper
# space makes a normal space
bindkey -M emacs " " magic-space
bindkey -M viins " " magic-space

timezsh() {
    echo "Real zsh startup time in seconds:"
    local VAR i
    VAR=${1:-10};
    for ((i = 1; i <= VAR; i++)); do
        (/usr/bin/time -f "%e" zsh -i -c exit) &>> zsh_startup_time.tmp;
        printf '%2s) ' $i
        tail -n 1 zsh_startup_time.tmp;
    done
    VAR=$(awk 'BEGIN{s=0;}{s+=$1;}END{print s/NR;}' zsh_startup_time.tmp)
    printf '-----------------------------------
    Average startup time: %.3f seconds\n' "$VAR"
    rm -f zsh_startup_time.tmp
}

# Ctrl+rightarrow to move to the next word
bindkey '^[[1;5C' emacs-forward-word
# Ctrl+Alt+l to move to the next word
bindkey '^[^L' emacs-forward-word
# Ctrl+leftarrow to move to the previous word
bindkey '^[[1;5D' emacs-backward-word
# Ctrl+Alt+h to move to the previous word
bindkey '^[^H' emacs-backward-word
# Alt(Option)+; to accept autosuggestion
bindkey '^[;' end-of-line
# Alt(Option)+Enter to execute autosuggestion
bindkey '^[^M' autosuggest-execute
# Home to move to the start of line
bindkey '^[[H' beginning-of-line
# End to move to the start of line
bindkey '^[[F' end-of-line
# Ctrl+x,Ctrl+v to open file in $EDITOR using fzf
# shellcheck disable=2016
bindkey -s '^x^v' '$EDITOR $(fzf)^M'

bindkey '^[y' yank-pop

# Ctrl+delete to delete until the end of the word
bindkey '^[[3;5~' kill-word
# Ctrl+Shift+delete to delete until the end of the line
bindkey '^[[3;6~' kill-line

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Alt+m to duplicate the last WORD on the command line
bindkey "^[m" copy-prev-shell-word

# Yank from vim's visual selection mode to the system clipboard
zvm_vi_yank() {
    zvm_yank
    printf %s "${CUTBUFFER}" | xclip -selection clipboard
    zvm_exit_visual_mode
}

# Git. Fetch all origin remote branches
# Git aliases
alias dots-status='git --git-dir "$GIT_DOTFILES/.git" status -s -b'
alias -g GR='$(git rev-parse --show-toplevel)'
# Prune local tracking branches that do not exist on remote anymore
cleanup-git-branches() {
    git fetch -p ; git branch -r | awk '{print $1}' | grep -E -v -f /dev/fd/0 <(git branch -vv | \
        grep origin) | awk '{print $1}' | xargs git branch -d
}

# Execute any alias or command in dotfiles repo
dots() {
    location="$PWD"
    cd "$GIT_DOTFILES" || return
    read -rA cmd <<< "$(alias "$1" | cut -d= -f2- | sed "s/^'//;s/'$//")"
    if [ ${#cmd[@]} -gt 0 ]; then
        "${cmd[@]}" "${@:2}"
    else
        "$@"
    fi
    cd "$location" || return
}

# Restart cinnamon from tty when black screen after wake up from suspend
restart-cinnamon() {
    pkill -HUP -f "cinnamon --replace"; export DISPLAY=:0.0; cinnamon --replace &
}

# Launch environment adjusting scripts
adjust-my-env() {
    mouse-middle-button-scroll 2>/dev/null || true
    xrandr-"$(hostname)" 2>/dev/null || true
}
alias ame='adjust-my-env'

# Update all submodules in the specified repository
git-update-all-submodules() {
    [ $# -lt 1 ] && echo "Repository path missed!" && return 1
    local old_pwd
    old_pwd="$PWD"
    cd "$1" || return 1
    git submodule update
    git submodule foreach git checkout \
        "$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|^refs/remotes/origin/||')"
    git submodule foreach git pull origin
    cd "$old_pwd" || return 1
}

# Clean $PATH from duplicates
if [ -n "$PATH" ]; then
    old_PATH="$PATH":
    # shellcheck disable=2123
    PATH=
    while [ -n "$old_PATH" ]; do
        x=${old_PATH%%:*}       # the first remaining entry
        case $PATH: in
            *:"$x":*) ;;          # already there
            *) PATH=$PATH:$x ;;    # not there yet
        esac
        old_PATH=${old_PATH#*:}
    done
    PATH=${PATH#:}
    unset old_PATH x
fi

# zsh-easy-motion
bindkey -M vicmd ' ' vi-easy-motion

# Color output of json file using jq and less
jqc() {
    jq --color-output . "$1" | less -NR -r
}

# Color output of yaml file using yq and less
yqc() {
    yq --colors "$1" | less -NR -r
}

# rclone aliases
rclone-bisync-google-drive_cobblestone.tlt() {
    rclone bisync /media/andrei/Data/Clouds/Google\ Drive \
        google-drive_cobblestone.tlt: \
        --filters-file /home/andrei/.config/rclone/filter_google-drive_cobblestone.tlt \
        --log-file /home/andrei/.config/rclone/logs/bisync_google-drive_cobblestone.tlt.log
}

if [[ "${commands[aws-vault]}" ]]; then
    export AWS_VAULT_BACKEND=file
fi

if [[ "${commands[direnv]}" ]]; then
    eval "$(direnv hook zsh)"
fi

# Repeat given char N times using shell function
rep() {
    local start=1
    local end=${1:-80}
    local str="${2:-=}"
    eval "printf '$str%0.s' {$start..$end}"
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

# {{{ Fix fzf-tab plugin halt on ../<tab> in git repo
# https://stackoverflow.com/a/41420448/14110650
function fzf-tab-complete-wrapper() {
    zle fzf-tab-complete
}
zle -N fzf-tab-complete-wrapper
bindkey '^I' fzf-tab-complete-wrapper
# }}}

# WSL specific settings
if [[ "$(< /proc/sys/kernel/osrelease)" == *microsoft* ]]; then
    DISPLAY="$(ip route show default | sed -n 's/.*via \([^ ]\+\).*$/\1/p'):0"
    export DISPLAY
    if [[ -n $(pgrep ssh-agent) ]]; then
        if [[ -z $SSH_AGENT_PID ]]; then
            SSH_AGENT_PID="$(pgrep ssh-agent | head -n1)"; export SSH_AGENT_PID
            SSH_AUTH_SOCK="$(
                find /tmp -type s -name "agent.$((SSH_AGENT_PID-1))" 2>/dev/null
            )"
            export SSH_AUTH_SOCK
        fi
    else
        eval "$(ssh-agent -s)" >/dev/null
    fi
fi

# catppuccin fast-syntax-highlighting theme
fsh_theme="catppuccin-mocha"
# fast-theme -s | head -n 1 | awk '{print $NF}'
if [[ -e "$HOME/.config/fsh/$fsh_theme.ini" ]]; then
    fast-theme XDG:"$fsh_theme" --quiet
fi

# oh-my-tmux https://github.com/gpakosz/.tmux.git
if [[ "${commands[tmux]}" ]] && [ ! -d "$HOME/.tmux" ]; then
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    ln -s "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

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
        # shellcheck disable=1091
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
    function fgb() {
        lazy_fgb "$@"
    }
    function gbl() {
        lazy_fgb branch list "$@"
    }
    function gbm() {
        lazy_fgb branch manage "$@"
    }
    function gwl() {
        lazy_fgb worktree list "$@"
    }
    function gwm() {
        lazy_fgb worktree manage "$@"
    }
    function gwa() {
        lazy_fgb worktree add --confirm "$@"
    }
    function gwt() {
        lazy_fgb worktree total --confirm "$@"
    }
fi

# nvim-switcher
alias vl="NVIM_APPNAME=LazyVim nvim"

function nvs() {
    items=("default" "LazyVim")
    config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config: " --height=~50% --layout=reverse --border --exit-0)
    if [[ -z $config ]]; then
        echo "Nothing selected"
        return 0
    elif [[ $config == "default" ]]; then
        config=""
    fi
    NVIM_APPNAME=$config nvim "$@"
}

# The plugin will auto execute this zvm_after_init function
zvm_after_init() {
    [ -f "$HOME/.fzf.zsh" ] && eval "$(fzf --zsh | sed -e "s|fc -rl|fc -rlnt '%h/%d %H:%M:%S'|; s|LBUFFER=\"\$selected\"|selected=\"\${selected#* * }\"; LBUFFER=\"\${selected#* }\"|")"
}

# Aliases
# shellcheck disable=1091
source "$HOME/.aliases_sh.sh"
