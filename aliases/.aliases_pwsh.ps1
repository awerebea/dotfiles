if (Get-Command oh-my-posh -ErrorAction SilentlyContinue)
{
    function Set-PoshEnvVars
    {
        $env:POSH_PATH_MAX_WIDTH = $Host.UI.RawUI.WindowSize.Width
    }
    New-Alias -Name 'Set-PoshContext' -Value 'Set-PoshEnvVars' -Scope Global -Force
}


# Git helper functions
function Get-GitCurrentBranch
{
    if (-not (git rev-parse --git-dir 2>&1 | out-null))
    {
        return
    }
    git branch --show-current
}

function Get-GitMainBranch
{
    if (-not (git rev-parse --git-dir 2>&1 | out-null))
    {
        return
    }
    $refs = @(
        "refs/heads/main",
        "refs/heads/trunk",
        "refs/heads/mainline",
        "refs/heads/default",
        "refs/remotes/origin/main",
        "refs/remotes/origin/trunk",
        "refs/remotes/origin/mainline",
        "refs/remotes/origin/default",
        "refs/remotes/upstream/main",
        "refs/remotes/upstream/trunk",
        "refs/remotes/upstream/mainline",
        "refs/remotes/upstream/default"
    )
    foreach ($ref in $refs)
    {
        if (git show-ref -q --verify $ref)
        {
            Write-Output $ref.Split('/')[-1]
            return
        }
    }
    Write-Output "master"
}

function Get-GitDevelopmentBranch
{
    if (-not (git rev-parse --git-dir 2>&1 | out-null))
    {
        return
    }
    $branches = @("dev", "devel", "development")
    foreach ($branch in $branches)
    {
        if (git show-ref -q --verify "refs/heads/$branch")
        {
            Write-Output $branch
            return
        }
    }
    Write-Output "develop"
}

# Git aliases/functions
function Invoke-Git
{
    git $args
}
New-Alias -Name 'g' -Value 'Invoke-Git' -Scope Global -Force

function Invoke-GitAdd
{
    git add $args
}
New-Alias -Name 'ga' -Value 'Invoke-GitAdd' -Scope Global -Force

function Invoke-GitAddAll
{
    git add --all $args
}
New-Alias -Name 'gaa' -Value 'Invoke-GitAddAll' -Scope Global -Force

function Invoke-GitAddUpdate
{
    git add --update $args
}
New-Alias -Name 'gau' -Value 'Invoke-GitAddUpdate' -Scope Global -Force

function Invoke-GitApply
{
    git apply $args
}
New-Alias -Name 'gap' -Value 'Invoke-GitApply' -Scope Global -Force

function Invoke-GitBranch
{
    git branch $args
}
New-Alias -Name 'gb' -Value 'Invoke-GitBranch' -Scope Global -Force

function Invoke-GitBranchAll
{
    git branch --all $args
}
New-Alias -Name 'gba' -Value 'Invoke-GitBranchAll' -Scope Global -Force

function Invoke-GitBranchDelete
{
    git branch --delete $args
}
New-Alias -Name 'gbd' -Value 'Invoke-GitBranchDelete' -Scope Global -Force

function Invoke-GitBranchDeleteForce
{
    git branch -D $args
}
New-Alias -Name 'gbD' -Value 'Invoke-GitBranchDeleteForce' -Scope Global -Force

function Invoke-GitCommitVerbose
{
    git commit --verbose $args
}
New-Alias -Name 'gc' -Value 'Invoke-GitCommitVerbose' -Scope Global -Force

function Invoke-GitSwitchDevelopmentBranch
{
    git switch $(Get-GitDevelopmentBranch) $args
}
New-Alias -Name 'gcd' -Value 'Invoke-GitSwitchDevelopmentBranch' -Scope Global -Force

function Invoke-GitCommitVerboseGpgSign
{
    git commit --verbose --gpg-sign $args
}
New-Alias -Name 'gcs' -Value 'Invoke-GitCommitVerboseGpgSign' -Scope Global -Force

function Invoke-GitCommitAmendVerbose
{
    git commit --amend --verbose $args
}
New-Alias -Name 'gc!' -Value 'Invoke-GitCommitAmendVerbose' -Scope Global -Force

function Invoke-GitCloneRecursesubmodules
{
    git clone --recurse-submodules $args
}
New-Alias -Name 'gcl' -Value 'Invoke-GitCloneRecursesubmodules' -Scope Global -Force

function Invoke-GitCleanId
{
    git clean -id $args
}
New-Alias -Name 'gclean' -Value 'Invoke-GitCleanId' -Scope Global -Force

function Invoke-GitSwitchMainBranch
{
    git switch $(Get-GitMainBranch) $args
}
New-Alias -Name 'gcm' -Value 'Invoke-GitSwitchMainBranch' -Scope Global -Force

function Invoke-GitCommitAmendNoeditVerbose
{
    git commit --amend --no-edit --verbose $args
}
New-Alias -Name 'gcn!' -Value 'Invoke-GitCommitAmendNoeditVerbose' -Scope Global -Force

function Invoke-GitCheckout
{
    git checkout $args
}
New-Alias -Name 'gco' -Value 'Invoke-GitCheckout' -Scope Global -Force

function Invoke-GitCherrypick
{
    git cherry-pick $args
}
New-Alias -Name 'gcp' -Value 'Invoke-GitCherrypick' -Scope Global -Force

function Invoke-GitCherrypickAbort
{
    git cherry-pick --abort $args
}
New-Alias -Name 'gcpa' -Value 'Invoke-GitCherrypickAbort' -Scope Global -Force

function Invoke-GitCherrypickContinue
{
    git cherry-pick --continue $args
}
New-Alias -Name 'gcpc' -Value 'Invoke-GitCherrypickContinue' -Scope Global -Force

function Invoke-GitCommitAmend
{
    "$env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD
    git commit --amend $args
    Remove-Item Env:GIT_COMMITTER_DATE"
}
New-Alias -Name 'gcpd!' -Value 'Invoke-GitCommitAmend' -Scope Global -Force

function Invoke-GitCommitAmendNoEdit
{
    "$env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD
    git commit --amend --no-edit $args
    Remove-Item Env:GIT_COMMITTER_DATE"
}
New-Alias -Name 'gcpdn!' -Value 'Invoke-GitCommitAmendNoEdit' -Scope Global -Force

function Invoke-GitCommitAmendNoEditGpgSign
{
    "$env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD
    git commit --amend --no-edit --gpg-sign $args
    Remove-Item Env:GIT_COMMITTER_DATE"
}
New-Alias -Name 'gcpdns!' -Value 'Invoke-GitCommitAmendNoEditGpgSign' -Scope Global -Force

function Invoke-GitCommitAmendGpgSign
{
    "$env:GIT_COMMITTER_DATE = git log -n 1 --format=%aD
    git commit --amend --gpg-sign $args
    Remove-Item Env:GIT_COMMITTER_DATE"
}
New-Alias -Name 'gcpds!' -Value 'Invoke-GitCommitAmendGpgSign' -Scope Global -Force

function Invoke-GitCherrypickSkip
{
    git cherry-pick --skip $args
}
New-Alias -Name 'gcps' -Value 'Invoke-GitCherrypickSkip' -Scope Global -Force

function Invoke-GitCommitAmendDateNowVerbose
{
    git commit --amend --date=now --verbose $args
}
New-Alias -Name 'gcud!' -Value 'Invoke-GitCommitAmendDateNowVerbose' -Scope Global -Force

function Invoke-GitCommitAmendNoeditDateNowVerbose
{
    git commit --amend --no-edit --date=now --verbose $args
}
New-Alias -Name 'gcudn!' -Value 'Invoke-GitCommitAmendNoeditDateNowVerbose' -Scope Global -Force

function Invoke-GitDiff
{
    git diff $args
}
New-Alias -Name 'gd' -Value 'Invoke-GitDiff' -Scope Global -Force

function Invoke-GitDiffCached
{
    git diff --cached $args
}
New-Alias -Name 'gdca' -Value 'Invoke-GitDiffCached' -Scope Global -Force

function Invoke-GitDiffCachedWorddiff
{
    git diff --cached --word-diff $args
}
New-Alias -Name 'gdcw' -Value 'Invoke-GitDiffCachedWorddiff' -Scope Global -Force

function Invoke-GitDiffStaged
{
    git diff --staged $args
}
New-Alias -Name 'gds' -Value 'Invoke-GitDiffStaged' -Scope Global -Force

function Invoke-GitBranchSetupstreamtoOrigin
{
    git branch --set-upstream-to=origin $args
}
New-Alias -Name 'ggsup' -Value 'Invoke-GitBranchSetupstreamtoOrigin' -Scope Global -Force

function Invoke-GitPull
{
    git pull $args
}
New-Alias -Name 'gl' -Value 'Invoke-GitPull' -Scope Global -Force

function Invoke-GitTrackAllOriginBranches
{
    $remoteBranches = git branch -r | Where-Object { $_ -notmatch '->' }
    foreach ($remote in $remoteBranches)
    {
        $branchName = $remote -replace '^origin/', ''
        git branch --track $branchName $remote
    }
}
New-Alias -Name 'glall' -Value 'Invoke-GitTrackAllOriginBranches' -Scope Global -Force

function Invoke-GitPullRebaseMergesVerbose
{
    git pull --rebase=merges --verbose $args
}
New-Alias -Name 'glr' -Value 'Invoke-GitPullRebaseMergesVerbose' -Scope Global -Force

function Invoke-GitLogStat
{
    git log --stat $args
}
New-Alias -Name 'glg' -Value 'Invoke-GitLogStat' -Scope Global -Force

function Invoke-GitLogStatPatch
{
    git log --stat --patch $args
}
New-Alias -Name 'glgp' -Value 'Invoke-GitLogStatPatch' -Scope Global -Force

function Invoke-GitLogOnelineDecorate
{
    git log --oneline --decorate $args
}
New-Alias -Name 'glo' -Value 'Invoke-GitLogOnelineDecorate' -Scope Global -Force

function Invoke-GitLogOnelineDecorateGraphAll
{
    git log --oneline --decorate --graph --all $args
}
New-Alias -Name 'gloga' -Value 'Invoke-GitLogOnelineDecorateGraphAll' -Scope Global -Force

function Invoke-GitLogPrettyFuller
{
    git log --pretty=fuller $args
}
New-Alias -Name 'glpf' -Value 'Invoke-GitLogPrettyFuller' -Scope Global -Force

function Invoke-GitMerge
{
    git merge $args
}
New-Alias -Name 'gm' -Value 'Invoke-GitMerge' -Scope Global -Force

function Invoke-GitMergeContinue
{
    git merge --continue $args
}
New-Alias -Name 'gmc' -Value 'Invoke-GitMergeContinue' -Scope Global -Force

function Invoke-GitMergeAbort
{
    git merge --abort $args
}
New-Alias -Name 'gma' -Value 'Invoke-GitMergeAbort' -Scope Global -Force

function Invoke-GitPush
{
    git push $args
}
New-Alias -Name 'gp' -Value 'Invoke-GitPush' -Scope Global -Force

function Invoke-GitPushForcewithlease
{
    git push --force-with-lease $args
}
New-Alias -Name 'gpf' -Value 'Invoke-GitPushForcewithlease' -Scope Global -Force

function Invoke-GitPushSetUpstreamOriginCurrentBranch
{
    git push --set-upstream origin "$(Get-GitCurrentBranch)" $args
}
New-Alias -Name 'gpsup' -Value 'Invoke-GitPushSetUpstreamOriginCurrentBranch' -Scope Global -Force

function Invoke-GitPushForce
{
    git push --force $args
}
New-Alias -Name 'gpf!' -Value 'Invoke-GitPushForce' -Scope Global -Force

function Invoke-GitRemoteAdd
{
    git remote add $args
}
New-Alias -Name 'gra' -Value 'Invoke-GitRemoteAdd' -Scope Global -Force

function Invoke-GitRebase
{
    git rebase $args
}
New-Alias -Name 'grb' -Value 'Invoke-GitRebase' -Scope Global -Force

function Invoke-GitRebaseAbort
{
    git rebase --abort $args
}
New-Alias -Name 'grba' -Value 'Invoke-GitRebaseAbort' -Scope Global -Force

function Invoke-GitRebaseContinue
{
    git rebase --continue $args
}
New-Alias -Name 'grbc' -Value 'Invoke-GitRebaseContinue' -Scope Global -Force

function Invoke-GitRebaseSkip
{
    git rebase --skip $args
}
New-Alias -Name 'grbs' -Value 'Invoke-GitRebaseSkip' -Scope Global -Force

function Invoke-GitRebaseInteractive
{
    git rebase --interactive $args
}
New-Alias -Name 'grbi' -Value 'Invoke-GitRebaseInteractive' -Scope Global -Force

function Invoke-GitRebaseInteractiveCommitterDateIsAuthorDate
{
    git rebase --interactive --committer-date-is-author-date $args
}
New-Alias -Name 'grbipd' -Value 'Invoke-GitRebaseInteractiveCommitterDateIsAuthorDate' -Scope Global -Force

function Invoke-GitRebaseCommitterDateIsAuthorDate
{
    git rebase --committer-date-is-author-date $args
}
New-Alias -Name 'grbpd' -Value 'Invoke-GitRebaseCommitterDateIsAuthorDate' -Scope Global -Force

function Invoke-GitRebaseInteractiveRebaseMerges
{
    git rebase --interactive --rebase-merges $args
}
New-Alias -Name 'grbirm' -Value 'Invoke-GitRebaseInteractiveRebaseMerges' -Scope Global -Force

function Invoke-GitRebaseRebaseMerges
{
    git rebase --rebase-merges $args
}
New-Alias -Name 'grbrm' -Value 'Invoke-GitRebaseRebaseMerges' -Scope Global -Force

function Invoke-GitRebaseInteractiveCommitterDateIsAuthorDateRebaseMerges
{
    git rebase --interactive --committer-date-is-author-date --rebase-merges $args
}
New-Alias -Name 'grbipdrm' -Value 'Invoke-GitRebaseInteractiveCommitterDateIsAuthorDateRebaseMerges' -Scope Global -Force

function Invoke-GitRebaseCommitterDateIsAuthorDateRebaseMerges
{
    git rebase --committer-date-is-author-date --rebase-merges $args
}
New-Alias -Name 'grbpdrm' -Value 'Invoke-GitRebaseCommitterDateIsAuthorDateRebaseMerges' -Scope Global -Force

function Invoke-GitRevert
{
    git revert $args
}
New-Alias -Name 'grev' -Value 'Invoke-GitRevert' -Scope Global -Force

function Invoke-GitReset
{
    git reset $args
}
New-Alias -Name 'grh' -Value 'Invoke-GitReset' -Scope Global -Force

function Invoke-GitResetHard
{
    git reset --hard $args
}
New-Alias -Name 'grhh' -Value 'Invoke-GitResetHard' -Scope Global -Force

function Invoke-GitRestore
{
    git restore $args
}
New-Alias -Name 'grs' -Value 'Invoke-GitRestore' -Scope Global -Force

function Invoke-GitRemoteVerbose
{
    git remote --verbose $args
}
New-Alias -Name 'grv' -Value 'Invoke-GitRemoteVerbose' -Scope Global -Force

function Invoke-GitStatusShort
{
    git status --short $args
}
New-Alias -Name 'gss' -Value 'Invoke-GitStatusShort' -Scope Global -Force

function Invoke-GitStatus
{
    git status $args
}
New-Alias -Name 'gst' -Value 'Invoke-GitStatus' -Scope Global -Force

function Invoke-GitStashPush
{
    git stash push $args
}
New-Alias -Name 'gsta' -Value 'Invoke-GitStashPush' -Scope Global -Force

function Invoke-GitStashApply
{
    git stash apply $args
}
New-Alias -Name 'gstaa' -Value 'Invoke-GitStashApply' -Scope Global -Force

function Invoke-GitStashClear
{
    git stash clear $args
}
New-Alias -Name 'gstc' -Value 'Invoke-GitStashClear' -Scope Global -Force

function Invoke-GitStashDrop
{
    git stash drop $args
}
New-Alias -Name 'gstd' -Value 'Invoke-GitStashDrop' -Scope Global -Force

function Invoke-GitStashList
{
    git stash list $args
}
New-Alias -Name 'gstl' -Value 'Invoke-GitStashList' -Scope Global -Force

function Invoke-GitStashPop
{
    git stash pop $args
}
New-Alias -Name 'gstp' -Value 'Invoke-GitStashPop' -Scope Global -Force

function Invoke-GitStashShowText
{
    git stash show --text $args
}
New-Alias -Name 'gsts' -Value 'Invoke-GitStashShowText' -Scope Global -Force

function Invoke-GitSubmoduleUpdate
{
    git submodule update $args
}
New-Alias -Name 'gsu' -Value 'Invoke-GitSubmoduleUpdate' -Scope Global -Force

function Invoke-GitSwitch
{
    git switch $args
}
New-Alias -Name 'gsw' -Value 'Invoke-GitSwitch' -Scope Global -Force

function Invoke-GitSwitchCreate
{
    git switch --create $args
}
New-Alias -Name 'gswc' -Value 'Invoke-GitSwitchCreate' -Scope Global -Force

function Invoke-GitPushDryrun
{
    git push --dry-run $args
}
New-Alias -Name 'gpd' -Value 'Invoke-GitPushDryrun' -Scope Global -Force

function Invoke-GitRemote
{
    git remote $args
}
New-Alias -Name 'gr' -Value 'Invoke-GitRemote' -Scope Global -Force

function Invoke-GitRemoteRename
{
    git remote rename $args
}
New-Alias -Name 'grmv' -Value 'Invoke-GitRemoteRename' -Scope Global -Force

function Invoke-GitRemoteRemove
{
    git remote remove $args
}
New-Alias -Name 'grrm' -Value 'Invoke-GitRemoteRemove' -Scope Global -Force

function Invoke-GitRemoteSeturl
{
    git remote set-url $args
}
New-Alias -Name 'grset' -Value 'Invoke-GitRemoteSeturl' -Scope Global -Force

function Invoke-SetLocationGitRevParseShowtoplevel
{
    Set-Location "$(git rev-parse --show-toplevel)" $args
    SetLocationGitRevParseShowtoplevel
}
New-Alias -Name 'grt' -Value 'Invoke-SetLocationGitRevParseShowtoplevel' -Scope Global -Force
New-Alias -Name 'cdgr' -Value 'Invoke-SetLocationGitRevParseShowtoplevel' -Scope Global -Force

function Invoke-GitBisect
{
    git bisect $args
}
New-Alias -Name 'gbs' -Value 'Invoke-GitBisect' -Scope Global -Force

function Invoke-GitBisectBad
{
    git bisect bad $args
}
New-Alias -Name 'gbsb' -Value 'Invoke-GitBisectBad' -Scope Global -Force

function Invoke-GitBisectGood
{
    git bisect good $args
}
New-Alias -Name 'gbsg' -Value 'Invoke-GitBisectGood' -Scope Global -Force

function Invoke-GitBisectReset
{
    git bisect reset $args
}
New-Alias -Name 'gbsr' -Value 'Invoke-GitBisectReset' -Scope Global -Force

function Invoke-GitBisectStart
{
    git bisect start $args
}
New-Alias -Name 'gbss' -Value 'Invoke-GitBisectStart' -Scope Global -Force

function Invoke-GetGitCurrentBranch
{
    Get-GitCurrentBranch $args
}
New-Alias -Name 'gbsc' -Value 'Invoke-GetGitCurrentBranch' -Scope Global -Force

function Invoke-GitLsfiles
{
    git ls-files $args
}
New-Alias -Name 'gls' -Value 'Invoke-GitLsfiles' -Scope Global -Force

function Invoke-GitLsFilesGitRevparseShowtoplevel
{
    git ls-files $(git rev-parse --show-toplevel) $args
}
New-Alias -Name 'glsa' -Value 'Invoke-GitLsFilesGitRevparseShowtoplevel' -Scope Global -Force

function Invoke-GitConfigRemoteOriginFetchRefs
{
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" $args
}
New-Alias -Name 'grefs' -Value 'Invoke-GitConfigRemoteOriginFetchRefs' -Scope Global -Force

function Invoke-GitDeltaSideBySideTrueDiff
{
    git -c delta.side-by-side=true diff $args
}
New-Alias -Name 'gdh' -Value 'Invoke-GitDeltaSideBySideTrueDiff' -Scope Global -Force


# CLI tools aliases
if (Get-Command nvim -ErrorAction SilentlyContinue)
{
    New-Alias -Name 'v' -Value 'nvim' -Scope Global -Force
}
if (Get-Command lazygit -ErrorAction SilentlyContinue)
{
    New-Alias -Name 'lg' -Value 'lazygit' -Scope Global -Force
}

# Python Virtual Environment activation
function Enter-VirtualEnvironment
{
    param (
        [string]$venvName = ".venv"
    )

    # Create the virtual environment
    python -m venv $venvName

    # Activate the virtual environment
    $activateScript = Join-Path $venvName "Scripts/Activate.ps1"
    if (Test-Path $activateScript)
    {
        . $activateScript
    } else
    {
        Write-Error "Failed to find Activate.ps1 script in the virtual environment."
    }
}
Set-Alias -Name activate -Value Enter-VirtualEnvironment

function Invoke-GitPullRebaseVerbose
{
    git pull --rebase --verbose $args
}
New-Alias -Name 'gupv' -Value 'Invoke-GitPullRebaseVerbose' -Scope Global -Force
