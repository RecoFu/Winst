# WinUpd.ps1 (Daily work to keep computer clean and safe)

# Get some computer information.  Like its name and what Windows it uses.
$model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$winver = (Get-ComputerInfo).WindowsVersion
$installDate = (Get-WmiObject -Class Win32_OperatingSystem).InstallDate
$installDateFormatted = [System.Management.ManagementDateTimeConverter]::ToDateTime($installDate).ToString("yyyyMMdd")
$defaultBackupLocation = "$model_$winver_$installDateFormatted"

# Ask where to save the backup files.
$backupChoice = Read-Host "Choose where to save backup: 1. Automatic place, 2. I choose."
# Check the answer.
switch ($backupChoice) {
  "1" { # If the answer is 1...
    $backupLocation = $defaultBackupLocation # ...use the automatic place.
  }
  "2" { # If the answer is 2...
    $backupLocation = Read-Host "Tell me where to save backup:" # ...ask the user where to save.
  }
  default { # If the answer is wrong...
    Write-Warning "Wrong answer. Using automatic place." # ...use the automatic place.
    $backupLocation = $defaultBackupLocation
  }
}

# Make sure the place to save backup exists.  If not, make it.
if (!(Test-Path -Path $backupLocation)) {
  New-Item -ItemType Directory -Force -Path $backupLocation | Out-Null
}

# Set the place to save the backup log.
$backupLog = "$backupLocation\backup_log.txt"
# Set files to backup.
$backupFiles = @("%USERPROFILE%\Documents", "%USERPROFILE%\Pictures")

# This part does the backup work.
try { # Try to do these things...
    # Backup important files.  One by one.
    foreach ($path in $backupFiles) {
        Backup-Files -SourcePath $path -DestinationPath $backupLocation -LogPath $backupLog
    }

    # Clean up old files.
    Clean-TempFiles

    # Check for new Windows updates.
    Write-Host "Checking for Windows updates..."
    powershell Get-WindowsUpdate -AcceptAll -Install

    Write-Host "Daily work is done!" #  All is good!
}
catch { # But if something goes wrong...
    Write-Error "Daily work failed: $($_.Exception.Message)" # ...tell me what went wrong.
}


# This is a helper. It does the actual backup.
function Backup-Files {
    param(
        [string]$SourcePath, # Where to get the files.
        [string]$DestinationPath, # Where to save the files.
        [string]$LogPath # Where to write what happened.
    )
    try { # Try to do this...
        Write-Host "Saving files from '$SourcePath' to '$DestinationPath'..." # Tell me what's happening.
        robocopy $SourcePath $DestinationPath /e /copyall /r:0 /w:0 /log:$LogPath # Do the saving.
        Write-Host "Files saved!" # All good!
    }
    catch { # But if something goes wrong...
        Write-Error "Saving files failed: $($_.Exception.Message)" # ...tell me what went wrong.
    }
}

# This is another helper. It cleans up old computer files.
function Clean-TempFiles {
    try { # Try to do this...
        Write-Host "Cleaning old computer files..." # Tell me what's happening.
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue # Clean up!
        Remove-Item -Path "$env:TMP\*" -Recurse -Force -ErrorAction SilentlyContinue # Clean up more!
        Write-Host "Old computer files cleaned!" # All good!
    }
    catch { # But if something goes wrong...
        Write-Warning "Cleaning up failed: $($_.Exception.Message)" # ...tell me what went wrong.
    }
}
