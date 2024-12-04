<#
.SYNOPSIS
Automated Windows 11 Upgrade, Software Installation, and System Optimization Script

.DESCRIPTION
This script provides a fully automated process for upgrading Windows 11, installing software, and customizing system settings.
Supports both automatic and advanced modes for efficient and flexible system deployment.  Includes robust error handling and improved logging.

.NOTES
Version: 2.1
Author: AI Assistant
Date: 2024-12-07
#>

# Global Settings
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$LogFilePath = "C:\WindowsUpgrade.log"  # Centralized log file
$ChocolateyInstallPath = "$env:LOCALAPPDATA\Programs\chocolatey" #Path to check if Chocolatey is installed

# Create Log Directory if it doesn't exist
if (!(Test-Path -Path (Split-Path $LogFilePath -Parent))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $LogFilePath -Parent)
}

# Logging Function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'Info'
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Level] [$Timestamp] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFilePath -Value $LogMessage
}


# --- Modules ---

# 1. System Upgrade Module
function Upgrade-Windows {
    param(
        [string]$IsoPath,
        [string]$Edition = "Pro",
        [switch]$AutoMode
    )
    try {
        Write-Log "Starting Windows Upgrade..."
        # Validate ISO Path
        if (!(Test-Path $IsoPath)) { throw "Error: ISO file not found at '$IsoPath'. Please provide a valid path." }
        $mountResult = Mount-DiskImage -ImagePath $IsoPath -PassThru
        if (-not $mountResult) { throw "Error: Failed to mount ISO image. Please ensure the ISO is valid and accessible." }
        $driveLetter = ($mountResult | Get-Volume).DriveLetter
        $args = "/auto upgrade /dynamicupdate disable /noreboot"
        if ($AutoMode) { $args += "/quiet" }
        Start-Process -FilePath "$($driveLetter):\setup.exe" -ArgumentList $args -Wait
        Write-Log "Windows Upgrade Successful!"
    }
    catch { Write-Log "Windows Upgrade Failed: $_" -Level "Error" }
    finally {
        try { Dismount-DiskImage -ImagePath $IsoPath }
        catch { Write-Log "Error dismounting ISO: $_" -Level "Warning" }
    }
}


# 2. Software Installation Module (uses Winget for consistency)
function Install-Software {
    param(
        [string[]]$Packages
    )
    foreach ($package in $Packages) {
        try {
            Write-Log "Installing $package..."
            winget install "$package" --silent --accept-source-agreements
        }
        catch { Write-Log "Failed to install $package: $_" -Level "Warning" }
    }
}

# 3. System Optimization Module
function Optimize-System {
    try {
        Write-Log "Optimizing System Settings..."
        Set-ExecutionPolicy RemoteSigned -Force
        Set-WinSystemLocale zh-TW
        Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{Name = 'C:\pagefile.sys'; InitialSize = 0; MaximumSize = 0}
        bcdedit /set hypervisorlaunchtype auto
        powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        Powercfg /h /type full
        Powercfg /h on
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        Write-Log "System Optimization Complete!"
    }
    catch { Write-Log "System Optimization Failed: $_" -Level "Error" }
}

# 4. System Update and Cleanup Module
function Update-And-Cleanup {
    try {
        Write-Log "Updating and Cleaning System..."
        # Check if PSWindowsUpdate is installed; install if necessary.
        if (!(Get-Module -Name PSWindowsUpdate -ErrorAction SilentlyContinue)) {
          Write-Log "Installing PSWindowsUpdate module..."
          try {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
          }
          catch {
            Write-Log "PSWindowsUpdate installation failed: $_" -Level "Error"
            return
          }
        }
        Get-WindowsUpdate -AcceptAll -Install
        winget upgrade --all --silent
        dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase
        Write-Log "System Update and Cleanup Complete!"
    }
    catch { Write-Log "System Update or Cleanup Failed: $_" -Level "Error" }
}

# 5. Chocolatey Installation and Management (with error handling)
function Manage-Chocolatey {
  try {
    if (!(Test-Path $ChocolateyInstallPath)) {
      Write-Log "Installing Chocolatey..."
      Set-ExecutionPolicy Bypass -Scope Process -Force;
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
      iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
      Write-Log "Chocolatey installation successful."
    } else {
      Write-Log "Chocolatey already installed."
    }
    #Upgrade Chocolatey (optional)
    choco upgrade chocolatey -y
    # Perform Chocolatey cleanup (optional - uncomment if needed)
    #powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\tools\BCURRAN3\choco-cleaner.ps1' %*" # Replace with your choco-cleaner path if used.
  }
  catch {
    Write-Log "Chocolatey installation or management failed: $_" -Level "Error"
  }
}


# --- Main Execution ---
function Main {
    # Check for Winget and install if necessary
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
      Write-Log "Winget not found, attempting to install..."
      try {
          Install-PackageProvider -Name NuGet -Force | Out-Null
          Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
          Repair-WinGetPackageManager
      } catch {
          Write-Log "Winget installation failed: $_" -Level "Error"
          return
      }
    }

    Manage-Chocolatey #Install or manage Chocolatey before proceeding

    # Interactive Menu
    Write-Host "Windows 11 Upgrade and Optimization Tool v2.1"
    Write-Host "1. Automatic Mode"
    Write-Host "2. Advanced Mode"
    $choice = Read-Host "Select Mode (1/2):"

    switch ($choice) {
        "1" {
            $isoPath = Read-Host "Enter path to Windows 11 ISO:"
            #Validate ISO Path input (simple check)
            if (-not (Test-Path $isoPath)) {
              Write-Log "Invalid ISO path. Exiting." -Level "Error"
              return
            }

            Upgrade-Windows -IsoPath $isoPath -AutoMode
            Install-Software -Packages @("7zip.7zip", "Google.Chrome", "VideoLAN.VLC", "Microsoft.WindowsTerminal")
            Optimize-System
            Update-And-Cleanup
        }
        "2" {
            # Advanced Mode
            do {
                Write-Host ""
                Write-Host "Advanced Mode Menu:"
                Write-Host "1. Upgrade Windows"
                Write-Host "2. Install Software"
                Write-Host "3. Optimize System"
                Write-Host "4. Update and Cleanup"
                Write-Host "5. Manage Chocolatey" # Added option
                Write-Host "6. Exit"
                $moduleChoice = Read-Host "Select a module (1-6):"

                switch ($moduleChoice) {
                    "1" {
                        $isoPath = Read-Host "Enter path to Windows 11 ISO:"
                        if (-not (Test-Path $isoPath)) {
                          Write-Log "Invalid ISO path. Skipping Upgrade." -Level "Warning"
                          continue
                        }
                        Upgrade-Windows -IsoPath $isoPath
                    }
                    "2" { Install-Software -Packages @("7zip.7zip", "Google.Chrome", "VideoLAN.VLC", "Microsoft.WindowsTerminal") }
                    "3" { Optimize-System }
                    "4" { Update-And-Cleanup }
                    "5" { Manage-Chocolatey }
                    "6" { break }
                    default { Write-Log "Invalid choice. Please try again." -Level "Warning" }
                }
            } while ($moduleChoice -ne "6")
        }
        default { Write-Log "Invalid choice. Exiting." -Level "Error" }
    }

    Write-Log "Script Execution Complete!"
}


# Run Main Function
Main
