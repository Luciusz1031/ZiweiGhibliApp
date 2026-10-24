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
        let currentUrl = webhookUrl
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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Google Sheet 同步失敗：\(error.localizedDescription)")
                DispatchQueue.main.async { completion?(false, error.localizedDescription) }
                return
            }
            if let httpRes = response as? HTTPURLResponse, (200...399).contains(httpRes.statusCode) {
                print("Google Sheet 同步成功！")
                DispatchQueue.main.async { completion?(true, nil) }
            } else {
                DispatchQueue.main.async { completion?(true, nil) }
            }
        }.resume()
    }
    
    /// 測試連線
    public func testConnection(url: String, completion: @escaping (Bool, String) -> Void) {
        guard let targetUrl = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            completion(false, "網址格式不正確")
            return
        }
        
        let testPayload: [String: Any] = [
            "timestamp": "測試連線",
            "userName": "連線測試",
            "gender": "-",
            "solarBirthDate": "-",
            "birthTime": "-",
            "isUnknownHour": "-",
            "lunarBirthDate": "測試成功",
            "baZi": "-",
            "elementBureau": "-",
            "lifeMaster": "-",
            "bodyMaster": "-",
            "platform": "測試訊號"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: testPayload) else {
            completion(false, "資料封裝失敗")
            return
        }
        
        var request = URLRequest(url: targetUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else if let httpRes = response as? HTTPURLResponse, (200...399).contains(httpRes.statusCode) {
                    completion(true, "連線成功！已傳送一筆測試資料至試算表。")
                } else {
                    completion(true, "已送出請求，請檢查試算表是否已收到資料。")
                }
            }
        }.resume()
    }
}
