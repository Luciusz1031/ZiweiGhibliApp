import Foundation

public final class GoogleSheetsSyncManager {
    public static let shared = GoogleSheetsSyncManager()
    
    // 正式部署的 Google Apps Script Web App 網址
    public static let defaultWebhookUrl = "https://script.google.com/macros/s/AKfycbzUZm93oNx74FAUj-5ZkUI8pNLXh4AnY_h_UV6VlgzWmWw4gC4chrYGQajC8aePgtM5/exec"
    
    private let userDefaultsKey = "XiaoLuer_GoogleSheet_WebhookUrl"
    private let queueKey = "XiaoLuer_GoogleSheet_OfflineQueue"
    
    public var webhookUrl: String {
        get {
            let saved = UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
            return saved.isEmpty ? Self.defaultWebhookUrl : saved
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: userDefaultsKey)
        }
    }
    
    private init() {}
    
    /// 上傳排盤紀錄至 Google Sheet（無網路時自動暫存於本機離線隊列）
    public func syncChart(
        chart: AstrolabeChart,
        solarBirthDate: Date,
        isUnknownHour: Bool,
        completion: ((Bool, String?) -> Void)? = nil
    ) {
        let currentUrl = webhookUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let targetUrl = URL(string: currentUrl.isEmpty ? Self.defaultWebhookUrl : currentUrl) else {
            completion?(false, "網址解析失敗")
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
        request.timeoutInterval = 12
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            let isHttpSuccess = (response as? HTTPURLResponse).map { (200...399).contains($0.statusCode) } ?? false
            
            if error != nil || !isHttpSuccess {
                // 網路失敗或離線狀態：自動寫入離線隊列
                self.enqueueOffline(payload: payload)
                DispatchQueue.main.async { completion?(false, "離線暫存成功") }
                return
            }
            
            // 上傳成功，順便觸發檢查離線隊列補傳
            self.flushOfflineQueue()
            DispatchQueue.main.async { completion?(true, nil) }
        }.resume()
    }
    
    // MARK: - 離線暫存與自動重試機制
    
    private func getOfflineQueue() -> [[String: Any]] {
        guard let data = UserDefaults.standard.data(forKey: queueKey),
              let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return list
    }
    
    private func saveOfflineQueue(_ queue: [[String: Any]]) {
        if let data = try? JSONSerialization.data(withJSONObject: queue) {
            UserDefaults.standard.set(data, forKey: queueKey)
        }
    }
    
    private func enqueueOffline(payload: [String: Any]) {
        var queue = getOfflineQueue()
        queue.append(payload)
        saveOfflineQueue(queue)
    }
    
    /// 當有網路時，自動補傳所有離線時暫存的排盤資料
    public func flushOfflineQueue() {
        guard let targetUrl = URL(string: webhookUrl) else { return }
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            let queue = self.getOfflineQueue()
            guard !queue.isEmpty else { return }
            
            var successfullySentIndices = Set<Int>()
            let group = DispatchGroup()
            
            for (index, payload) in queue.enumerated() {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                    successfullySentIndices.insert(index)
                    continue
                }
                
                var request = URLRequest(url: targetUrl)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                request.timeoutInterval = 10
                
                group.enter()
                let task = URLSession.shared.dataTask(with: request) { _, response, error in
                    if error == nil, let httpRes = response as? HTTPURLResponse, (200...399).contains(httpRes.statusCode) {
                        successfullySentIndices.insert(index)
                    }
                    group.leave()
                }
                task.resume()
                group.wait()
            }
            
            let updated = queue.enumerated().filter { !successfullySentIndices.contains($0.offset) }.map { $0.element }
            self.saveOfflineQueue(updated)
        }
    }
}
