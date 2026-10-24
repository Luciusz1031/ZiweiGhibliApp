import Foundation

public struct LunarDateInfo: Codable {
    public let lunarYear: Int
    public let lunarMonth: Int
    public let lunarDay: Int
    public let isLeapMonth: Bool
    
    public let yearStem: HeavenlyStem
    public let yearBranch: EarthlyBranch
    
    public let monthStem: HeavenlyStem
    public let monthBranch: EarthlyBranch
    
    public let dayStem: HeavenlyStem
    public let dayBranch: EarthlyBranch
    
    public let hourStem: HeavenlyStem
    public let hourBranch: EarthlyBranch
    
    public var lunarDateString: String {
        let leapStr = isLeapMonth ? "閏" : ""
        let monthNames = ["", "正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "臘"]
        let dayNames = ["", "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        let mName = (lunarMonth >= 1 && lunarMonth <= 12) ? monthNames[lunarMonth] : "\(lunarMonth)"
        let dName = (lunarDay >= 1 && lunarDay <= 30) ? dayNames[lunarDay] : "\(lunarDay)"
        return "農曆 \(yearStem.name)\(yearBranch.name)年 \(leapStr)\(mName)月\(dName)日 \(hourStem.name)\(hourBranch.name)時"
    }
    
    public var baZiString: String {
        return "\(yearStem.name)\(yearBranch.name)年  \(monthStem.name)\(monthBranch.name)月  \(dayStem.name)\(dayBranch.name)日  \(hourStem.name)\(hourBranch.name)時"
    }
}

public class ChineseCalendarHelper {
    private static let chineseCalendar = Calendar(identifier: .chinese)
    private static let gregorianCalendar = Calendar(identifier: .gregorian)
    
    /// 將西曆/真太陽時日期轉為農曆資訊與四柱八字
    public static func getLunarDateInfo(from date: Date, hourBranch: EarthlyBranch, isLateZi: Bool, dayChangeRule: DayChangeRule) -> LunarDateInfo {
        // 如果是夜子時 (23:00-00:00) 且選擇了倪海廈天紀「子初換日」，則日柱需計入下一日
        var targetDate = date
        if isLateZi && dayChangeRule == .tianJiMidnight23 {
            targetDate = date.addingTimeInterval(3600) // 跨過零點進次日
        }
        
        let components = chineseCalendar.dateComponents([.year, .month, .day, .isLeapMonth], from: targetDate)
        
        let lunarMonth = components.month ?? 1
        let lunarDay = components.day ?? 1
        let isLeap = components.isLeapMonth ?? false
        
        // 年干支：以農曆年份為準
        // 西元紀年算干支 (西元 4 年為甲子年)
        let gregYear = gregorianCalendar.component(.year, from: targetDate)
        // 若農曆月份為11或12月且西曆為年初，可能為前一年
        let gregMonth = gregorianCalendar.component(.month, from: targetDate)
        var actualYear = gregYear
        if gregMonth == 1 && lunarMonth >= 11 {
            actualYear = gregYear - 1
        }
        
        let yearStemIndex = (actualYear - 4) % 10
        let normalizedYearStem = (yearStemIndex + 10) % 10
        let yearStem = HeavenlyStem(rawValue: normalizedYearStem)!
        
        let yearBranchIndex = (actualYear - 4) % 12
        let normalizedYearBranch = (yearBranchIndex + 12) % 12
        let yearBranch = EarthlyBranch(rawValue: normalizedYearBranch)!
        
        // 五虎遁月起月干 (以年干起正月丙/戊/庚/壬/甲)
        // 寅月為正月 (index 2)
        let tigerStartStemMap: [HeavenlyStem: HeavenlyStem] = [
            .jia: .bing, .ji: .bing,
            .yi: .wu,   .geng: .wu,
            .bing: .geng, .xin: .geng,
            .ding: .ren,  .ren: .ren,
            .wu: .jia,   .gui: .jia
        ]
        let firstMonthStem = tigerStartStemMap[yearStem] ?? .bing
        let monthStemIndex = (firstMonthStem.rawValue + (lunarMonth - 1)) % 10
        let monthStem = HeavenlyStem(rawValue: monthStemIndex)!
        
        // 月支 (正月為寅2，二月為卯3...)
        let monthBranchIndex = (EarthlyBranch.yin.rawValue + (lunarMonth - 1)) % 12
        let monthBranch = EarthlyBranch(rawValue: monthBranchIndex)!
        
        // 日干支：利用格里曆天數計算 (以 1900-01-31 為基準日 甲辰日，或公式法)
        let (dayStem, dayBranch) = calculateDayStemBranch(for: targetDate)
        
        // 五鼠遁日起時干 (以日干起子時甲/丙/戊/庚/壬)
        let ratStartStemMap: [HeavenlyStem: HeavenlyStem] = [
            .jia: .jia, .ji: .jia,
            .yi: .bing, .geng: .bing,
            .bing: .wu, .xin: .wu,
            .ding: .geng, .ren: .geng,
            .wu: .ren,  .gui: .ren
        ]
        let firstHourStem = ratStartStemMap[dayStem] ?? .jia
        let hourStemIndex = (firstHourStem.rawValue + hourBranch.rawValue) % 10
        let hourStem = HeavenlyStem(rawValue: hourStemIndex)!
        
        return LunarDateInfo(
            lunarYear: actualYear,
            lunarMonth: lunarMonth,
            lunarDay: lunarDay,
            isLeapMonth: isLeap,
            yearStem: yearStem,
            yearBranch: yearBranch,
            monthStem: monthStem,
            monthBranch: monthBranch,
            dayStem: dayStem,
            dayBranch: dayBranch,
            hourStem: hourStem,
            hourBranch: hourBranch
        )
    }
    
    /// 計算日干支演算法 (基於儒略日或公曆基準日計算)
    public static func calculateDayStemBranch(for date: Date) -> (HeavenlyStem, EarthlyBranch) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        // 基準日：2000年1月1日 為 戊午日 (幹5=戊, 支6=午)
        var baseComponents = DateComponents()
        baseComponents.year = 2000
        baseComponents.month = 1
        baseComponents.day = 1
        baseComponents.hour = 12
        let baseDate = cal.date(from: baseComponents)!
        
        let diffDays = cal.dateComponents([.day], from: baseDate, to: date).day ?? 0
        
        // 2000-01-01: 戊 = 4, 午 = 6
        let stemIndex = (4 + diffDays) % 10
        let normalizedStem = (stemIndex + 10) % 10
        
        let branchIndex = (6 + diffDays) % 12
        let normalizedBranch = (branchIndex + 12) % 12
        
        return (HeavenlyStem(rawValue: normalizedStem)!, EarthlyBranch(rawValue: normalizedBranch)!)
    }
}
