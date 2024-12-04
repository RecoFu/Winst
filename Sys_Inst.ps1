<#
.SYNOPSIS
Windows 11 系統升級、軟體安裝與系統優化腳本

.DESCRIPTION
此腳本提供全自動化的 Windows 11 升級、軟體安裝與系統客製化流程
支援手動與自動模式，增強系統部署效率與彈性

.NOTES
版本: 2.0
作者: AI助理
日期: 2024-12-04
#>

# 全域設定
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# 日誌記錄函數
function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$Level] [$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path "C:\Logs\WindowsUpgrade.log" -Value $logMessage
}

# 系統升級主函數
function Invoke-WindowsUpgrade {
    param(
        [string]$IsoPath,
        [string]$Edition = "Pro",
        [switch]$AutoMode = $false
    )

    try {
        Write-Log "開始 Windows 系統升級程序"
        
        # 驗證 ISO 檔案
        if (-not (Test-Path $IsoPath)) {
            throw "ISO 檔案不存在: $IsoPath"
        }

        # 掛載 ISO
        $mountResult = Mount-DiskImage -ImagePath $IsoPath -PassThru
        $driveLetter = ($mountResult | Get-Volume).DriveLetter

        # 升級命令
        $upgradeArgs = @(
            "/auto", 
            "upgrade", 
            "/dynamicupdate", 
            "disable", 
            "/noreboot"
        )

        if ($AutoMode) {
            $upgradeArgs += "/quiet"
        }

        # 執行升級
        Start-Process -FilePath "$($driveLetter):\setup.exe" -ArgumentList $upgradeArgs -Wait

        Write-Log "Windows 升級成功"
    }
    catch {
        Write-Log "Windows 升級失敗: $_" -Level "Error"
    }
    finally {
        # 卸載 ISO
        Dismount-DiskImage -ImagePath $IsoPath
    }
}

# 軟體安裝函數
function Install-RecommendedSoftware {
    $softwareList = @(
        "7zip.7zip",
        "Google.Chrome",
        "VideoLAN.VLC",
        "Microsoft.WindowsTerminal"
    )

    foreach ($software in $softwareList) {
        try {
            Write-Log "安裝軟體: $software"
            winget install $software --silent
        }
        catch {
            Write-Log "安裝 $software 失敗" -Level "Warning"
        }
    }
}

# 系統優化函數
function Optimize-SystemPerformance {
    try {
        # 電源與虛擬化設定
        bcdedit /set hypervisorlaunchtype auto
        powercfg -S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        Powercfg /h /type full
        Powercfg /h on

        # 啟用系統功能
        $features = @(
            "Microsoft-Hyper-V",
            "Microsoft-Windows-Subsystem-Linux",
            "Containers-DisposableClientVM"
        )

        foreach ($feature in $features) {
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
        }

        Write-Log "系統優化完成"
    }
    catch {
        Write-Log "系統優化失敗: $_" -Level "Error"
    }
}

# 主執行函數
function Start-SystemUpgrade {
    param(
        [string]$IsoPath = "C:\Windows11_23H2.iso",
        [switch]$AutoMode = $false
    )

    # 建立日誌目錄
    if (-not (Test-Path "C:\Logs")) {
