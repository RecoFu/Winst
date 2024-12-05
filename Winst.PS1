```powershell
# Winst.ps1 - Initial Setup after Windows 11 24H2 Installation

# Set execution policy for the current session
Set-ExecutionPolicy Bypass -Scope Process -Force

# Region: System Locale and Page File
# Set system locale to zh-tw
Set-WinSystemLocale zh-tw

# Disable page file (Optional - adjust as needed)
Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=0; MaximumSize=0}
# EndRegion

# Region: Hyper-V and WSL (Optional)
# Enable Hyper-V (if needed)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

# Enable Windows Subsystem for Linux (if needed)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

# Enable Containers feature (if needed)
Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart
# EndRegion

# Region: Package Managers Installation
# Install Chocolatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install winget
Install-PackageProvider -Name NuGet -Force -Confirm:$false
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Confirm:$false
Repair-WinGetPackageManager
# EndRegion

# Region: Essential Software Installation
# Install essential applications using Chocolatey
choco install 7zip googlechrome keepass everything fastcopy vscode vlc --yes -r:0 --ignore-checksums

# Install essential applications using winget
winget install Microsoft.WindowsTerminal --accept-source-agreements --silent
winget install --id Microsoft.PowerShell --accept-source-agreements --silent
#winget install JanDeDobbeleer.OhMyPosh --accept-source-agreements --silent  # Oh My Posh - install later, requires configuration

# Install other apps (List for manual installation - adapt as needed)
# Example: winget install <package-id> --accept-source-agreements --silent
# Example: choco install <package-name> --yes -r:0 --ignore-checksums
Write-Host "Following applications are recommended for manual installation:"
Write-Host "  * Line"
Write-Host "  * PicPick"
Write-Host "  * Obsidian"
Write-Host "  * etc."
# EndRegion

# Region: Driver Installation (Manual)
Write-Host "Driver installation needs to be performed manually.  Check manufacturer website."
# EndRegion

# Region: Office Installation (Manual - Interactive)
$installOffice = Read-Host -Prompt "Install Office? (y/n)"
if ($installOffice -eq "y") {
  $officePath = Read-Host -Prompt "Enter the path to the Office setup file (e.g., D:\Office\setup.exe):"
  if (Test-Path $officePath) {
    Start-Process -FilePath $officePath -Wait
  } else {
    Write-Warning "Office setup file not found at '$officePath'."
  }
}
# EndRegion

# Reboot after initial setup (if required by installed software)
if ($rebootRequired) {
    Restart-Computer -Force
}
