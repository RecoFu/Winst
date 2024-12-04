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
      }
    }

    # Parameters (Define these at the beginning for easy modification)
    $IsoPath = "D:\Win11_24H2.iso"  # Replace with your ISO path
    $UpgradeAutoMode = $true # Set to $false for interactive upgrade
    $OfficeConfigPath = "Z:\Configuration.xml" # Path to your Office Configuration file
    $OfficeSetupPath = "Z:\setup.exe" # Path to Office setup
    $PackagesToInstall = @(
        "7zip",
        "GoogleChrome",
        "KeePass",
        "Everything",
        "FastCopy",
        "Microsoft.VisualStudioCode",
        "vlc",
        "LINE",
        "PicPick",
        "Telegram.TelegramDesktop",
        "WinSCP",
        "Terraform"
    ) # Winget packages
     $ChocoPackagesToInstall = @(
        "mRemoteNG",
        "Sysinternals",
        "choco-cleaner"
    ) # Add your desired Chocolatey packages here

    # --- Execution Flow ---

    # 1. Upgrade to Windows 11 Pro (if necessary - uncomment and adapt if needed)
    # Write-Log "Upgrading to Windows 11 Pro..."
    # irm bit.ly/UpgradeWinPro | iex  # Consider a safer alternative like using a product key with changepk.exe
    # Restart-Computer

    # 2. Upgrade to Windows 11 24H2
    Write-Log "Starting Upgrade to Windows 11 24H2..."
    Upgrade-Windows -IsoPath $IsoPath -AutoMode:$UpgradeAutoMode

    # 3. Install Office (if needed)
    Write-Log "Installing Office..."
    Start-Process -FilePath $OfficeSetupPath -ArgumentList "/configure `"$OfficeConfigPath`"" -Wait

    # 4. Optimize System
    Write-Log "Optimizing System..."
    Optimize-System

    # 5. Manage Chocolatey (Install and then install packages)
    Manage-Chocolatey
    if (Test-Path $ChocolateyInstallPath) {
       Write-Log "Installing Choco packages..."
       choco install $ChocoPackagesToInstall -y --ignore-checksums
       Write-Log "Choco package installation successful."
    } else {
        Write-Log "Chocolatey not installed, skipping package installation." -Level "Warning"
    }

    # 6. Install Software (using Winget)
    Write-Log "Installing Software Packages via Winget..."
    Install-Software -Packages $PackagesToInstall

    # 7. Update and Cleanup
    Write-Log "Performing System Update and Cleanup..."
    Update-And-Cleanup

    Write-Log "Windows 11 Upgrade and System Setup Complete!"
    Write-Log "Restarting computer to finalize changes..."
    Restart-Computer -Force
}

# --- Entry Point ---
Main
