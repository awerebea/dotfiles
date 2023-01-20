oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/awerebea.omp.json" | Invoke-Expression

# Vi mode
Set-PSReadlineOption -EditMode Vi
# This example emits a cursor change VT escape in response to a Vi mode change.
function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
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
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

# PSFzf Config
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Import-Module PSFzf
# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

$env:FZF_DEFAULT_COMMAND='fd --type f --follow --hidden --exclude .git'
$env:FZF_CTRL_T_COMMAND=$env:FZF_DEFAULT_COMMAND
$env:FZF_DEFAULT_OPTS="--height=100%  --inline-info --ansi --scheme=history --bind ctrl-/:toggle-preview,alt-j:preview-down,alt-k:preview-up,alt-b:preview-page-up,alt-f:preview-page-down,alt-u:preview-half-page-up,alt-d:preview-half-page-down,alt-up:preview-top,alt-down:preview-bottom,ctrl-space:toggle+up,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-f:page-down,ctrl-b:page-up"

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
Remove-Alias -Force -Name g 2>&1 | out-null; function g() { git $args }
Remove-Alias -Force -Name ga 2>&1 | out-null; function ga() { git add $args }
Remove-Alias -Force -Name gaa 2>&1 | out-null; function gaa() { git add --all $args }
Remove-Alias -Force -Name gapa 2>&1 | out-null; function gapa() { git add --patch $args }
Remove-Alias -Force -Name gau 2>&1 | out-null; function gau() { git add --update $args }
Remove-Alias -Force -Name gb 2>&1 | out-null; function gb() { git branch $args }
Remove-Alias -Force -Name gbD 2>&1 | out-null; function gbD() { git branch -D $args }
Remove-Alias -Force -Name gba 2>&1 | out-null; function gba() { git branch -a $args }
Remove-Alias -Force -Name gbd 2>&1 | out-null; function gbd() { git branch -d $args }
Remove-Alias -Force -Name gc 2>&1 | out-null; function gc() { git commit -v $args }
Remove-Alias -Force -Name gc! 2>&1 | out-null; function gc!() { git commit -v --amend $args }
Remove-Alias -Force -Name gcl 2>&1 | out-null; function gcl() { git clone --recurse-submodules $args }
Remove-Alias -Force -Name gcm 2>&1 | out-null; function gcm() { git checkout $(git_main_branch) $args }
Remove-Alias -Force -Name gcn! 2>&1 | out-null; function gcn!() { git commit -v --no-edit --amend $args }
Remove-Alias -Force -Name gco 2>&1 | out-null; function gco() { git checkout $args }
Remove-Alias -Force -Name gcp 2>&1 | out-null; function gcp() { git cherry-pick $args }
Remove-Alias -Force -Name gcpa 2>&1 | out-null; function gcpa() { git cherry-pick --abort $args }
Remove-Alias -Force -Name gcpc 2>&1 | out-null; function gcpc() { git cherry-pick --continue $args }
Remove-Alias -Force -Name gcpd! 2>&1 | out-null; function gcpd!() { $env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD; git commit --amend $args; Remove-Item Env:GIT_COMMITTER_DATE }
Remove-Alias -Force -Name gcpdn! 2>&1 | out-null; function gcpdn!() { $env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD; git commit --amend --no-edit $args; Remove-Item Env:GIT_COMMITTER_DATE }
Remove-Alias -Force -Name gcud! 2>&1 | out-null; function gcud!() { git commit -v --amend --date=now $args }
Remove-Alias -Force -Name gcudn! 2>&1 | out-null; function gcudn!() { git commit --amend --date=now --no-edit $args }
Remove-Alias -Force -Name gd 2>&1 | out-null; function gd() { git diff $args }
Remove-Alias -Force -Name gdca 2>&1 | out-null; function gdca() { git diff --cached $args }
Remove-Alias -Force -Name gdcw 2>&1 | out-null; function gdcw() { git diff --cached --word-diff $args }
Remove-Alias -Force -Name gds 2>&1 | out-null; function gds() { git diff --staged $args }
Remove-Alias -Force -Name ggsup 2>&1 | out-null; function ggsup() { git branch --set-upstream-to=origin/$(git_current_branch) $args }
Remove-Alias -Force -Name gl 2>&1 | out-null; function gl() { git pull $args }
Remove-Alias -Force -Name glg 2>&1 | out-null; function glg() { git log --stat $args }
Remove-Alias -Force -Name glgp 2>&1 | out-null; function glgp() { git log --stat -p $args }
Remove-Alias -Force -Name glo 2>&1 | out-null; function glo() { git log --oneline --decorate $args }
Remove-Alias -Force -Name gloga 2>&1 | out-null; function gloga() { git log --oneline --decorate --graph --all $args }
Remove-Alias -Force -Name glpf 2>&1 | out-null; function glpf() { git log --pretty=fuller $args }
Remove-Alias -Force -Name gm 2>&1 | out-null; function gm() { git merge $args }
Remove-Alias -Force -Name gma 2>&1 | out-null; function gma() { git merge --abort $args }
Remove-Alias -Force -Name gp 2>&1 | out-null; function gp() { git push $args }
Remove-Alias -Force -Name gpf 2>&1 | out-null; function gpf() { git push --force-with-lease $args }
Remove-Alias -Force -Name gpf! 2>&1 | out-null; function gpf!() { git push --force $args }
Remove-Alias -Force -Name gpsup 2>&1 | out-null; function gpsup() { git push --set-upstream origin $(git_current_branch) $args }
Remove-Alias -Force -Name gra 2>&1 | out-null; function gra() { git remote add $args }
Remove-Alias -Force -Name grb 2>&1 | out-null; function grb() { git rebase $args }
Remove-Alias -Force -Name grba 2>&1 | out-null; function grba() { git rebase --abort $args }
Remove-Alias -Force -Name grbc 2>&1 | out-null; function grbc() { git rebase --continue $args }
Remove-Alias -Force -Name grbi 2>&1 | out-null; function grbi() { git rebase -i $args }
Remove-Alias -Force -Name grbipd 2>&1 | out-null; function grbipd() { git rebase -i --committer-date-is-author-date $args }
Remove-Alias -Force -Name grev 2>&1 | out-null; function grev() { git revert $args }
Remove-Alias -Force -Name grh 2>&1 | out-null; function grh() { git reset $args }
Remove-Alias -Force -Name grhh 2>&1 | out-null; function grhh() { git reset --hard $args }
Remove-Alias -Force -Name grs 2>&1 | out-null; function grs() { git restore $args }
Remove-Alias -Force -Name grv 2>&1 | out-null; function grv() { git remote -v $args }
Remove-Alias -Force -Name gss 2>&1 | out-null; function gss() { git status -s $args }
Remove-Alias -Force -Name gst 2>&1 | out-null; function gst() { git status $args }
Remove-Alias -Force -Name gsta 2>&1 | out-null; function gsta() { git stash push $args }
Remove-Alias -Force -Name gstaa 2>&1 | out-null; function gstaa() { git stash apply $args }
Remove-Alias -Force -Name gstc 2>&1 | out-null; function gstc() { git stash clear $args }
Remove-Alias -Force -Name gstd 2>&1 | out-null; function gstd() { git stash drop $args }
Remove-Alias -Force -Name gstl 2>&1 | out-null; function gstl() { git stash list $args }
Remove-Alias -Force -Name gstp 2>&1 | out-null; function gstp() { git stash pop $args }
Remove-Alias -Force -Name gsts 2>&1 | out-null; function gsts() { git stash show --text $args }
Remove-Alias -Force -Name gsts 2>&1 | out-null; function gsts() { git stash show --text $args }
Remove-Alias -Force -Name gsu 2>&1 | out-null; function gsu() { git submodule update $args }
Remove-Alias -Force -Name gsw 2>&1 | out-null; function gsw() { git switch $args }
Remove-Alias -Force -Name gswc 2>&1 | out-null; function gswc() { git switch -c $args }

New-Alias v nvim
