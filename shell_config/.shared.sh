set_poshcontext() {
    POSH_PATH_MAX_WIDTH="$(tput cols)"
    export POSH_PATH_MAX_WIDTH
}

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

if command -v "eza" &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview '${FZF_PREVIEW_STRING/$\'\n\'/}'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons --all --git {}'"

    # Advanced customization of fzf options via _fzf_comprun function
    # - The first argument to the function is the name of the command.
    # - You should make sure to pass the rest of the arguments to fzf.
    _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
        cd | z)
            EZA_OPTS="eza --tree --level=2 --group-directories-first --color=always --color-scale \
          --icons --all --git {}"
            fzf --preview "${EZA_OPTS/$\'\n\'/}" "$@"
            ;;
        export | unset)
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

# Git helper functions
git_current_branch() {
    command git rev-parse --git-dir &>/dev/null || return
    git branch --show-current
}

git_develop_branch() {
    command git rev-parse --git-dir &>/dev/null || return
    local branch
    for branch in dev devel development; do
        if command git show-ref -q --verify refs/heads/"$branch"; then
            echo "$branch"
            return
        fi
    done
    echo develop
}

git_main_branch() {
    command git rev-parse --git-dir &>/dev/null || return
    local ref
    for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
        if command git show-ref -q --verify "$ref"; then
            echo "${ref:t}"
            return
        fi
    done
    echo master
}

# Git aliases/functions
alias cdgr='cd "$(git rev-parse --show-toplevel)"'
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git apply'
alias gau='git add --update'
alias gb='git branch'
alias gbD='git branch -D'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsc='git_current_branch'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gc!='git commit --amend --verbose'
alias gc='git commit --verbose'
alias gcd='git switch "$(git_develop_branch)"'
alias gcl='git clone --recurse-submodules'
alias gclean='git clean --interactive -d'
alias gcm='git switch "$(git_main_branch)"'
alias gcn!='git commit --amend --no-edit --verbose'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcpd!='GIT_COMMITTER_DATE=$(git log -n 1 --format=%aD) git commit --amend --verbose'
alias gcpdn!='GIT_COMMITTER_DATE=$(git log -n 1 --format=%aD) git commit --amend --no-edit'
alias gcpdns!='GIT_COMMITTER_DATE=$(git log -n 1 --format=%aD) git commit --amend --no-edit --gpg-sign'
alias gcpds!='GIT_COMMITTER_DATE=$(git log -n 1 --format=%aD) git commit --amend --gpg-sign --verbose'
alias gcps='git cherry-pick --skip'
alias gcs='git commit --gpg-sign --verbose'
alias gcud!='git commit --amend --date=now --verbose'
alias gcudn!='git commit --amend --date=now --no-edit --verbose'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gdh='git -c delta.side-by-side=true diff'
alias gds='git diff --staged'
alias ggsup='git branch --set-upstream-to=origin'
alias gl='git pull'
# shellcheck disable=2154
alias glall='git branch -r | grep -v "\->" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias glo='git log --oneline --decorate'
alias gloga='git log --oneline --decorate --graph --all'
alias glpf='git log --pretty=fuller'
alias glr='git pull --rebase=merges --verbose'
alias gls='git ls-files'
alias glsa='git ls-files "$(git rev-parse --show-toplevel)"'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf!='git push --force'
alias gpf='git push --force-with-lease'
alias gpsup='git push --set-upstream origin "$(git_current_branch)"'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbipd='git rebase --interactive --committer-date-is-author-date'
alias grbipdrm='git rebase --interactive --committer-date-is-author-date --rebase-merges'
alias grbirm='git rebase --interactive --rebase-merges'
alias grbpd='git rebase --committer-date-is-author-date'
alias grbpdrm='git rebase --committer-date-is-author-date --rebase-merges'
alias grbrm='git rebase --rebase-merges'
alias grbs='git rebase --skip'
alias grefs='git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"'
alias grev='git revert'
alias greva='git revert --abort'
alias grevc='git revert --continue'
alias grevq='git revert --quit'
alias grh='git reset'
alias grhh='git reset --hard'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grs='git restore'
alias grset='git remote set-url'
alias grt='cd "$(git rev-parse --show-toplevel)"'
alias grv='git remote --verbose'
alias gss='git status --short'
alias gst='git status'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gsu='git submodule update'
alias gsw='git switch'
alias gswc='git switch --create'
alias gupv='git pull --rebase --verbose'
