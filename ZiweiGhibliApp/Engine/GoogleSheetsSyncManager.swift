import Foundation

public final class GoogleSheetsSyncManager {
    public static let shared = GoogleSheetsSyncManager()
    
    private let userDefaultsKey = "XiaoLuer_GoogleSheet_WebhookUrl"
    private let enabledKey = "XiaoLuer_GoogleSheet_Enabled"
    
    // 預設可留空，或填入使用者部署的 Google Apps Script 網址
    public var webhookUrl: String {
        get {
            UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: userDefaultsKey)
        }
    }
    
    public var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: enabledKey) == nil {
                return true // 預設開啟（有填網址時才發送）
            }
            return UserDefaults.standard.bool(forKey: enabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledKey)
        }
    }
    
    private init() {}
    
    /// 上傳排盤紀錄至 Google Sheet
    public func syncChart(
        chart: AstrolabeChart,
        solarBirthDate: Date,
        isUnknownHour: Bool,
        completion: ((Bool, String?) -> Void)? = nil
    ) {
        let currentUrl = webhookUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isEnabled, !currentUrl.isEmpty, let targetUrl = URL(string: currentUrl) else {
            completion?(false, "尚未設定 Google Sheet 網址或已停用")
            return
        }
        
        let now = Date()
        let tf = DateFormatter()
        tf.locale = Locale(identifier: "zh_Hant_TW")
        tf.timeZone = TimeZone(identifier: "Asia/Taipei")
        tf.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let timestampStr = tf.string(from: now)
        
        let birthDf = DateFormatter()
        birthDf.locale = Locale(identifier: "zh_Hant_TW")
        birthDf.dateFormat = "yyyy年MM月dd日"
        let solarDateStr = birthDf.string(from: solarBirthDate)
        
        let timeDf = DateFormatter()
        timeDf.locale = Locale(identifier: "zh_Hant_TW")
        timeDf.dateFormat = "HH:mm"
        let birthTimeStr = isUnknownHour ? "未知 (以子時起盤)" : timeDf.string(from: solarBirthDate)
        
        let payload: [String: Any] = [
            "timestamp": timestampStr,
            "userName": chart.userName,
            "gender": chart.gender.rawValue,
            "solarBirthDate": solarDateStr,
            "birthTime": birthTimeStr,
            "isUnknownHour": isUnknownHour ? "是 (以子時起盤)" : "否",
            "lunarBirthDate": chart.lunarInfo.lunarDateString,
            "baZi": chart.lunarInfo.baZiString,
            "elementBureau": chart.elementBureau.name,
            "lifeMaster": chart.lifeMasterStar,
            "bodyMaster": chart.bodyMasterStar,
            "platform": "iOS (小鹿兒算命)"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion?(false, "資料封裝失敗")
            return
        }
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Google Sheet 同步失敗：\(error.localizedDescription)")
                DispatchQueue.main.async { completion?(false, error.localizedDescription) }
                return
            }
            let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            if body.contains("accounts.google.com") || body.contains("ServiceLogin") {
                print("Google Sheet 權限錯誤：Apps Script 需設為所有人存取")
                DispatchQueue.main.async { completion?(false, "權限設定錯誤：Apps Script 部署時「誰可以存取」未設為「所有人 (Anyone)」") }
            } else if body.contains("\"status\":\"error\"") {
                print("Google Sheet 寫入錯誤：\(body)")
                DispatchQueue.main.async { completion?(false, "試算表寫入失敗：\(body)") }
            } else if let httpRes = response as? HTTPURLResponse, (200...399).contains(httpRes.statusCode) {
                print("Google Sheet 同步成功！")
                DispatchQueue.main.async { completion?(true, nil) }
            } else {
                DispatchQueue.main.async { completion?(false, "伺服器未正常回應") }
            }
        }.resume()
    }
    
    /// 測試連線
    public func testConnection(url: String, completion: @escaping (Bool, String) -> Void) {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            completion(false, "網址不得為空")
            return
        }
        if trimmed.contains("docs.google.com/spreadsheets") {
            completion(false, "⚠️ 您輸入的是 Google 試算表頁面網址，請依照教學貼上 Apps Script 部署後的「網頁應用程式網址 (Web App URL)」(結尾應為 /exec)！")
            return
        }
        if trimmed.hasSuffix("/edit") || trimmed.contains("script.google.com/home/projects") {
            completion(false, "⚠️ 您輸入的是 Apps Script 編輯器網址，請點選右上角「部署」>「新增部署作業」複製網頁應用程式網址！")
            return
        }
        if trimmed.hasSuffix("/dev") {
            completion(false, "⚠️ 您輸入的是測試開發網址 (/dev)，此網址要求登入 Google 帳號。請在部署時建立正式網頁應用程式，取得 /exec 結尾的網址！")
            return
        }
        guard let targetUrl = URL(string: trimmed), targetUrl.scheme == "https" else {
            completion(false, "網址格式不正確，必須以 https:// 開頭")
            return
        }
        
        let testPayload: [String: Any] = [
            "timestamp": "測試連線",
            "userName": "小鹿連線測試",
            "gender": "-",
            "solarBirthDate": "-",
            "birthTime": "-",
            "isUnknownHour": "-",
            "lunarBirthDate": "測試成功",
            "baZi": "-",
            "elementBureau": "-",
            "lifeMaster": "-",
            "bodyMaster": "-",
            "platform": "iOS 測試訊號"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: testPayload) else {
            completion(false, "資料封裝失敗")
            return
        }
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 12
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "連線失敗：\(error.localizedDescription)")
                    return
                }
                guard let httpRes = response as? HTTPURLResponse else {
                    completion(false, "未收到伺服器回應")
                    return
                }
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                if body.contains("accounts.google.com") || body.contains("ServiceLogin") {
                    completion(false, "❌ 權限設定錯誤：Apps Script 部署時「誰可以存取 (Who has access)」未設為「所有人 (Anyone)」，請至 Apps Script 重新部署！")
                } else if body.contains("\"status\":\"error\"") {
                    completion(false, "❌ 試算表寫入失敗：\(body)")
                } else if (200...399).contains(httpRes.statusCode) {
                    completion(true, "✅ 連線成功！已傳送一筆測試資料至試算表，請查看試算表是否出現「小鹿連線測試」一列。")
                } else {
                    completion(false, "❌ 伺服器回應錯誤碼 \(httpRes.statusCode)，請確認 Apps Script 部署設定。")
                }
            }
        }.resume()
    }
}
