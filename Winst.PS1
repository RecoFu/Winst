# Winst.ps1 (Get the computer ready after a fresh install)

# This part gets tools to help install things.
function Install-PackageProvider {
  param(
    [string]$ProviderName # Name of the tool to get.
  )
  try { # Try to do this...
    Write-Host "Getting '$ProviderName' tool..." # Tell me what's happening.
    Install-PackageProvider -Name $ProviderName -Force | Out-Null # Get the tool.
    Write-Host "'$ProviderName' tool got!" # All good!
  }
  catch { # But if something goes wrong...
    Write-Warning "Failed to get '$ProviderName': $($_.Exception.Message)" # ...tell me what went wrong.
  }
}

# This part gets Chocolatey, a tool for installing things.
function Install-Chocolatey {
  try { # Try to do this...
    Write-Host "Getting Chocolatey..." # Tell me what's happening.
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) # Get Chocolatey.
    Write-Host "Chocolatey got!" # All good!
  }
  catch { # But if something goes wrong...
    Write-Error "Failed to get Chocolatey: $($_.Exception.Message)" # ...tell me what went wrong.
  }
}

# This part gets Winget, another tool for installing things.
function Install-Winget {
  try { # Try to do this...
    Write-Host "Getting Winget..." # Tell me what's happening.
    Install-PackageProvider -Name NuGet -Force # Get a helper tool first.
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null # Get Winget.
    Repair-WinGetPackageManager # Make sure Winget is working correctly.
    Write-Host "Winget got!" # All good!
  }
  catch { # But if something goes wrong...
    Write-Warning "Failed to get Winget: $($_.Exception.Message)" # ...tell me what went wrong.
  }
}

# This part installs programs.
function Install-Applications {
  param (
    [array]$chocoPackages, # List of programs to get using Chocolatey.
    [array]$wingetPackages # List of programs to get using Winget.
  )
  try { # Try to do this...
    Write-Host "Getting programs using Chocolatey..." # Tell me what's happening.
    choco install $chocoPackages -y --ignore-checksums # Get the programs.
    Write-Host "Getting programs using Winget..." # Tell me what's happening.
    winget install $wingetPackages --silent --accept-source-agreements # Get more programs.
  }
  catch { # But if something goes wrong...
    Write-Warning "Getting programs failed: $($_.Exception.Message)" # ...tell me what went wrong.
  }
}

# This part sets up some computer settings.
function Configure-System {
  try { # Try to do this...
    Write-Host "Setting up computer settings..." # Tell me what's happening.
    Set-WinSystemLocale zh-TW # Set the language.
    Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='C:\pagefile.sys'; InitialSize=0; MaximumSize=0} # Turn off something.
    bcdedit /set hypervisorlaunchtype auto # Turn on something else.
    Write-Host "Computer settings set up!" # All good!
  }
  catch { # But if something goes wrong...
    Write-Warning "Setting up computer settings failed: $($_.Exception.Message)" # ...tell me what went wrong.
  }
}

# Set the programs to install.
$chocoPackages = "7zip", "GoogleChrome", "keepass", "Everything", "fastcopy", "vscode", "vlc", "line", "picpick.portable", "choco-cleaner"
$wingetPackages = @(
    "7zip.7zip",
    "voidtools.Everything",
    "line.line",
    "picpick",
    "Google.Chrome",
    "VideoLAN.VLC",
    "Microsoft.WindowsTerminal"
)

# This part does the main work.
try { # Try to do these things...
  Install-PackageProvider -ProviderName NuGet # Get a helper tool.
  Install-Chocolatey # Get Chocolatey.
  Install-Winget # Get Winget.
  Install-Applications -chocoPackages $chocoPackages -wingetPackages $wingetPackages # Get the programs.
  Configure-System # Set up the computer settings.
  Write-Host "Computer is all set up!" # All good!
}
catch { # But if something goes wrong...
  Write-Error "Setting up the computer failed: $($_.Exception.Message)" # ...tell me what went wrong.
}
