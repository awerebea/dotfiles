if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression (
        (New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1')
    )
} else
{
    oh-my-posh init pwsh --config "$HOME/.oh-my-posh.yaml" | Invoke-Expression
}

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

$env:FZF_DEFAULT_COMMAND = "fd --strip-cwd-prefix --follow --hidden --exclude .git --exclude .venv --type file --type symlink"
$env:FZF_ALT_C_COMMAND = "fd --strip-cwd-prefix --follow --hidden --exclude .git --exclude .venv --type directory"
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
Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineKeyHandler -Chord "Alt+k" -Function ForwardWord

Set-PSReadLineKeyHandler -Chord "Alt+l" -Function ClearScreen

$apiKeyFile = "$env:USERPROFILE\.config\.openai_api_key"
if (Test-Path $apiKeyFile)
{
    $env:OPENAI_API_KEY = Get-Content $apiKeyFile | ForEach-Object { $_.Trim() }
}

. "$HOME\.shared.ps1"
