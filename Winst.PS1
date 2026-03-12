#Requires -RunAsAdministrator
# ============================================================
# Winst.ps1 — Windows 全自動部署 v2026
# Reco Fu / 優雅架構社
# 高斯式：最少選擇，最大效能，可擴充
# 執行：powershell -ExecutionPolicy Bypass -File Winst.ps1
# ============================================================
chcp 65001 | Out-Null
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================================================
# 選項選單（唯一需要人工介入的地方）
# ============================================================
function Show-Menu {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Winst v2026 — 選擇部署模式          ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║  [1] 全自動（推薦，無人值守）            ║"
    Write-Host "║  [2] 進階（分層選擇）                    ║"
    Write-Host "║  [0] 結束                                ║"
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    return (Read-Host "選擇")
}

function Show-LayerMenu {
    Write-Host ""
    Write-Host "  選擇要執行的層（空白=全選，多選用逗號）："
    Write-Host "  [L1] 系統設定（locale/power/虛擬化）"
    Write-Host "  [L2] 核心工具（git/vscode/7zip...）"
    Write-Host "  [L3] 選配工具（chrome/line/telegram）"
    Write-Host "  [L4] AI環境（Ollama+模型）"
    Write-Host "  [L5] Windows Update + DISM清理"
    Write-Host "  [L6] DevLauncher部署"
    $sel = Read-Host "  輸入（例：L1,L2,L4 或直接Enter全選）"
    if ([string]::IsNullOrWhiteSpace($sel)) { return @("L1","L2","L3","L4","L5","L6") }
    return $sel.ToUpper() -split "," | ForEach-Object { $_.Trim() }
}

# ============================================================
# L0：Chocolatey Bootstrap（永遠執行）
# ============================================================
function Install-Chocolatey {
    Write-Host "[L0] Chocolatey..." -ForegroundColor Yellow
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    } else {
        Write-Host "[L0] 已存在" -ForegroundColor Green
    }
    # 自動週更
    choco install choco-upgrade-all-at -y --params "'/WEEKLY:yes /DAY:SUN /TIME:02:00'" | Out-Null
}

# ============================================================
# L1：系統設定
# ============================================================
function Set-System {
    Write-Host "[L1] 系統設定..." -ForegroundColor Yellow

    # 語系
    Set-WinSystemLocale zh-TW

    # 電源：高效能
    powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # 休眠：reduced（保留快速啟動但省空間）
    powercfg /h /type reduced
    powercfg /h on

    # Hypervisor
    bcdedit /set hypervisorlaunchtype auto | Out-Null

    # 虛擬化功能
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart | Out-Null

    # 效能設定（視覺效果最佳化）
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    Set-ItemProperty -Path $path -Name VisualFXSetting -Value 2 -ErrorAction SilentlyContinue

    # PageFile：不動（保持系統管理，避免大型模型OOM）
    # Set-WmiInstance Win32_PageFileSetting ... ← 刻意保留預設，AI模型需要

    # 執行原則
    Set-ExecutionPolicy RemoteSigned -Force

    Write-Host "[L1] 完成" -ForegroundColor Green
}

# ============================================================
# L2：核心工具（精簡，必裝）
# ============================================================
function Install-Core {
    Write-Host "[L2] 核心工具..." -ForegroundColor Yellow
    $pkgs = @(
        "git"
        "vscode"
        "obsidian"
        "7zip"
        "everything"
        "fastcopy"
        "powertoys"
        "microsoft-windows-terminal"
        "keepass"
        "mremoteng"
        "openssl"
        "pandoc"
        "python"
        "nodejs"
        "putty.portable"
        "winscp.install"
        "choco-cleaner"
    )
    choco install ($pkgs -join " ") -y --ignore-checksums | Out-Null

    # Git 全域設定
    git config --global user.name "Reco Fu"
    git config --global user.email "recofu@gmail.com"
    git config --global core.editor "code --wait"
    git config --global core.autocrlf false
    git config --global init.defaultBranch main
    git config --global alias.lo "log --oneline"
    git config --global alias.ll "log --pretty=format:'%h %ad | %s [%an]' --graph --date=short"

    # PATH 更新
    $env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\Program Files\Microsoft VS Code\bin"

    Write-Host "[L2] 完成" -ForegroundColor Green
}

# ============================================================
# L3：選配工具（依需求）
# ============================================================
function Install-Optional {
    Write-Host "[L3] 選配工具..." -ForegroundColor Yellow

    # 瀏覽器（擇一）
    $browser = Read-Host "  瀏覽器：[1]Chrome [2]Firefox [3]跳過"
    if ($browser -eq "1") { choco install googlechrome -y --ignore-checksums | Out-Null }
    if ($browser -eq "2") { choco install firefox -y --ignore-checksums | Out-Null }

    # 溝通
    $comm = Read-Host "  溝通工具 Line+Telegram？[Y/N]"
    if ($comm -eq "Y" -or $comm -eq "y") {
        choco install line telegram -y --ignore-checksums | Out-Null
    }

    # 交易工具（KGI）
    $trade = Read-Host "  KGI交易系統？[Y/N]"
    if ($trade -eq "Y" -or $trade -eq "y") {
        $kgiUrl = "https://www.kgieworld.com.tw/download/service/gts.exe"
        $kgiPath = "$env:TEMP\kgisetup.exe"
        Invoke-WebRequest -Uri $kgiUrl -OutFile $kgiPath
        Start-Process $kgiPath -Wait
    }

    # VSCode Extensions
    $ext = Read-Host "  VSCode AI擴充套件？[Y/N]"
    if ($ext -eq "Y" -or $ext -eq "y") {
        code --install-extension Continue.continue        # Ollama本地AI
        code --install-extension eamodio.gitlens         # Git強化
        code --install-extension ms-python.python        # Python
        code --install-extension esbenp.prettier-vscode  # 格式化
    }

    # Cursor
    $cursor = Read-Host "  安裝Cursor IDE？[Y/N]"
    if ($cursor -eq "Y" -or $cursor -eq "y") {
        choco install cursoride -y --ignore-checksums | Out-Null
    }

    Write-Host "[L3] 完成" -ForegroundColor Green
}

# ============================================================
# L4：AI環境
# ============================================================
function Install-AI {
    Write-Host "[L4] AI環境..." -ForegroundColor Yellow

    # Ollama
    choco install ollama -y | Out-Null

    # 模型路徑 → D槽
    [System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS","D:\AIModels\ollama_models","Machine")
    $env:OLLAMA_MODELS = "D:\AIModels\ollama_models"
    New-Item -ItemType Directory -Path "D:\AIModels\ollama_models" -Force | Out-Null

    # Junction
    if (Test-Path "$env:USERPROFILE\.ollama") {
        Remove-Item "$env:USERPROFILE\.ollama" -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Junction -Path "$env:USERPROFILE\.ollama" `
             -Target "D:\AIModels\ollama_models" -ErrorAction SilentlyContinue | Out-Null

    # 模型下載（背景）
    Write-Host "[L4] 模型下載中（背景，約1-2小時）..."
    Start-Process "cmd" -ArgumentList "/c ollama pull phi4:14b && ollama pull qwen3:8b && ollama pull llama3.2:3b && echo DONE > D:\AIModels\models_ready.txt" -WindowStyle Minimized

    # CLI工具
    npm install -g @anthropic-ai/claude-code | Out-Null
    npm install -g @google/gemini-cli | Out-Null

    Write-Host "[L4] 完成（模型背景下載中）" -ForegroundColor Green
}

# ============================================================
# L5：Windows Update + 清理
# ============================================================
function Update-System {
    Write-Host "[L5] Windows Update + 清理..." -ForegroundColor Yellow

    # PSWindowsUpdate
    if (!(Get-Module -ListAvailable PSWindowsUpdate)) {
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module PSWindowsUpdate -Force | Out-Null
    }
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-Null

    # DISM清理
    dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null

    # Choco清理
    if (Test-Path "C:\tools\BCURRAN3\choco-cleaner.ps1") {
        powershell -NoProfile -ExecutionPolicy Bypass -File "C:\tools\BCURRAN3\choco-cleaner.ps1"
    }

    Write-Host "[L5] 完成" -ForegroundColor Green
}

# ============================================================
# L6：DevLauncher部署
# ============================================================
function Deploy-Launcher {
    Write-Host "[L6] DevLauncher..." -ForegroundColor Yellow

    New-Item -ItemType Directory -Path "D:\Projects" -Force | Out-Null

    $launcher = @'
@echo off
chcp 65001 >nul
title Reco Dev Launcher v2026
color 0B
set "OBS=%LOCALAPPDATA%\Programs\Obsidian\Obsidian.exe"
set "VAULT=D:\Projects\Obsidian"
set "OPENCLAW=D:\Projects\New Mouse 小鼠5策略"
set "SLS=D:\Projects\優雅架構科技社 Sovereign Logic Systems (SLS)"
set "CISSP=D:\Projects\CISSP"
:MENU
cls
echo.
echo  ╔════════════════════════════╗
echo  ║  Reco Dev Launcher v2026  ║
echo  ╠════════════════════════════╣
echo  ║ [1] Obsidian              ║
echo  ║ [2] VSCode                ║
echo  ║ [3] Cursor                ║
echo  ║ [4] Git Bash              ║
echo  ║ [5] Ollama serve          ║
echo  ║ [6] phi4:14b              ║
echo  ║ [7] qwen3:8b              ║
echo  ║ [8] llama3.2:3b           ║
echo  ╠════════════════════════════╣
echo  ║ [A] 全開                  ║
echo  ║ [B] OpenClaw組合          ║
echo  ║ [C] CISSP組合             ║
echo  ║ [D] SLS組合               ║
echo  ║ [0] 結束                  ║
echo  ╚════════════════════════════╝
echo.
set /p C=選擇:
if "%C%"=="1" (start "" "%OBS%" "%VAULT%") & goto MENU
if "%C%"=="2" (start "" code) & goto MENU
if "%C%"=="3" (start "" cursor) & goto MENU
if "%C%"=="4" (start "" "C:\Program Files\Git\git-bash.exe") & goto MENU
if "%C%"=="5" (start "Ollama" cmd /k "ollama serve") & goto MENU
if "%C%"=="6" (start "phi4" cmd /k "ollama run phi4:14b") & goto MENU
if "%C%"=="7" (start "qwen3" cmd /k "ollama run qwen3:8b") & goto MENU
if "%C%"=="8" (start "llama3" cmd /k "ollama run llama3.2:3b") & goto MENU
if /i "%C%"=="A" (start "" "%OBS%" "%VAULT%" & start "" code & start "" "C:\Program Files\Git\git-bash.exe") & goto MENU
if /i "%C%"=="B" (start "" "%OBS%" "%VAULT%" & start "" code "%OPENCLAW%") & goto MENU
if /i "%C%"=="C" (start "" "%OBS%" "%VAULT%" & start "" code "%CISSP%") & goto MENU
if /i "%C%"=="D" (start "" "%OBS%" "%VAULT%" & start "" code "%SLS%") & goto MENU
if "%C%"=="0" exit
goto MENU
'@
    $launcher | Out-File "D:\Projects\DevLauncher.bat" -Encoding utf8
    Write-Host "[L6] DevLauncher → D:\Projects\DevLauncher.bat" -ForegroundColor Green
}

# ============================================================
# 主流程
# ============================================================
$mode = Show-Menu

Install-Chocolatey

switch ($mode) {
    "1" {
        # 全自動
        Set-System
        Install-Core
        Install-AI
        Update-System
        Deploy-Launcher
        # 選配工具仍需確認
        $opt = Read-Host "安裝選配工具（Chrome/Line/Cursor）？[Y/N]"
        if ($opt -eq "Y" -or $opt -eq "y") { Install-Optional }
    }
    "2" {
        # 進階分層
        $layers = Show-LayerMenu
        if ($layers -contains "L1") { Set-System }
        if ($layers -contains "L2") { Install-Core }
        if ($layers -contains "L3") { Install-Optional }
        if ($layers -contains "L4") { Install-AI }
        if ($layers -contains "L5") { Update-System }
        if ($layers -contains "L6") { Deploy-Launcher }
    }
    default { exit }
}

# ============================================================
# 完成
# ============================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  部署完成                                ║" -ForegroundColor Green
Write-Host "║  AI模型背景下載中 → D:\AIModels\         ║" -ForegroundColor Green
Write-Host "║  啟動器 → D:\Projects\DevLauncher.bat   ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$restart = Read-Host "立即重開機？[Y/N]"
if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer -Force
}
