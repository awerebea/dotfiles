param (
    [switch]$v = $false,
    [switch]$vv = $false,
    [switch]$vvv = $false,
    [switch]$silent = $false,

    [switch]$removeOriginal = $false,

    [string]$sourceDirectory,
    [string]$backupPrefix
)

function Set-GlobalVariables
{
    if ($vvv)
    {
        $vv = $true
    }
    if ($vv)
    {
        $v = $true
    }
    # If $sourceDirectory is not provided, prompt the user for input
    if (-not $sourceDirectory)
    {
        $sourceDirectory = Read-Host "Enter the source directory path"
        $sourceDirectory = $sourceDirectory.Trim('"', "'")  # Remove surrounding quotes
    }
    # If $backupPrefix is not provided, prompt the user for input
    if (-not $backupPrefix)
    {
        $backupPrefix = Read-Host "Enter the prefix for the backup directory path"
        $backupPrefix = $backupPrefix.Trim('"', "'")  # Remove surrounding quotes
    }


    # Use input arguments as global variables
    $script:v = $v
    $script:vv = $vv
    $script:vvv = $vvv
    $script:silent = $silent
    $script:sourceDirectory = $sourceDirectory
    $script:backupPrefix = $backupPrefix
}

function Get-Confirmation
{
    param (
        [string]$message = "Do you want to proceed?"
    )

    # Ask the user for confirmation on the same line
    [Console]::Write("$message (Yes/[N]o): ")

    # Wait for a key press
    while (-not [Console]::KeyAvailable)
    {
        Start-Sleep -Milliseconds 100
    }

    # Read the key
    $key = [Console]::ReadKey()

    # Add a new line after user input, TODO: figure out why Write-Output "" doesn't work
    Write-Host ""

    # Check user input
    if (-not($key.Key -eq 'Y' -or $key.Key -eq 'y'))
    {
        # Write-Output "Declined."
        return $false
    }
    return $true
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

function Write-HashTableRecursively
{
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable]$hashTable,
        [string]$indent = ""
    )

    # Calculate the maximum key length
    $maxKeyLength = ($hashTable.Keys | Measure-Object { $_.Length } -Maximum).Maximum

    foreach ($key in $hashTable.Keys)
    {
        $value = $hashTable[$key]
        # If the value is a hashtable, recursively print it with increased indentation
        if ($value -is [System.Collections.Hashtable])
        {
            # Print the current key and value
            Write-Output "$indent$key`:"
            Write-HashTableRecursively -hashTable $value -indent "$indent  "
        } else
        {
            # Print the current key and value
            Write-Output ("$indent{0,-$maxKeyLength} : $value" -f $key)
        }
    }
}

function Build-DataTable ($fileMapping)
{
    # *.mkv is excluded
    $videoExtensions = @(
        '.3g2', '.3gp2', '.3gp', '.3gpp', '.amr', '.amv', '.asf', '.avi',
        '.bik', '.divx', '.dpg', '.dvr-ms', '.evo', '.ifo', '.flv', '.k3g',
        '.m1v', '.m2v', '.m2t', '.m2ts', '.m4v', '.m4p', '.m4b', '.mov',
        '.mp4', '.mpeg', '.mpg', '.mpe', '.mpv2', '.mp2v', '.mts', '.mxf',
        '.nsr', '.nsv', '.ogm', '.ogv', '.rm', '.ram', '.rmvb', '.rpm',
        '.rv', '.qt', '.skm', '.swf', '.ts', '.tp', '.tpr', '.trp',
        '.vob', '.wm', '.wmp', '.wmv'
    )
    # Get converted files
    $convertedFiles = Get-ChildItem -Path $sourceDirectory -Recurse -Include '*.mkv'
    # Iterate through found converted files
    foreach ($convertedFile in $convertedFiles)
    {
        # Get the directory and base name of the current converted file
        $directory = $convertedFile.DirectoryName
        $baseName = $convertedFile.BaseName
        # Initialize a nested hashtable for each converted file
        $nestedMapping = @{}
        # Iterate through each video extension
        foreach ($videoExtension in $videoExtensions)
        {
            # Construct the path for the file with the current video extension
            $videoFilePath = Join-Path -Path $directory -ChildPath "$baseName$videoExtension"
            # Check if the file with the current video extension exists
            if (Test-Path $videoFilePath)
            {
                # Add the mapping to the nested hashtable
                $nestedMapping["origFile"] = $videoFilePath
                # Add the nested hashtable to the main mapping with converted file path as key
                $fileMapping[$convertedFile.FullName] = $nestedMapping
                # Exit the inner loop as we found a match
                break
            }
        }
    }

    # DEBUG: print
    if ($v)
    {
        Write-Output "Number of files found for processing: $($fileMapping.Count)"
    }
    if ($vv)
    {
        foreach ($convertedFile in $fileMapping.Keys)
        {
            Write-HashTableRecursively -hashTable $fileMapping
            Write-Output ""
        }
        Write-Output ""
    }
}

function Expand-DataTableWithCompressionEfficiency ($fileMapping)
{
    foreach ($convertedFile in $fileMapping.Keys)
    {
        $convertedFileSizeInBytes = (Get-Item "$convertedFile").length
        $fileMapping[$convertedFile]["convertedFileSizeInBytes"] = $convertedFileSizeInBytes

        $convertedFileSize = "$(Format-FileSize -sizeInBytes $convertedFileSizeInBytes)"
        $fileMapping[$convertedFile]["convertedFileSize"] = $convertedFileSize

        $origFile = $($fileMapping[$convertedFile]["origFile"])

        $origFileSizeInBytes = (Get-Item "$origFile").length
        $fileMapping[$convertedFile]["origFileSizeInBytes"] = $origFileSizeInBytes

        $origFileSize = "$(Format-FileSize -sizeInBytes $origFileSizeInBytes)"
        $fileMapping[$convertedFile]["origFileSize"] = $origFileSize

        # Calculate compression efficiency
        $compressionEfficiency = (1 - ($convertedFileSizeInBytes / $origFileSizeInBytes)) * 100
        $fileMapping[$convertedFile]["compressionEfficiency"] = $compressionEfficiency

        $compressionEfficiencyFormatted = $("{0:N2}%" -f $compressionEfficiency)
        $fileMapping[$convertedFile]["compressionEfficiencyFormatted"] = $compressionEfficiencyFormatted

        # DEBUG: print
        if ($vvv)
        {
            Write-HashTableRecursively -hashTable $fileMapping
            Write-Output ""
        }
    }
}

function Expand-DataTableWithBackupLocation ($fileMapping)
{
    foreach ($convertedFile in $fileMapping.Keys)
    {
        $compressionEfficiency = $fileMapping[$convertedFile]["compressionEfficiency"]
        if ($compressionEfficiency -lt 0)
        {
            # Splitting the path into drive and the rest of the path
            $drive = [System.IO.Path]::GetPathRoot($convertedFile)
            $restOfPath = $convertedFile.Substring($drive.Length)

            # Concatenating the modified path
            $backupFile = Join-Path -Path $drive -ChildPath ("$backupPrefix\$restOfPath")
            $fileMapping[$convertedFile]["backupFile"] = $backupFile

            # DEBUG: print
            if ($vvv)
            {
                Write-HashTableRecursively -hashTable $fileMapping
                Write-Output ""
            }
        }
    }
}

function Request-OverwritePermission
{
    param (
        [string]$destinationPath,
        [string]$message = "The file already exists at the destination. Overwrite?"
    )

    if (-not (Test-Path $destinationPath) -or (
            Get-Confirmation -message "$destinationPath`n$message"
        ))
    {
        return $true
    }

    return $false
}

function Move-FilesToBackupLocation ($fileMapping)
{
    $filesToBackup = New-Object System.Collections.ArrayList
    foreach ($convertedFile in $fileMapping.Keys | Sort-Object)
    {
        if ($fileMapping[$convertedFile].ContainsKey("backupFile"))
        {
            $null = $filesToBackup.Add($convertedFile)
        }
    }

    Write-Confirmation -filesToBackup $filesToBackup -fileMapping $fileMapping

    foreach ($convertedFile in $filesToBackup)
    {
        $backupFile = $fileMapping[$convertedFile]["backupFile"]

        # Creating the directory structure if it doesn't exist
        $null = New-Item -ItemType Directory -Force -Path (Split-Path "$backupFile")

        # Validate overwriting if the backup already exists
        if (-not (Request-OverwritePermission -destinationPath $backupFile))
        {
            Write-Output "Backup skipped."
            continue
        }

        # Move the file from the original path to the backup path with confirmation
        Move-Item -Path "$convertedFile" -Destination "$backupFile" -Force

        # Move the sidecar file if exists
        $sidecarFileExists = $false
        if (Test-Path "$convertedFile.xmp")
        {
            $sidecarFileExists = $true
            Move-Item -Path "$convertedFile.xmp" -Destination "$backupFile.xmp" -Force
        }

        if (-not $silent)
        {
            Write-Output "$convertedFile => $backupFile"
            if ($sidecarFileExists)
            {
                Write-Output "Sidecar file moved to $backupFile.xmp"
            }
            Write-Output ""
        }
    }
}

function Write-Confirmation ($filesToBackup, $fileMapping)
{
    if ($filesToBackup.Count -gt 0)
    {
        Write-Output "Number of files to move to backup: $($filesToBackup.Count)`n"
        if (-not $silent)
        {
            foreach ($convertedFile in $filesToBackup)
            {
                Write-Output "$convertedFile : $(
                $fileMapping[$convertedFile]["origFileSize"]
            ) => $(
                $fileMapping[$convertedFile]["convertedFileSize"]
            ), Compression: $(
                $fileMapping[$convertedFile]["compressionEfficiencyFormatted"]
            )"
            }
            Write-Output ""
        }
        if (-not (Get-Confirmation))
        {
            Write-Output "Script execution aborted."
            exit
        }
    } else
    {
        Write-Output "No files to backup."
    }
}

function Remove-InefficientOrigFiles ($fileMapping)
{
    $filesToRemove = New-Object System.Collections.ArrayList
    foreach ($convertedFile in $fileMapping.Keys | Sort-Object)
    {
        $compressionEfficiency = $fileMapping[$convertedFile]["compressionEfficiency"]
        if ($compressionEfficiency -gt 0)
        {
            $null = $filesToRemove.Add($convertedFile)
        }
    }

    if ($filesToRemove.Count -gt 0)
    {
        Write-Output "Number of files to remove: $($filesToRemove.Count)`n"
        if (-not $silent)
        {
            foreach ($convertedFile in $filesToRemove)
            {
                Write-Output "$($fileMapping[$convertedFile]["origFile"]) : $(
                $fileMapping[$convertedFile]["origFileSize"]
            ) => $(
                $fileMapping[$convertedFile]["convertedFileSize"]
            ), Compression: $(
                $fileMapping[$convertedFile]["compressionEfficiencyFormatted"]
            )"
            }
            Write-Output ""
        }
        if (-not (Get-Confirmation))
        {
            Write-Output "Script execution aborted."
            exit
        }
    } else
    {
        Write-Output "No files to remove."
    }

    foreach ($convertedFile in $filesToRemove)
    {
        $origFile = $fileMapping[$convertedFile]["origFile"]

        # Move the file from the original path to the backup path with confirmation
        Remove-Item -Path "$origFile" -Force

        # Move the sidecar file if exists
        $sidecarFileExists = $false
        if (Test-Path "$origFile.xmp")
        {
            $sidecarFileExists = $true
            Remove-Item -Path "$origFile.xmp" -Force
        }

        if (-not $silent)
        {
            Write-Output "$origFile removed"
            if ($sidecarFileExists)
            {
                Write-Output "Sidecar file removed"
            }
            Write-Output ""
        }
    }
}

# Start program here.
function Start-Program
{
    Set-GlobalVariables

    $fileMapping = @{}

    Build-DataTable -fileMapping $fileMapping

    Expand-DataTableWithCompressionEfficiency -fileMapping $fileMapping

    Expand-DataTableWithBackupLocation -fileMapping $fileMapping

    Move-FilesToBackupLocation -fileMapping $fileMapping

    if ($removeOriginal)
    {
        Remove-InefficientOrigFiles -fileMapping $fileMapping
    }
}

Start-Program
