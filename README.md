# Winst
**Windows 全自動部署腳本 — 高斯式精簡架構**
Reco Fu / 優雅架構社 | v2026.03.11

---

## 設計原則

```
最少選擇  → 開頭一次，其餘無人值守
最少安裝  → 只裝必要，選配明確分離
最大效能  → 系統層優化內建
最大擴充  → 六層架構，各層獨立可跳過
```

---

## 快速開始

```powershell
# 以系統管理員身份執行 PowerShell
powershell -ExecutionPolicy Bypass -File Winst_v2026.ps1
```

選擇模式：
- `[1]` 全自動（推薦，約30分鐘，AI模型背景下載另需1-2小時）
- `[2]` 進階分層（選擇要執行的層）

---

## 六層架構

| 層 | 內容 | 互動 |
|---|---|---|
| L0 | Chocolatey Bootstrap | 無 |
| L1 | 系統設定（locale/power/虛擬化） | 無 |
| L2 | 核心工具（git/vscode/obsidian...） | 無 |
| L3 | 選配工具（Chrome/Line/Cursor/KGI） | 有 |
| L4 | AI環境（Ollama+模型） | 無 |
| L5 | Windows Update + DISM清理 | 無 |
| L6 | DevLauncher自動生成 | 無 |

---

## L2 核心工具清單

```
git / vscode / obsidian / 7zip / everything
fastcopy / powertoys / windows-terminal
keepass / mremoteng / openssl / pandoc
python / nodejs / putty / winscp / choco-cleaner
```

## L3 選配工具

```
瀏覽器    → Chrome 或 Firefox（擇一）
溝通      → Line + Telegram
交易      → KGI 元大交易系統
VSCode    → Continue（Ollama）/ GitLens / Prettier
IDE       → Cursor
```

## L4 AI 本地模型

| 模型 | 大小 | 用途 |
|---|---|---|
| phi4:14b | 9.1GB | 主力推理（微軟，非中國） |
| qwen3:8b | 5.2GB | 中文法律語境 |
| llama3.2:3b | 2.0GB | API自動化/輕量任務 |

模型路徑：`D:\AIModels\ollama_models`（Junction自動建立）

---

## DevLauncher 快捷鍵

部署後位於 `D:\Projects\DevLauncher.bat`

| 鍵 | 功能 |
|---|---|
| 1-4 | 單項啟動（Obsidian/VSCode/Cursor/Git） |
| 5-8 | Ollama模型啟動 |
| A | 全開（Obsidian+VSCode+Git） |
| B | OpenClaw工作組合 |
| C | CISSP工作組合 |
| D | SLS工作組合 |

---

## 系統設定說明

```
語系        zh-TW
電源方案    高效能（8c5e7fda）
休眠        reduced（保留快速啟動）
Hypervisor  auto
虛擬化      Hyper-V + WSL + Sandbox 全開
PageFile    系統管理（不設0，AI模型需要）
執行原則    RemoteSigned
```

---

## 注意事項

1. 需要**系統管理員權限**
2. 需要**網路連線**
3. AI模型下載在**背景執行**，完成後 `D:\AIModels\models_ready.txt` 出現
4. L5 Windows Update 可能需要**重開機**才能完全生效
5. KGI交易系統需要**手動完成安裝精靈**

---

## 相關連結

- [Chocolatey](https://chocolatey.org)
- [Ollama](https://ollama.ai)
- [Obsidian](https://obsidian.md)
- [Cursor](https://cursor.sh)
- [Microsoft Activation Scripts](https://github.com/massgravel/microsoft-activation-scripts)
