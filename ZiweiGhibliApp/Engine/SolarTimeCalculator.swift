import Foundation

public struct SolarCorrectionResult: Codable {
    public let originalDate: Date
    public let trueSolarDate: Date
    public let longitudeOffsetMinutes: Double
    public let equationOfTimeMinutes: Double
    public let totalOffsetMinutes: Double
    public let hourBranch: EarthlyBranch
    public let isLateZi: Bool // 是否為夜子時 (23:00 - 00:00)
    public let isEarlyZi: Bool // 是否為早子時 (00:00 - 01:00)
    
    public var summaryText: String {
        let sign = totalOffsetMinutes >= 0 ? "+" : ""
        return String(format: "真太陽時偏差: %@%.1f分 (經度%@%.1f分, 均時差%@%.1f分)",
                      sign, totalOffsetMinutes,
                      longitudeOffsetMinutes >= 0 ? "+" : "", longitudeOffsetMinutes,
                      equationOfTimeMinutes >= 0 ? "+" : "", equationOfTimeMinutes)
    }
}

public class SolarTimeCalculator {
    
    /// 計算天文均時差 (Equation of Time, EOT)，單位：分鐘
    /// 依據 NOAA / Spencer 天文經驗多項式公式
    public static func calculateEquationOfTime(for date: Date, calendar: Calendar = Calendar.current) -> Double {
        let dayOfYear = Double(calendar.ordinality(of: .day, in: .year, for: date) ?? 1)
        // 日角 (Fractional year in radians)
        let gamma = (2.0 * Double.pi / 365.0) * (dayOfYear - 1.0)
        
        // EOT 經驗傅立葉展開式 (精確至 0.1 分鐘以內)
        let eot = 229.18 * (
            0.000075 +
            0.001868 * cos(gamma) -
            0.032077 * sin(gamma) -
            0.014615 * cos(2.0 * gamma) -
            0.040849 * sin(2.0 * gamma)
        )
        return eot
    }
    
    /// 計算真太陽時及時辰地支
    /// - Parameters:
    ///   - date: 鐘錶平太陽時
    ///   - city: 出生地點
    ///   - adjustDST: 是否在歷史夏令時生效時扣除1小時夏令時
    public static func calculateTrueSolarTime(for date: Date, city: CityLocation, adjustDST: Bool = true) -> SolarCorrectionResult {
        var baseDate = date
        var calendar = Calendar(identifier: .gregorian)
        if let tz = TimeZone(identifier: city.timeZoneIdentifier) {
            calendar.timeZone = tz
        }
        
        // 1. 夏令時扣除檢測 (如 1986-1991 中國大陸夏令時、1974-1979 台灣夏令時)
        if adjustDST && isDaylightSavingHistorical(date: baseDate, city: city, calendar: calendar) {
            baseDate = baseDate.addingTimeInterval(-3600) // 扣除1小時平太陽時
        }
        
        // 2. 經度時差：每偏東1度快4分鐘，偏西1度慢4分鐘
        let lonDiff = city.longitude - city.standardLongitude
        let lonOffsetMinutes = lonDiff * 4.0
        
        // 3. 均時差 (Equation of Time)
        let eotMinutes = calculateEquationOfTime(for: baseDate, calendar: calendar)
        
        // 總偏差 (秒)
        let totalOffsetMinutes = lonOffsetMinutes + eotMinutes
        let totalOffsetSeconds = totalOffsetMinutes * 60.0
        
        let trueSolarDate = baseDate.addingTimeInterval(totalOffsetSeconds)
        
        // 4. 解析真太陽時對應的時辰地支
        let hour = calendar.component(.hour, from: trueSolarDate)
        let _ = calendar.component(.minute, from: trueSolarDate)
        
        var isLateZi = false
        var isEarlyZi = false
        var branchIndex = 0
        
        if hour == 23 {
            // 23:00 - 24:00 (夜子時 / 晚子時)
            branchIndex = 0 // 子
            isLateZi = true
        } else if hour == 0 {
            // 00:00 - 01:00 (早子時)
            branchIndex = 0 // 子
            isEarlyZi = true
        } else {
            // 其餘時辰每兩小時換一辰 (1~2 丑, 3~4 寅, ...)
            branchIndex = ((hour + 1) / 2) % 12
        }
        
        let branch = EarthlyBranch(rawValue: branchIndex) ?? .zi
        
        return SolarCorrectionResult(
            originalDate: date,
            trueSolarDate: trueSolarDate,
            longitudeOffsetMinutes: lonOffsetMinutes,
            equationOfTimeMinutes: eotMinutes,
            totalOffsetMinutes: totalOffsetMinutes,
            hourBranch: branch,
            isLateZi: isLateZi,
            isEarlyZi: isEarlyZi
        )
    }
    
    /// 檢驗歷史夏令時（台灣與中國大陸常規歷史區間）
    private static func isDaylightSavingHistorical(date: Date, city: CityLocation, calendar: Calendar) -> Bool {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        // 台灣歷史夏令時常見年份 (1974 - 1979 夏季 7月~9月)
        if city.region == "台灣" && year >= 1974 && year <= 1979 {
            return month >= 7 && month <= 9
        }
        // 中國大陸歷史夏令時 (1986 - 1991，通常為 4月中旬至9月中旬)
        if city.region == "大陸" && year >= 1986 && year <= 1991 {
            return month >= 5 && month <= 8
        }
        return false
    }
}
