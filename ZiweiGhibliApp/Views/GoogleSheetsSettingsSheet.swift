import SwiftUI

public struct GoogleSheetsSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var webhookUrl: String = GoogleSheetsSyncManager.shared.webhookUrl
    @State private var isEnabled: Bool = GoogleSheetsSyncManager.shared.isEnabled
    @State private var testStatusMessage: String?
    @State private var isTesting: Bool = false
    @State private var isSuccess: Bool = false
    
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
                            Text("Google Apps Script 網頁應用程式網址 (Web App URL)")
                                .font(GhibliTheme.bodyFont(size: 12))
                                .foregroundColor(GhibliTheme.forestMoss)
                                .fontWeight(.bold)
                            
                            TextField("https://script.google.com/macros/s/.../exec", text: $webhookUrl)
                                .font(.system(size: 13, design: .monospaced))
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
                                    Text(isTesting ? "連線中..." : "發送測試訊號")
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
                                .foregroundColor(isSuccess ? GhibliTheme.forestMoss : GhibliTheme.tabooRed)
                                .padding(8)
                                .background(isSuccess ? GhibliTheme.forestMoss.opacity(0.1) : GhibliTheme.tabooRed.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // 簡易設定指南
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📖 3 步驟快速取得網址：")
                                .font(GhibliTheme.titleFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                StepRow(number: "1", text: "新建一個 Google 試算表，點選「擴充功能」>「Apps Script」。")
                                StepRow(number: "2", text: "貼上為您準備的後端接收代碼並儲存。")
                                StepRow(number: "3", text: "點擊右上角「部署」>「新建部署」> 選擇「網頁應用程式」，將存取權限設為「所有人」，將取得的網址貼在上方即可！")
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
