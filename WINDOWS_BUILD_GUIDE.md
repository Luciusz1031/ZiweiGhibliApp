# Windows 使用者編譯與安裝 iOS IPA 完整教學指南

在 Windows 電腦上，由於 Apple 官方限制 iOS SDK 與 Xcode 工具鏈僅能運行於 macOS 上，因此**無法在 Windows 本地直接執行編譯**。

但是，**您完全不需要購買 Mac 電腦！**
我們已經為您配置好了 **GitHub Actions 免費雲端自動編譯工作流**，只要將代碼上傳至 GitHub，雲端 Mac 會在 2~3 分鐘內自動編譯出 `.ipa` 檔案供您下載，並在 Windows 電腦上安裝至 iPhone！

---

## 步驟一：將代碼推送至 GitHub 觸發自動編譯

如果您已有 GitHub 帳號：
1. 在 [GitHub.com](https://github.com) 建立一個新的倉庫（例如：`ZiweiGhibliApp`，設為 Private 私人或 Public 公開皆可）。
2. 在 Windows 的專案目錄打開 PowerShell 或 Terminal，依序執行：
   ```powershell
   cd C:\Users\lordl\.gemini\antigravity\scratch\ZiweiGhibliApp
   git init
   git add .
   git commit -m "feat: 初版宮崎駿風紫微斗數 App"
   git branch -M main
   git remote add origin https://github.com/<您的GitHub用戶名>/ZiweiGhibliApp.git
   git push -u origin main
   ```
3. 推送完成後，進入您的 GitHub 倉庫頁面，點擊上方的 **「Actions」** 分頁。
4. 您會看到 **「Build iOS IPA」** 工作流正在自動運行（使用 Apple Silicon macOS 雲端機器編譯）。
5. 等待約 2~3 分鐘打綠色勾勾後，點進該次工作流，在最下方的 **「Artifacts」** 區塊點擊下載 **`ZiweiGhibliApp-IPA`**。
6. 解壓縮後即可獲得 **`ZiweiGhibliApp.ipa`**！

---

## 步驟二：在 Windows 上把 IPA 安裝到 iPhone（免越獄）

在 Windows 上安裝 IPA 最穩定、最推薦的工具是 **Sideloadly**（專為 Windows 設計的免費 iOS 側載工具）：

### 1. 準備工具
1. 在 Windows 電腦上下載並安裝 [Sideloadly (官方官網)](https://sideloadly.io/)。
2. 確保 Windows 電腦已安裝 iTunes（從 Apple 官網下載的獨立版本，非微軟商店版尤佳）以讓電腦能辨識 iPhone。

### 2. 安裝 App 至 iPhone
1. 用 USB 傳輸線將 iPhone 連接至 Windows 電腦（若 iPhone 彈出提示，點選「信任這部電腦」）。
2. 打開 **Sideloadly**：
   - 頂部 **iDevice** 會自動識別您的 iPhone。
   - 將剛才下載的 `ZiweiGhibliApp.ipa` 直接**拖曳進 Sideloadly 視窗中**。
   - 在 **Apple ID** 欄位輸入您平時使用的免費個人 Apple ID 帳號（Sideloadly 會在本地為此 IPA 進行自簽名，完全免費）。
3. 點擊 **「Start」** 按鈕。
4. 稍等約 30 秒至 1 分鐘，看到視窗顯示 **`Done!`**，您的 iPhone 桌面上就會出現「小鹿兒算命」App 的 BOURNS 圖示！

---

## 步驟三：首次在 iPhone 上開啟 App

iOS 為了安全性，首次安裝自簽 App 需要確認信任：
1. 拿起 iPhone，前往 **「設定」 > 「一般」 > 「VPN 與裝置管理」**。
2. 找到您的 Apple ID 簽名名稱，點進去並點選 **「信任 [您的 Apple ID]」**。
3. 返回桌面，即可直接點擊開啟「小鹿兒算命」App！
4. 體驗 100% 離線、無廣告、具備宮崎駿美學與倪師《天紀》排盤的獨立 iOS 應用！
