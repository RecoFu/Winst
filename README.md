# Windows 11 Upgrade and Optimization Script

This PowerShell script automates the process of upgrading Windows 11, installing essential software, and optimizing system settings.  It's designed for ease of use and maintainability.

**Features:**

* **Automated Upgrade:**  Seamlessly upgrades Windows 11 (including to Pro edition).
* **Software Installation:** Installs a curated set of popular applications using Winget.
* **System Optimization:** Configures system settings for improved performance and stability.
* **System Updates and Cleanup:** Keeps your system up-to-date and removes unnecessary files.
* **Flexible Modes:** Offers both Automatic and Advanced modes to suit various needs.
* **Detailed Logging:** Provides a comprehensive log file for troubleshooting.


**Prerequisites:**

* **Administrator Privileges:** The script must be run with administrator privileges.
* **Windows 11 ISO:**  An ISO file of the desired Windows 11 version (e.g., 23H2) is required for the upgrade process.  (Path specified during execution)
* **Internet Connection:**  Required for downloading updates and installing software via Winget.
* **PowerShell 5.1 or higher:** The script is written for PowerShell 5.1 and later versions.


**How to Use:**

1. **Clone the Repository:** Clone this repository to your local machine.
2. **Download Windows 11 ISO:** Download the Windows 11 ISO file and place it in a known location.
3. **Run the Script:** Open PowerShell as administrator and navigate to the script's directory. Execute the script using `.\Winstal.ps1`.
4. **Choose Mode:** Select either Automatic or Advanced mode from the menu.
    * **Automatic Mode:** Performs the entire upgrade, software installation, and optimization process automatically.
    * **Advanced Mode:** Allows selective execution of upgrade, software installation, optimization, and update/cleanup modules.


**Automatic Mode:**

This mode requires the path to your Windows 11 ISO file as input.  The script handles the rest automatically.

**Advanced Mode:**

Advanced mode allows granular control over which parts of the process to execute.  You will be presented with a menu to choose which modules to run.

**Log File:**

A log file named `WindowsUpgrade.log` is created in the `C:\Logs` directory. This file contains detailed information about the script's execution, including any errors encountered.

**Disclaimer:**

This script is provided as-is. Use it at your own risk. Always back up your data before running any system upgrade or optimization scripts.


**Contributing:**

Contributions are welcome! Please open issues or pull requests to report bugs, suggest improvements, or add new features.




# Windows 11升級最佳化腳本

此 PowerShell 腳本自動執行升級 Windows 11、安裝基本軟體和最佳化系統設定的程序。 它的設計是為了易於使用和可維護性。

**特徵：**

* **自動升級：** 無縫升級 Windows 11（含專業版）。
* **軟體安裝：** 使用 Winget 安裝一組精選的熱門應用程式。
* **系統最佳化：** 配置系統設定以提高效能和穩定性。
* **系統更新和清理：** 讓您的系統保持最新狀態並刪除不必要的檔案。
* **靈活模式：** 提供自動和進階模式以滿足各種需求。
* **詳細日誌記錄：** 提供故障排除的全面日誌檔案。


**先決條件：**

* **管理員權限：** 腳本必須以管理員權限執行。
* **Windows 11 ISO：** 升級過程需要所需 Windows 11 版本（例如 23H2）的 ISO 檔案。 （執行時指定的路徑）
* **網路連線：** 透過 Winget 下載更新和安裝軟體需求。
* **PowerShell 5.1 或更高版本：** 腳本是為 PowerShell 5.1 及更高版本編寫的。


**使用方法：**

1. **複製儲存庫：** 將此儲存庫複製到本機。
2. **下載 Windows 11 ISO：** 下載 Windows 11 ISO 檔案並將其放置在已知位置。
3. **執行腳本：** 以管理員身分開啟 PowerShell 並導覽至腳本的目錄。使用“.\Winstal.ps1”執行腳本。
4. **選擇模式：** 從選單中選擇自動或進階模式。
 * **自動模式：** 自動執行整個升級、軟體安裝和最佳化過程。
 * **進階模式：** 允許選擇性執行升級、軟體安裝、最佳化和更新/清理模組。


**自動模式：**

此模式需要 Windows 11 ISO 檔案的路徑作為輸入。 腳本會自動處理其餘的事情。

**進階模式：**

進階模式允許對要執行的流程部分進行精細控制。 您將看到一個選單來選擇要執行的模組。

**記錄檔:**

將在「C:\Logs」目錄中建立名為「WindowsUpgrade.log」的日誌檔案。該文件包含有關腳本執行的詳細信息，包括遇到的任何錯誤。

**免責聲明：**

該腳本按原樣提供。使用它的風險由您自行承擔。在執行任何系統升級或最佳化腳本之前，請務必備份資料。


**貢獻：**

歡迎貢獻！請開啟問題或拉取請求以報告錯誤、提出改進建議或新增功能。
