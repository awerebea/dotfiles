param (
    [string]$preset = 'slow',

    [string]$sourceDirectory
)

# If $sourceDirectory is not provided, prompt the user for input
if (-not $sourceDirectory)
{
    $sourceDirectory = Read-Host "Enter the source directory path"
    $sourceDirectory = $sourceDirectory.Trim('"')  # Remove surrounding double quotes
}

# *.mkv is excluded
$videoExtensions = @(
    '*.3g2', '*.3gp2', '*.3gp', '*.3gpp', '*.amr', '*.amv', '*.asf', '*.avi',
    '*.bik', '*.divx', '*.dpg', '*.dvr-ms', '*.evo', '*.ifo', '*.flv', '*.k3g',
    '*.m1v', '*.m2v', '*.m2t', '*.m2ts', '*.m4v', '*.m4p', '*.m4b', '*.mov',
    '*.mp4', '*.mpeg', '*.mpg', '*.mpe', '*.mpv2', '*.mp2v', '*.mts', '*.mxf',
    '*.nsr', '*.nsv', '*.ogm', '*.ogv', '*.rm', '*.ram', '*.rmvb', '*.rpm',
    '*.rv', '*.qt', '*.skm', '*.swf', '*.ts', '*.tp', '*.tpr', '*.trp',
    '*.vob', '*.wm', '*.wmp', '*.wmv'
)

# Get video files
$videoFiles = Get-ChildItem -Path $sourceDirectory -Recurse -Include $videoExtensions

# Print the number of found paths
Write-Host "Number of files found for processing: $($videoFiles.Count)"

# Iterate through each path and print
foreach ($file in $videoFiles)
{
    Write-Host "$($file.FullName)"
}

Write-Host ""
Write-Host "Used preset: $preset"
Write-Host ""

# Ask the user for confirmation on the same line
[Console]::Write("Do you want to proceed? (Yes/[N]o): ")

# Wait for a key press
while (-not [Console]::KeyAvailable)
{
    Start-Sleep -Milliseconds 100
}

# Read the key
$key = [Console]::ReadKey()

# Add a new line after user input
Write-Host ""

# Check user input
if (-not($key.Key -eq 'Y' -or $key.Key -eq 'y'))
{
    Write-Host "Script execution aborted."
    exit
}

$logFilePath = Join-Path (Get-Location) "convert.log"

if (-not (Test-Path "$logFilePath"))
{
    New-Item -ItemType File -Path "$logFilePath" | Out-Null
}

foreach ($file in $videoFiles)
{
    $outputPath = Join-Path "$($file.Directory.FullName)" "$($file.BaseName).mkv"

    Write-Host "Processing $($file.FullName)"

    & ffmpeg -y -hide_banner `
        -i "$($file.FullName)" `
        -map 0:v -map 0:a? -map 0:s? -map_metadata 0 `
        -c:v libx265 -preset "$preset" -pix_fmt yuv444p `
        -c:a copy -c:s copy `
        "$outputPath"

    $exitCode = $LASTEXITCODE

    $timeStamp = "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')"
    if ($exitCode -eq 0)
    {
        "$timeStamp [COMPLETE]: $($file.FullName)" | Out-File -Append -FilePath "$logFilePath"
    } else
    {
        "$timeStamp [FAILED]  : $($file.FullName)" | Out-File -Append -FilePath "$logFilePath"
    }
    Write-Host ""
}
