# Get computer model
$model = (Get-WmiObject -Class Win32_ComputerSystem).Model
$backupFile = "D:\Backup\$model\$model-Lst.txt"

# Create backup directory
$backupPath = "D:\Backup\$model"
New-Item -ItemType Directory -Path $backupPath -Force

# Check hardware status
$hardware = Get-WmiObject -Class Win32_ComputerSystem

# Check driver and application list
$drivers = Get-WindowsDriver -Online -All
$apps = Get-AppxPackage

# Backup information to a text file
$hardware | Out-File -FilePath $backupFile
"Drivers:" | Out-File -FilePath $backupFile -Append
$drivers | Format-Table -AutoSize | Out-String | Out-File -FilePath $backupFile -Append
"Applications:" | Out-File -FilePath $backupFile -Append
$apps | Format-Table -AutoSize | Out-String | Out-File -FilePath $backupFile -Append

# Backup driver and application list to CSV files
$drivers | Export-Csv -Path "$backupPath\drivers.csv" -NoTypeInformation
$apps | Export-Csv -Path "$backupPath\apps.csv" -NoTypeInformation

# Update system
powershell Get-WindowsUpdate -AcceptAll -Install

# Update all applications
choco upgrade all -y
winget upgrade --all --silent

# Clean up system components
dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Run Choco Cleaner
powershell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\tools\BCURRAN3\choco-cleaner.ps1' %*"
