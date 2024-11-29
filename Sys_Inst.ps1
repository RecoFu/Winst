### Winstal.ps1: Automated Script for System Setup and Optimization

```powershell
# ---------------------------
# Windows System Setup Script
# Version: 2.0
# Author: [Your Name]
# Description: Automates the setup, backup, and optimization of Windows systems.
# ---------------------------

# ---------------------------
# Section 1: List Hardware, Drivers, and Check for Backup Location
# ---------------------------
Write-Host "Listing system hardware and drivers..."
dxdiag /t "$env:TEMP\dxdiag_output.txt"
Write-Host "Hardware details saved to dxdiag_output.txt."

Write-Host "Getting installed drivers..."
Get-WmiObject Win32_PnPSignedDriver | Select-Object DeviceName, Manufacturer, DriverVersion, DriverDate | Export-Csv "$env:TEMP\drivers_list.csv" -NoTypeInformation
Write-Host "Driver list saved to drivers_list.csv."

Write-Host "Checking for backup location..."
if (Test-Path D:\) {
    Write-Host "D: drive available for backup."
} elseif ((Get-PSDrive -Name "OneDrive" -ErrorAction SilentlyContinue)) {
    Write-Host "OneDrive available for backup."
} else {
    Write-Host "No suitable backup location found. Please connect a drive or ensure OneDrive is configured."
}

# ---------------------------
# Section 2: Backup Drivers and Applications
# ---------------------------
Write-Host "Backing up drivers and applications..."
$BackupPath = "D:\Backup"
if (-Not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath
}

# Backup Drivers
Export-WindowsDriver -Online -Destination "$BackupPath\Drivers"
Write-Host "Drivers backed up to $BackupPath\Drivers."

# Backup Installed Applications
Get-StartApps | Export-Csv "$BackupPath\installed_apps.csv" -NoTypeInformation
Write-Host "Installed applications list saved to $BackupPath\installed_apps.csv."

# ---------------------------
# Section 3: Reinstall System and Drivers
# ---------------------------
Write-Host "Starting system reinstallation..."
# Reinstallation logic to be executed manually or added here if automated setup files are available.

Write-Host "Reinstalling drivers..."
$DriverBackupPath = "$BackupPath\Drivers"
if (Test-Path $DriverBackupPath) {
    pnputil.exe /add-driver "$DriverBackupPath\*.inf" /subdirs /install
    Write-Host "Drivers reinstalled from backup."
} else {
    Write-Host "No driver backup found at $DriverBackupPath. Skipping driver installation."
}

# ---------------------------
# Section 4: Optimize System Settings
# ---------------------------
Set-ExecutionPolicy RemoteSigned -Force
Set-WinSystemLocale zh-TW
Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=0; MaximumSize=0}
bcdedit /set hypervisorlaunchtype auto
powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Powercfg /h /type full
Powercfg /h on
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -n
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -n
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -n
Write-Host "System optimization settings applied."

# ---------------------------
# Section 5: Prompt for Application Installation
# ---------------------------
if ((Read-Host "Do you want to install Microsoft Office? (y/n)") -eq "y") {
    Write-Host "Installing Microsoft Office..."
    Start-Process -FilePath "E:\OFFICEPROPLUS2021\setup.exe" -ArgumentList "/configure Z:\Configuration.xml" -Wait
}

if ((Read-Host "Do you want to install additional applications? (y/n)") -eq "y") {
    Write-Host "Installing additional applications..."
    # Install Apps using Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
        [System.Net.ServicePointManager]::SecurityProtocol = \
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    choco install 7zip GoogleChrome keepass Everything fastcopy vscode vlc line picpick.portable choco-cleaner -y --ignore-checksums
    choco install choco-upgrade-all-at --params "'/WEEKLY:yes /DAY:SUN /TIME:05:00'"
}

Write-Host "System setup and optimization completed. Restart your system to apply all changes."
Restart-Computer
