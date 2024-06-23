set_poshcontext() {
    POSH_PATH_MAX_WIDTH="$(tput cols)"
    export POSH_PATH_MAX_WIDTH
}

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
alias gclean='git clean -id'
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
