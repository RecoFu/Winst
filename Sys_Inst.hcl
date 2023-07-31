# Set execution policy and system locale
provisioner "powershell" {
  inline = [
    "Set-ExecutionPolicy RemoteSigned -Force",
    "Set-WinSystemLocale zh-tw"
  ]
}

# Configure page file settings
provisioner "powershell" {
  inline = [
    "Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='C:\\pagefile.sys'; InitialSize=0; MaximumSize=0}"
  ]
}

# Enable Hyper-V and Windows Subsystem for Linux (WSL)
provisioner "powershell" {
  inline = [
    "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -n",
    "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -n",
    "Enable-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -All -Online -n"
  ]
}

# Configure system settings
provisioner "powershell" {
  inline = [
    "bcdedit /set hypervisorlaunchtype auto",
    "powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
    "Powercfg /h /type full",
    "Powercfg /h on"
  ]
}

# Install Chocolatey package manager and PSWindowsUpdate module
provisioner "remote-exec" {
  inline = [
    "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
    "Install-Module PSWindowsUpdate"
  ]
}

# Install desired applications using Chocolatey package manager
provisioner "remote-exec" {
  inline = [
    "choco install 7zip GoogleChrome keepass Everything fastcopy vscode vlc telegram line picpick.portable firefox git terraform mRemoteNG meshcommander Sysinternals choco-cleaner -y --ignore-checksums",
    "choco install choco-upgrade-all-at --params '/WEEKLY:yes /DAY:SUN /TIME:01:00'"
  ]
}

# Run BGInfo with a specific configuration file
provisioner "remote-exec" {
  inline = [
    '"C:\\bginfo\\bginfo.exe" "C:\\bginfo\\default.bgi" /TIMER:00 /NOLICPROMPT'
  ]
}

# Run Windows servicing cleanup task
provisioner "remote-exec" {
  inline = [
    "schtasks.exe /Run /TN '\\Microsoft\\Windows\\Servicing\\StartComponent Cleanup'"
  ]
}

# Open System Properties - Performance Options
provisioner "remote-exec" {
  inline = [
    "C:\\Windows\\SysWOW64\\SystemPropertiesPerformance.exe"
  ]
}

# Restart the computer
provisioner "remote-exec" {
  inline = [
    "Restart-Computer"
  ]
}
