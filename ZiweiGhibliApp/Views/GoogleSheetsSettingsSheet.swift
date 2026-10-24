import SwiftUI

public struct GoogleSheetsSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var webhookUrl: String = GoogleSheetsSyncManager.shared.webhookUrl
    @State private var isEnabled: Bool = GoogleSheetsSyncManager.shared.isEnabled
    @State private var testStatusMessage: String?
    @State private var isTesting: Bool = false
    @State private var isSuccess: Bool = false
    @State private var isCodeCopied: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                GhibliTheme.parchmentBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 頂部小鹿導覽卡
                        HStack(alignment: .top, spacing: 10) {
                            CuteDeerMascotView(size: 42)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Google Sheet 雲端同步")
                                    .font(GhibliTheme.titleFont(size: 16))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Text("將使用者每次排盤輸入的姓名、生日、生辰時辰與日期等資訊，自動記錄至您的專屬 Google 試算表中！")
                                    .font(GhibliTheme.noteFont(size: 12))
                                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                                    .lineSpacing(2)
                            }
                        }
                        .padding(12)
                        .background(GhibliTheme.parchmentCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                        )
                        
                        // 開關
                        Toggle("啟用自動同步至 Google Sheet", isOn: $isEnabled)
                            .font(GhibliTheme.titleFont(size: 14))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .padding(.vertical, 4)
                        
                        // 網址輸入框
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Google Apps Script 網頁應用程式網址 (Web App URL)")
                                    .font(GhibliTheme.bodyFont(size: 12))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            
                            TextField("https://script.google.com/macros/s/.../exec", text: $webhookUrl)
                                .font(.system(size: 12.5, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
                                )
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            if !webhookUrl.isEmpty && !webhookUrl.contains("/exec") {
                                Text("⚠️ 提醒：正式網址結尾必須為 /exec，請確認是否複製到編輯器或開發網址。")
                                    .font(GhibliTheme.noteFont(size: 11))
                                    .foregroundColor(GhibliTheme.tabooRed)
                            }
                        }
                        
                        // 測試按鈕與狀態
                        HStack {
                            Button(action: runTest) {
                                HStack(spacing: 6) {
                                    if isTesting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                    }
                                    Text(isTesting ? "連線測試中..." : "發送測試訊號至試算表")
                                        .font(GhibliTheme.bodyFont(size: 13))
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(webhookUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : GhibliTheme.magicBrass)
                                .cornerRadius(8)
                            }
                            .disabled(isTesting || webhookUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Spacer()
                        }
                        
                        if let msg = testStatusMessage {
                            Text(msg)
                                .font(GhibliTheme.noteFont(size: 12))
                                .foregroundColor(isSuccess ? Color(red: 0.18, green: 0.52, blue: 0.25) : GhibliTheme.tabooRed)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(isSuccess ? Color(red: 0.18, green: 0.52, blue: 0.25).opacity(0.1) : GhibliTheme.tabooRed.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        // 一鍵複製 Apps Script 接收代碼按鈕
                        Button(action: copyAppsScriptCode) {
                            HStack {
                                Image(systemName: isCodeCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                Text(isCodeCopied ? "代碼已複製到剪貼簿！" : "一鍵複製 Google Apps Script 接收端代碼")
                                    .font(GhibliTheme.bodyFont(size: 13))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(isCodeCopied ? Color(red: 0.18, green: 0.52, blue: 0.25) : GhibliTheme.forestMoss)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isCodeCopied ? Color(red: 0.18, green: 0.52, blue: 0.25) : GhibliTheme.borderBrass.opacity(0.8), lineWidth: 1)
                            )
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // 簡易設定指南
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📖 4 步驟排查與設定指南：")
                                .font(GhibliTheme.titleFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            VStack(alignment: .leading, spacing: 7) {
                                StepRow(number: "1", text: "在 Google 試算表中，從頂部選單點選「擴充功能」>「Apps Script」。")
                                StepRow(number: "2", text: "清空編輯器，貼上點擊上方按鈕複製的代碼並儲存。")
                                StepRow(number: "3", text: "點擊右上角「部署」>「新增部署作業」> 種類選擇「網頁應用程式」。")
                                StepRow(number: "4", text: "⚠️【關鍵必檢】執行身分選「我」，「誰可以存取」務必選「所有人 (Anyone)」！將產生的 /exec 結尾網址貼在上方並按「儲存」。")
                            }
                        }
                        .padding(12)
                        .background(GhibliTheme.parchmentCard)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Google Sheet 設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        GoogleSheetsSyncManager.shared.webhookUrl = webhookUrl
                        GoogleSheetsSyncManager.shared.isEnabled = isEnabled
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(GhibliTheme.forestMoss)
                }
            }
        }
    }
    
    private func runTest() {
        guard !webhookUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isTesting = true
        testStatusMessage = nil
        
        GoogleSheetsSyncManager.shared.testConnection(url: webhookUrl) { success, msg in
            isTesting = false
            isSuccess = success
            testStatusMessage = msg
        }
    }
    
    private func copyAppsScriptCode() {
        let script = """
        // ==========================================
        // 🦌 小鹿兒算命・Google Sheet 雲端排盤紀錄接收端
        // ==========================================

        var SPREADSHEET_ID = ""; // 從試算表內「擴充功能 > Apps Script」開啟者保持留空即可自動綁定

        function getTargetSheet() {
          var ss = (SPREADSHEET_ID && SPREADSHEET_ID.trim() !== "") ? 
            SpreadsheetApp.openById(SPREADSHEET_ID.trim()) : 
            SpreadsheetApp.getActiveSpreadsheet();
          if (!ss) {
            throw new Error("找不到試算表！請確認本腳本是從試算表內開啟，或在頂部填入 SPREADSHEET_ID。");
          }
          return ss.getActiveSheet();
        }

        function doPost(e) {
          try {
            var sheet = getTargetSheet();
            if (sheet.getLastRow() === 0) {
              sheet.appendRow([
                "輸入時間", "命主姓名", "性別", "國曆出生日期", "出生時辰", 
                "時辰是否未知", "農曆生辰", "四柱八字", "五行局", "命主星", "身主星", "來源平台"
              ]);
              sheet.getRange(1, 1, 1, 12).setFontWeight("bold").setBackground("#D1E7DD");
            }
            
            var data = {};
            if (e && e.postData && e.postData.contents) {
              try { data = JSON.parse(e.postData.contents); } catch (err) { data = e.parameter || {}; }
            } else if (e && e.parameter) {
              data = e.parameter;
            }
            
            sheet.appendRow([
              data.timestamp || Utilities.formatDate(new Date(), "Asia/Taipei", "yyyy/MM/dd HH:mm:ss"),
              data.userName || "命主",
              data.gender || "-",
              data.solarBirthDate || "-",
              data.birthTime || "-",
              data.isUnknownHour || "-",
              data.lunarBirthDate || "-",
              data.baZi || "-",
              data.elementBureau || "-",
              data.lifeMaster || "-",
              data.bodyMaster || "-",
              data.platform || "App"
            ]);
            
            return ContentService.createTextOutput(JSON.stringify({ status: "success", message: "排盤紀錄已成功寫入 Google Sheet" }))
              .setMimeType(ContentService.MimeType.JSON);
          } catch (err) {
            return ContentService.createTextOutput(JSON.stringify({ status: "error", message: err.toString() }))
              .setMimeType(ContentService.MimeType.JSON);
          }
        }

        function doGet(e) {
          try {
            var sheet = getTargetSheet();
            var ss = sheet.getParent();
            return ContentService.createTextOutput(
              "✅ 小鹿兒 Google Sheet 雲端接收端運作正常！\\n\\n" +
              "📊 綁定試算表：" + ss.getName() + "\\n" +
              "📄 寫入工作表：" + sheet.getName() + "\\n" +
              "🔢 目前已有筆數：" + (sheet.getLastRow() > 0 ? sheet.getLastRow() - 1 : 0) + " 筆\\n" +
              "🕒 系統時間：" + Utilities.formatDate(new Date(), "Asia/Taipei", "yyyy/MM/dd HH:mm:ss")
            );
          } catch (err) {
            return ContentService.createTextOutput("⚠️ 警告：接收端腳本尚未正確綁定試算表！\\n原因：" + err.toString());
          }
        }
        """
        UIPasteboard.general.string = script
        isCodeCopied = true
        HapticManager.triggerSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isCodeCopied = false
        }
    }
}

private struct StepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(number + ".")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(GhibliTheme.magicBrass)
            Text(text)
                .font(GhibliTheme.bodyFont(size: 12))
                .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                .lineSpacing(2)
        }
    }
}
