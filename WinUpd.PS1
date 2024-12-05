# WinUpd.ps1 - Daily Optimization and Backup (Run at 6 AM)

# Set execution policy for the current session
Set-ExecutionPolicy Bypass -Scope Process -Force

# Region: Windows Updates and Package Upgrades
# Install Windows Updates
Install-Module PSWindowsUpdate -Force -Confirm:$false
Get-WindowsUpdate -AcceptAll -Install -Confirm:$false

# Upgrade all packages via winget
winget upgrade --all --silent

# Upgrade all packages via Chocolatey
choco upgrade all -y -r:0 --ignore-checksums
# EndRegion

# Region: Disk Cleanup and Optimization
# Run Disk Cleanup (Optional)
# Cleanmgr.exe /sagerun:1 # Consider replacing with more specific cleanup tasks

# Run DISM cleanup
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Optimize drives (Optional)
# Optimize-Volume -DriveLetter C -ReTrim -Verbose
# EndRegion

# Region: Backup (Manual Configuration)
Write-Host "Backup needs to be configured manually. Consider using File History, Backup and Restore, or a third-party tool."

# Example using Robocopy (adapt as needed):
# $source = "C:\Users\<username>\Documents"
# $destination = "D:\Backup\Documents"
# robocopy $source $destination /MIR /R:0 /W:0 /MT:16
# EndRegion

# Region: Choco Cleaner (Optional)
choco-cleaner all
# EndRegion


# Reboot if necessary (e.g., after Windows Updates)
if (((Get-WindowsUpdate).RebootRequired) -eq $true) {
  Restart-Computer -Force
}
