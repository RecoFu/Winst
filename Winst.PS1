# Get System Information
# Gets the computer model, Windows version, and installation date.
# This information is useful for identifying your computer.
$model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$winver = (Get-ComputerInfo).WindowsVersion
$installDate = (Get-WmiObject -Class Win32_OperatingSystem).InstallDate
$installDateFormatted = [System.Management.ManagementDateTimeConverter]::ToDateTime($installDate).ToString("yyyyMMdd")
$systemInfo = "$model_$winver_$installDateFormatted"
Write-Output $systemInfo


# --- Module: Chocolatey Package Manager ---
# Installs Chocolatey, a package manager for Windows.
# It makes installing software much easier.
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Installs several useful applications using Chocolatey.
choco install 7zip GoogleChrome keepass Everything fastcopy vscode vlc line picpick.portable choco-cleaner -y --ignore-checksums
# Schedules a weekly automatic update of all Chocolatey packages.
choco install choco-upgrade-all-at --params "'/WEEKLY:yes /DAY:SUN /TIME:01:00'"


# --- Module: Windows Updates ---
# Installs the PSWindowsUpdate module for managing Windows updates.
Install-Module PSWindowsUpdate
# Installs all pending Windows updates.
powershell Get-WindowsUpdate -AcceptAll -Install


# --- Module: Winget Package Manager ---
# Installs Winget, a package manager built into Windows.
# Useful for installing apps from the Microsoft Store.
# (Check if already installed before running this section. Manual installation from the Microsoft Store is also an option.)
$progressPreference = 'silentlyContinue'
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager
Write-Host "Done."

# Installs applications using Winget.
winget install 7zip.7zip
winget install voidtools.Everything
winget install line.line
winget install picpick
winget install Google.Chrome
winget install VideoLAN.VLC
winget install Microsoft.WindowsTerminal
winget install git.git
winget install Winscp
winget install vscode
winget install Telegram.TelegramDesktop
winget install terraform
winget install amir1376.ABDownloadManager
winget install Windows File Recovery
winget install WinfrGUI-APP
winget upgrade --all --silent


# --- Module: System Configuration ---
# Sets the execution policy to allow running scripts.
Set-ExecutionPolicy RemoteSigned -Force
# Sets the system locale to Traditional Chinese (Taiwan).
Set-WinSystemLocale zh-tw
# Disables the paging file. (Consider carefully before disabling)
Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=0; MaximumSize=0}
# Enables Hyper-V.
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -n
# Enables the Windows Subsystem for Linux (WSL).
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -n
# Enables Containers-DisposableClientVM.
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -n
#Sets Hypervisor Launch Type to Auto
bcdedit /set hypervisorlaunchtype auto
#Configure power plan (High performance)
powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#Configure Hibernation settings (Full)
Powercfg /h /type full
Powercfg /h on


# --- Module: Office Installation ---
# Installs Office 2021 ProPlus. Requires the setup.exe and Configuration.xml.
# Replace with your actual paths.
Start-Process -FilePath "E:\OFFICEPROPLUS2021\setup.exe" -ArgumentList "/configure Z:\Configuration.xml" -Wait


# --- Module: System Cleanup and Optimization ---
# Upgrades all Chocolatey packages.
choco upgrade all -y
# Runs a script to clean up leftover Chocolatey packages. Requires the script at specified location.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\tools\BCURRAN3\choco-cleaner.ps1'  %*"
# Runs system component cleanup.
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
# Adjusts performance settings.
C:\Windows\SysWOW64\SystemPropertiesPerformance.exe
#Runs Scheduled Task for Component Cleanup
schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponent Cleanup"


# --- Module:  Restart Computer ---
# Restarts the computer after all operations complete.
Restart-Computer
