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

foreach ($file in $videoFiles)
{
    $outputPath = Join-Path $file.Directory.FullName "$($file.BaseName).mkv"
    $xmpFilePath = "$($file.FullName).xmp"

    Write-Host "Processing $($file.FullName)"

    & ffmpeg -y -hide_banner `
        -i "$($file.FullName)" `
        -map 0:v -map 0:a? -map 0:s? -map_metadata 0 `
        -c:v libx265 -preset "$preset" -pix_fmt yuv444p `
        -c:a copy -c:s copy `
        "$outputPath"

    if ($LASTEXITCODE -eq 0)
    {
        Write-Host "Conversion successful. Removing original file: $($file.FullName)"
        Remove-Item -Path $file.FullName -Force

        # Check if .xmp file exists and rename it
        if (Test-Path $xmpFilePath)
        {
            Write-Host "Renaming $xmpFilePath to $outputPath.xmp"
            Rename-Item -Path "$xmpFilePath" -NewName "$outputPath.xmp" -Force
        }
    } else
    {
        Write-Host "Conversion failed for $($file.FullName)"
    }
    Write-Host ""
}
