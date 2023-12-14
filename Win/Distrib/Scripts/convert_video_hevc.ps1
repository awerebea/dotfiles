param (
    [string]$preset = 'slow',
    [switch]$v = $false,
    [switch]$vv = $false,

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

# Filter out already converted files
$filteredFiles = $videoFiles | Where-Object {
    $outputPath = Join-Path "$($_.Directory.FullName)" "$($_.BaseName).mkv"
    -not (Test-Path "$outputPath")
}

# Print the number of found paths
if ($v -or $vv)
{
    Write-Host "Number of files found for processing: $($filteredFiles.Count)"
}

function Format-FileSize
{
    param (
        [double]$sizeInBytes
    )

    $suffixes = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0

    while ($sizeInBytes -ge 1KB -and $index -lt $suffixes.Count)
    {
        $sizeInBytes /= 1KB
        $index++
    }

    "{0:N2} {1}" -f $sizeInBytes, $suffixes[$index]
}

# Iterate through each path and print
if ($vv)
{
    foreach ($file in $filteredFiles)
    {
        Write-Host "$($file.FullName)"
    }
    Write-Host ""
}

Write-Host "Used preset: $preset`n"

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

foreach ($file in $filteredFiles)
{
    $outputPath = Join-Path "$($file.Directory.FullName)" "$($file.BaseName).mkv"

    $fileSizeInBytes = (Get-Item "$($file.FullName)").length
    $fileSize = "$(Format-FileSize -sizeInBytes $fileSizeInBytes)"

    Write-Host "Processing $($file.FullName) ($fileSize)"

    $timeStampStart = "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')"
    "$timeStampStart [STARTED]  : $($file.FullName) ($fileSize)" |
        Out-File -Append -FilePath "$logFilePath"

    & ffmpeg -y -hide_banner `
        -i "$($file.FullName)" `
        -map 0:v -map 0:a? -map 0:s? -map_metadata 0 `
        -c:v libx265 -preset "$preset" -pix_fmt yuv444p `
        -c:a copy -c:s copy `
        "$outputPath"

    $exitCode = $LASTEXITCODE

    $timeStampFinish = "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')"

    # Calculate time elapsed
    $timeElapsed = (Get-Date $timeStampFinish) - (Get-Date $timeStampStart)

    # Format the time elapsed
    $timeElapsedFormatted = '{0:HH:mm:ss}' -f $timeElapsed

    if ($exitCode -eq 0)
    {
        $outputFileSizeInBytes = (Get-Item "$outputPath").length
        $outputFileSize = "$(Format-FileSize -sizeInBytes $outputFileSizeInBytes)"

        # Calculate compression efficiency
        $compressionEfficiency = (1 - ($outputFileSizeInBytes / $fileSizeInBytes)) * 100
        $compressionEfficiencyFormatted = $("{0:N2}%" -f $compressionEfficiency)

        "$timeStampFinish [COMPLETED]: $outputPath ($outputFileSize), " +
        "Compression Efficiency: $compressionEfficiencyFormatted, " +
        "Time Elapsed: $timeElapsedFormatted" |
            Out-File -Append -FilePath "$logFilePath"

        Write-Host "Completed: Original Size: $fileSize," `
            "Converted Size: $outputFileSize," `
            "Compression Efficiency: $compressionEfficiencyFormatted," `
            "Time Elapsed: $timeElapsedFormatted"
    } else
    {
        "$timeStampFinish [FAILED]   : $($file.FullName) " +
        "Time Elapsed: $timeElapsedFormatted" |
            Out-File -Append -FilePath "$logFilePath"
    }
    Write-Host ""
}
