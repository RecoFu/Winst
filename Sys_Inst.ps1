# Set execution policy and system locale
Set-ExecutionPolicy RemoteSigned -Force
Set-WinSystemLocale zh-tw

# Configure page file settings
Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=0; MaximumSize=0}

# Enable Hyper-V and Windows Subsystem for Linux (WSL)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -n
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -n
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -n

# Configure system settings
bcdedit /set hypervisorlaunchtype auto
powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
Powercfg /h /type full
Powercfg /h on

# Install Chocolatey package manager and PSWindowsUpdate module
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Install-Module PSWindowsUpdate

# Install desired applications using Chocolatey package manager
choco install 7zip GoogleChrome keepass Everything fastcopy vscode vlc telegram line picpick.portable firefox git terraform mRemoteNG meshcommander Sysinternals choco-cleaner -y --ignore-checksums
choco install choco-upgrade-all-at --params '/WEEKLY:yes /DAY:SUN /TIME:01:00'

# Uncomment the line below to install Office 2019 ProPlus (force install)
# choco install office2019proplus drivereasyfree --force

# Run BGInfo with a specific configuration file
"C:\bginfo\bginfo.exe" "C:\bginfo\default.bgi" /TIMER:00 /NOLICPROMPT

# Run Windows servicing cleanup task
schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponent Cleanup"

# Open System Properties - Performance Options
C:\Windows\SysWOW64\SystemPropertiesPerformance.exe

# Driver recommendation and configuration
# Install the PSWindowsUpdate module if not already installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force
}

# Check for recommended drivers and install them
$recommendedDrivers = Get-WindowsDriver -Online -AllUpdates | Where-Object {$_.UpdateClass -eq 'Driver' -and $_.Recommended -eq $true}
if ($recommendedDrivers) {
    Write-Host "Installing recommended drivers..."
    foreach ($driver in $recommendedDrivers) {
        $driver | Add-WindowsDriver -Confirm:$false
    }
    Write-Host "Recommended drivers installed successfully."
} else {
    Write-Host "No recommended drivers found."
}

# Additional configurations and commands
winget
# ... (other winget commands)

# Office Language Pack - Traditional Chinese
# Download link: https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=languagepack&language=zh-tw&platform=x64&source=O16LAP&version=O16GA

# Microsoft Activation Scripts
# Download link: https://github.com/massgravel/microsoft-activation-scripts

# KeePass Language Pack - Traditional Chinese
# Download link: https://downloads.sourceforge.net/keepass/KeePass-2.52-Chinese_Traditional.zip

# Line Backup
# Backup location: %USERPROFILE%\AppData\Local\

# mRemoteNG
# Configuration location: %AppData%\mRemoteNG

# Cleanup and update commands
choco upgrade all -y
powershell -NoProfile -ExecutionPolicy unrestricted -Command "& 'C:\tools\BCURRAN3\choco-cleaner.ps1' %*"
powershell Get-WindowsUpdate -AcceptAll -Install
winget upgrade --all --silent
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Restart the computer
Restart-Computer
