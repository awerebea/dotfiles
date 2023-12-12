param (
    [string]$sourceDirectory
)

# If $sourceDirectory is not provided, prompt the user for input
if (-not $sourceDirectory)
{
    $sourceDirectory = Read-Host "Enter the source directory path"
    $sourceDirectory = $sourceDirectory.Trim('"')  # Remove surrounding double quotes
}

# Get video files
$sidecarFiles = Get-ChildItem -Path $sourceDirectory -Recurse -Include '*.xmp' -Exclude '*.mkv.xmp'

foreach ($file in $sidecarFiles)
{
    $outputFile = "$($file -replace '\.[^.]*\.[^.]*$').mkv.xmp"

    if (Test-Path "$outputFile")
    {
        & exiftool -overwrite_original -tagsFromFile "$file" "$outputFile"

        if ($LASTEXITCODE -eq 0)
        {
            $originalVideoFile = "$(Join-Path $($file.Directory.FullName) $($file.BaseName))"

            Write-Host "Remove original video file   : $originalVideoFile"
            Write-Host "Remove original sidecar file : $file"

            Remove-Item -Path "$originalVideoFile" -Force
            Remove-Item -Path "$($file.FullName)" -Force
        } else
        {
            Write-Host "Metadata transfer failed for $($file.FullName)"
        }
    }
    Write-Host ""
}
