aliae init pwsh --config "$HOME/.aliae.yaml" | Invoke-Expression

# Vi mode
Set-PSReadlineOption -EditMode Vi
# This example emits a cursor change VT escape in response to a Vi mode change.
function OnViModeChange
{
    if ($args[0] -eq 'Command')
    {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else
    {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

# Completions
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
    Import-Module "$ChocolateyProfile"
}

# Catppuccin theme
if (-not (Get-Module -ListAvailable -Name Catppuccin))
{
    $MyDocumentsLocation = [Environment]::GetFolderPath('MyDocuments')
    New-Item -Type Directory -Path "$MyDocumentsLocation\PowerShell\Modules" -ErrorAction SilentlyContinue
    git clone https://github.com/catppuccin/powershell.git "$MyDocumentsLocation\PowerShell\Modules\Catppuccin"
}
# Import the module https://github.com/catppuccin/powershell
Import-Module Catppuccin
# Set a flavor for easy access
$Flavor = $Catppuccin['Mocha']

# PSFzf Config
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Import-Module PSFzf
# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

$env:FZF_DEFAULT_COMMAND='fd --type f --follow --hidden --exclude .git'
$env:FZF_CTRL_T_COMMAND=$env:FZF_DEFAULT_COMMAND
$env:FZF_DEFAULT_OPTS = @"
--height=100%
--inline-info
--ansi
--scheme=history
--bind ctrl-/:toggle-preview
--bind alt-j:preview-down
--bind alt-k:preview-up
--bind alt-b:preview-page-up
--bind alt-f:preview-page-down
--bind alt-u:preview-half-page-up
--bind alt-d:preview-half-page-down
--bind alt-up:preview-top
--bind alt-down:preview-bottom
--bind ctrl-space:toggle+up
--bind ctrl-d:half-page-down
--bind ctrl-u:half-page-up
--bind ctrl-f:page-down
--bind ctrl-b:page-up
--color=bg+:$($Flavor.Surface0),bg:$($Flavor.Base),spinner:$($Flavor.Rosewater)
--color=hl:$($Flavor.Red),fg:$($Flavor.Text),header:$($Flavor.Red)
--color=info:$($Flavor.Mauve),pointer:$($Flavor.Rosewater),marker:$($Flavor.Rosewater)
--color=fg+:$($Flavor.Text),prompt:$($Flavor.Mauve),hl+:$($Flavor.Red)
--color=border:$($Flavor.Surface2)
"@

# PSReadLine Catppuccin theme
$Colors = @{
    # Largely based on the Code Editor style guide
    # Emphasis, ListPrediction and ListPredictionSelected are inspired by the Catppuccin fzf theme

    # Powershell colours
    ContinuationPrompt      = $Flavor.Teal.Foreground()
    Emphasis                = $Flavor.Red.Foreground()
    Selection               = $Flavor.Surface0.Background()

    # PSReadLine prediction  colours
    InlinePrediction        = $Flavor.Overlay0.Foreground()
    ListPrediction          = $Flavor.Mauve.Foreground()
    ListPredictionSelected  = $Flavor.Surface0.Background()

    # Syntax highlighting
    Command                 = $Flavor.Blue.Foreground()
    Comment                 = $Flavor.Overlay0.Foreground()
    Default                 = $Flavor.Text.Foreground()
    Error                   = $Flavor.Red.Foreground()
    Keyword                 = $Flavor.Mauve.Foreground()
    Member                  = $Flavor.Rosewater.Foreground()
    Number                  = $Flavor.Peach.Foreground()
    Operator                = $Flavor.Sky.Foreground()
    Parameter               = $Flavor.Pink.Foreground()
    String                  = $Flavor.Green.Foreground()
    Type                    = $Flavor.Yellow.Foreground()
    Variable                = $Flavor.Lavender.Foreground()
}
Set-PSReadLineOption -Colors $Colors

# The following colors are used by PowerShell's formatting
# Again PS 7.2+ only
$PSStyle.Formatting.Debug           = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error           = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent     = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent    = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader     = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose         = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning         = $Flavor.Peach.Foreground()

# Keybindings
# Alt+; to accept autosuggestion
Set-PSReadLineKeyHandler -Chord "Alt+;" -Function AcceptSuggestion
# Alt+Enter to execute autosuggestion
Set-PSReadLineKeyHandler -Chord "Alt+Enter" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
# Ctrl+Alt+l to move to the next word
Set-PSReadLineKeyHandler -Chord "Ctrl+Alt+l" -Function ForwardWord

Set-PSReadLineKeyHandler -Chord "Alt+l" -Function ClearScreen

# Aliases (alias-like functions)
# Git
Remove-Alias -Force -Name g 2>&1 | out-null; function g()
{
    git $args
}
Remove-Alias -Force -Name ga 2>&1 | out-null; function ga()
{
    git add $args
}
Remove-Alias -Force -Name gaa 2>&1 | out-null; function gaa()
{
    git add --all $args
}
Remove-Alias -Force -Name gapa 2>&1 | out-null; function gapa()
{
    git add --patch $args
}
Remove-Alias -Force -Name gau 2>&1 | out-null; function gau()
{
    git add --update $args
}
Remove-Alias -Force -Name gb 2>&1 | out-null; function gb()
{
    git branch $args
}
Remove-Alias -Force -Name gbD 2>&1 | out-null; function gbD()
{
    git branch -D $args
}
Remove-Alias -Force -Name gba 2>&1 | out-null; function gba()
{
    git branch -a $args
}
Remove-Alias -Force -Name gbd 2>&1 | out-null; function gbd()
{
    git branch -d $args
}
Remove-Alias -Force -Name gc 2>&1 | out-null; function gc()
{
    git commit -v $args
}
Remove-Alias -Force -Name gc! 2>&1 | out-null; function gc!()
{
    git commit -v --amend $args
}
Remove-Alias -Force -Name gcl 2>&1 | out-null; function gcl()
{
    git clone --recurse-submodules $args
}
Remove-Alias -Force -Name gcn! 2>&1 | out-null; function gcn!()
{
    git commit -v --no-edit --amend $args
}
Remove-Alias -Force -Name gco 2>&1 | out-null; function gco()
{
    git checkout $args
}
Remove-Alias -Force -Name gcp 2>&1 | out-null; function gcp()
{
    git cherry-pick $args
}
Remove-Alias -Force -Name gcpa 2>&1 | out-null; function gcpa()
{
    git cherry-pick --abort $args
}
Remove-Alias -Force -Name gcpc 2>&1 | out-null; function gcpc()
{
    git cherry-pick --continue $args
}
Remove-Alias -Force -Name gcpd! 2>&1 | out-null; function gcpd!()
{
    $env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD; git commit --amend $args; Remove-Item Env:GIT_COMMITTER_DATE
}
Remove-Alias -Force -Name gcpdn! 2>&1 | out-null; function gcpdn!()
{
    $env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD; git commit --amend --no-edit $args; Remove-Item Env:GIT_COMMITTER_DATE
}
Remove-Alias -Force -Name gcud! 2>&1 | out-null; function gcud!()
{
    git commit -v --amend --date=now $args
}
Remove-Alias -Force -Name gcudn! 2>&1 | out-null; function gcudn!()
{
    git commit --amend --date=now --no-edit $args
}
Remove-Alias -Force -Name gd 2>&1 | out-null; function gd()
{
    git diff $args
}
Remove-Alias -Force -Name gdca 2>&1 | out-null; function gdca()
{
    git diff --cached $args
}
Remove-Alias -Force -Name gdcw 2>&1 | out-null; function gdcw()
{
    git diff --cached --word-diff $args
}
Remove-Alias -Force -Name gds 2>&1 | out-null; function gds()
{
    git diff --staged $args
}
Remove-Alias -Force -Name ggsup 2>&1 | out-null; function ggsup()
{
    git branch --set-upstream-to=origin/$(git_current_branch) $args
}
Remove-Alias -Force -Name gl 2>&1 | out-null; function gl()
{
    git pull $args
}
Remove-Alias -Force -Name glg 2>&1 | out-null; function glg()
{
    git log --stat $args
}
Remove-Alias -Force -Name glgp 2>&1 | out-null; function glgp()
{
    git log --stat -p $args
}
Remove-Alias -Force -Name glo 2>&1 | out-null; function glo()
{
    git log --oneline --decorate $args
}
Remove-Alias -Force -Name gloga 2>&1 | out-null; function gloga()
{
    git log --oneline --decorate --graph --all $args
}
Remove-Alias -Force -Name glpf 2>&1 | out-null; function glpf()
{
    git log --pretty=fuller $args
}
Remove-Alias -Force -Name gm 2>&1 | out-null; function gm()
{
    git merge $args
}
Remove-Alias -Force -Name gma 2>&1 | out-null; function gma()
{
    git merge --abort $args
}
Remove-Alias -Force -Name gp 2>&1 | out-null; function gp()
{
    git push $args
}
Remove-Alias -Force -Name gpf 2>&1 | out-null; function gpf()
{
    git push --force-with-lease $args
}
Remove-Alias -Force -Name gpf! 2>&1 | out-null; function gpf!()
{
    git push --force $args
}
Remove-Alias -Force -Name gpsup 2>&1 | out-null; function gpsup()
{
    git push --set-upstream origin $(git_current_branch) $args
}
Remove-Alias -Force -Name gra 2>&1 | out-null; function gra()
{
    git remote add $args
}
Remove-Alias -Force -Name grb 2>&1 | out-null; function grb()
{
    git rebase $args
}
Remove-Alias -Force -Name grba 2>&1 | out-null; function grba()
{
    git rebase --abort $args
}
Remove-Alias -Force -Name grbc 2>&1 | out-null; function grbc()
{
    git rebase --continue $args
}
Remove-Alias -Force -Name grbi 2>&1 | out-null; function grbi()
{
    git rebase -i $args
}
Remove-Alias -Force -Name grbipd 2>&1 | out-null; function grbipd()
{
    git rebase -i --committer-date-is-author-date $args
}
Remove-Alias -Force -Name grbpd 2>&1 | out-null; function grbpd()
{
    git rebase --committer-date-is-author-date $args
}
Remove-Alias -Force -Name grbpdrm 2>&1 | out-null; function grbpd()
{
    git rebase --committer-date-is-author-date --rebase-merges $args
}
Remove-Alias -Force -Name grev 2>&1 | out-null; function grev()
{
    git revert $args
}
Remove-Alias -Force -Name grh 2>&1 | out-null; function grh()
{
    git reset $args
}
Remove-Alias -Force -Name grhh 2>&1 | out-null; function grhh()
{
    git reset --hard $args
}
Remove-Alias -Force -Name grs 2>&1 | out-null; function grs()
{
    git restore $args
}
Remove-Alias -Force -Name grv 2>&1 | out-null; function grv()
{
    git remote -v $args
}
Remove-Alias -Force -Name gss 2>&1 | out-null; function gss()
{
    git status -s $args
}
Remove-Alias -Force -Name gst 2>&1 | out-null; function gst()
{
    git status $args
}
Remove-Alias -Force -Name gsta 2>&1 | out-null; function gsta()
{
    git stash push $args
}
Remove-Alias -Force -Name gstaa 2>&1 | out-null; function gstaa()
{
    git stash apply $args
}
Remove-Alias -Force -Name gstc 2>&1 | out-null; function gstc()
{
    git stash clear $args
}
Remove-Alias -Force -Name gstd 2>&1 | out-null; function gstd()
{
    git stash drop $args
}
Remove-Alias -Force -Name gstl 2>&1 | out-null; function gstl()
{
    git stash list $args
}
Remove-Alias -Force -Name gstp 2>&1 | out-null; function gstp()
{
    git stash pop $args
}
Remove-Alias -Force -Name gsts 2>&1 | out-null; function gsts()
{
    git stash show --text $args
}
Remove-Alias -Force -Name gsts 2>&1 | out-null; function gsts()
{
    git stash show --text $args
}
Remove-Alias -Force -Name gsu 2>&1 | out-null; function gsu()
{
    git submodule update $args
}
Remove-Alias -Force -Name gsw 2>&1 | out-null; function gsw()
{
    git switch $args
}
Remove-Alias -Force -Name gswc 2>&1 | out-null; function gswc()
{
    git switch -c $args
}
Remove-Alias -Force -Name gupv 2>&1 | out-null; function gupv()
{
    git pull --rebase -v $args
}

Remove-Alias -Force -Name gcm 2>&1 | out-null; function gcm()
{
    git checkout main || git checkout master
}

New-Alias v nvim

New-Alias lg lazygit

# Python Virtual Environment activation
function Enter-VirtualEnvironment
{
    param (
        [string]$venvName = ".venv"
    )

    # Create the virtual environment
    python -m venv $venvName

    # Activate the virtual environment
    $activateScript = Join-Path $venvName "Scripts\Activate.ps1"
    if (Test-Path $activateScript)
    {
        . $activateScript
    } else
    {
        Write-Error "Failed to find Activate.ps1 script in the virtual environment."
    }
}
Set-Alias -Name activate -Value Enter-VirtualEnvironment

# gmom='git merge origin/$(git_main_branch)'
# gmtl='git mergetool --no-prompt'
# gmtlvim='git mergetool --no-prompt --tool=vimdiff'
# gmum='git merge upstream/$(git_main_branch)'
# gpd='git push --dry-run'
# gpoat='git push origin --all && git push origin --tags'
# gpr='git pull --rebase'
# gpristine='git reset --hard && git clean -dffx'
# gpu='git push upstream'
# gpv='git push -v'
# gr='git remote'
# grbd='git rebase $(git_develop_branch)'
# grbipdrm='git rebase -i --committer-date-is-author-date --rebase-merges'
# grbm='git rebase $(git_main_branch)'
# grbo='git rebase --onto'
# grbom='git rebase origin/$(git_main_branch)'
# grbs='git rebase --skip'
# grm='git rm'
# grmc='git rm --cached'
# grmv='git remote rename'
# groh='git reset origin/$(git_current_branch) --hard'
# grrm='git remote remove'
# grset='git remote set-url'
# grss='git restore --source'
# grst='git restore --staged'
# grt='cd "$(git rev-parse --show-toplevel || echo .)"'
# gru='git reset --'
# grup='git remote update'
# gsb='git status -sb'
# gsd='git svn dcommit'
# gsh='git show'
# gsi='git submodule init'
# gsps='git show --pretty=short --show-signature'
# gstall='git stash --all'
# gswd='git switch $(git_develop_branch)'
# gswm='git switch $(git_main_branch)'
# gtl='gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'
# gts='git tag -s'
# gunignore='git update-index --no-assume-unchanged'
# gunwip='git log -n 1 | grep -q -c "\--wip--" && git reset HEAD~1'
# gup='git pull --rebase'
# gupa='git pull --rebase --autostash'
# gupav='git pull --rebase --autostash -v'
# gupom='git pull --rebase origin $(git_main_branch)'
# gupomi='git pull --rebase=interactive origin $(git_main_branch)'
# gupv='git pull --rebase -v'
# gwch='git whatchanged -p --abbrev-commit --pretty=medium'
# gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
# gwt='git worktree'
# gwta='git worktree add'
# gwtls='git worktree list'
# gwtmv='git worktree move'
# gwtrm='git worktree remove'

# gam='git am'
# gama='git am --abort'
# gamc='git am --continue'
# gams='git am --skip'
# gamscp='git am --show-current-patch'
# gap='git apply'
# gapt='git apply --3way'
# gav='git add --verbose'
# gbda='git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch -d 2>/dev/null'
# gbl='git blame -b -w'
# gbnm='git branch --no-merged'
# gbr='git branch --remote'
# gbs='git bisect'
# gbsb='git bisect bad'
# gbsg='git bisect good'
# gbsr='git bisect reset'
# gbss='git bisect start'
# gca='git commit -v -a'
# 'gca!'='git commit -v -a --amend'
# gcam='git commit -a -m'
# 'gcan!'='git commit -v -a --no-edit --amend'
# 'gcans!'='git commit -v -a -s --no-edit --amend'
# gcas='git commit -a -s'
# gcasm='git commit -a -s -m'
# gcb='git checkout -b'
# gcd='git checkout $(git_develop_branch)'
# gcf='git config --list'
# gch='git checkout $(git config gitflow.prefix.hotfix)'
# gclean='git clean -id'
# gcmsg='git commit -m'
# gcn='git commit -v --no-edit'
# gcor='git checkout --recurse-submodules'
# gcount='git shortlog -sn'
# gcr='git checkout $(git config gitflow.prefix.release)'
# gcs='git commit -S'
# gcsm='git commit -s -m'
# gcss='git commit -S -s'
# gcssm='git commit -S -s -m'
# gct=forgit::checkout::tag
# gdct='git describe --tags $(git rev-list --tags --max-count=1)'
# gdt='git diff-tree --no-commit-id --name-only -r'
# gdup='git diff @{upstream}'
# gdw='git diff --word-diff'
# gf='git fetch'
# gfa='git fetch --all --prune --jobs=10'
# gfg='git ls-files | grep'
# gfl='git flow'
# gflf='git flow feature'
# gflff='git flow feature finish'
# gflffc='git flow feature finish ${$(git_current_branch)#feature/}'
# gflfp='git flow feature publish'
# gflfpc='git flow feature publish ${$(git_current_branch)#feature/}'
# gflfpll='git flow feature pull'
# gflfs='git flow feature start'
# gflh='git flow hotfix'
# gflhf='git flow hotfix finish'
# gflhfc='git flow hotfix finish ${$(git_current_branch)#hotfix/}'
# gflhp='git flow hotfix publish'
# gflhpc='git flow hotfix publish ${$(git_current_branch)#hotfix/}'
# gflhs='git flow hotfix start'
# gfli='git flow init'
# gflr='git flow release'
# gflrf='git flow release finish'
# gflrfc='git flow release finish ${$(git_current_branch)#release/}'
# gflrp='git flow release publish'
# gflrpc='git flow release publish ${$(git_current_branch)#release/}'
# gflrs='git flow release start'
# gfo='git fetch origin'
# gg='git gui citool'
# gga='git gui citool --amend'
# ggpull='git pull origin "$(git_current_branch)"'
# ggpush='git push origin "$(git_current_branch)"'
# ghh='git help'
# ghtkn='gpg /home/andrei/Github/workspace/github_token.gpg; source /home/andrei/Github/workspace/github_token; rm -f /home/andrei/Github/workspace/github_token'
# gignore='git update-index --assume-unchanged'
# gignored='git ls-files -v | grep "^[[:lower:]]"'
# glall='git branch -r | grep -v "\->" | while read remote; do git branch --track "${remote#origin/}" "$remote"; done'
# glgg='git log --graph'
# glgga='git log --graph --decorate --all'
# glgm='git log --graph --max-count=10'
# glod='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'
# glods='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'' --date=short'
# glog='git log --oneline --decorate --graph'
# glol='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'
# glola='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'' --all'
# glols='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'' --stat'
# glp=_git_log_prettily
# gluc='git pull upstream $(git_current_branch)'
# glum='git pull upstream $(git_main_branch)'
