import Foundation

/// 庚干四化流派規則
public enum GengTransformationRule: String, CaseIterable, Codable, Identifiable {
    case tianJi = "天紀體系 (日武陰同 - 倪海廈推薦)"
    case zhongZhou = "中州派 (日武府同)"
    case quanShuAlt = "全書異說 (日武陰相)"
    
    public var id: String { rawValue }
    
    /// 庚干的「祿、權、科、忌」對應主星名
    public var stars: (lu: String, quan: String, ke: String, ji: String) {
        switch self {
        case .tianJi:
            return ("太陽", "武曲", "太陰", "天同")
        case .zhongZhou:
            return ("太陽", "武曲", "天府", "天同")
        case .quanShuAlt:
            return ("太陽", "武曲", "太陰", "天相")
        }
    }
}

/// 換日與子時分派規則
public enum DayChangeRule: String, CaseIterable, Codable, Identifiable {
    case tianJiMidnight23 = "子初換日 (23:00後算隔日 - 倪師《天紀》)"
    case traditionalMidnight00 = "子正換日 (00:00後算隔日 / 夜子時日不換)"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .tianJiMidnight23:
            return "凡夜間23點起即進入子時並直接換入次日天干與日柱（倪海廈先生主張天紀排盤秘法）。"
        case .traditionalMidnight00:
            return "23:00~24:00為夜子時，採用當日日干配子時時干；過00:00後方換日。"
        }
    }
}

/// 閏月排盤規則
public enum LeapMonthRule: String, CaseIterable, Codable, Identifiable {
    case halfSplit = "十五日前作本月，十六日後作下月"
    case nextMonth = "直接作下月計算"
    case currentMonth = "直接作當月計算"
    
    public var id: String { rawValue }
}

/// 流派設定集
public struct SchoolConfig: Codable {
    public var gengRule: GengTransformationRule
    public var dayChangeRule: DayChangeRule
    public var leapMonthRule: LeapMonthRule
    public var useTrueSolarTime: Bool
    public var autoAdjustDST: Bool
    
    public static let `default` = SchoolConfig(
        gengRule: .tianJi,
        dayChangeRule: .tianJiMidnight23,
        leapMonthRule: .halfSplit,
        useTrueSolarTime: true,
        autoAdjustDST: true
    )
    
    public init(gengRule: GengTransformationRule = .tianJi,
                dayChangeRule: DayChangeRule = .tianJiMidnight23,
                leapMonthRule: LeapMonthRule = .halfSplit,
                useTrueSolarTime: Bool = true,
                autoAdjustDST: Bool = true) {
        self.gengRule = gengRule
        self.dayChangeRule = dayChangeRule
        self.leapMonthRule = leapMonthRule
        self.useTrueSolarTime = useTrueSolarTime
        self.autoAdjustDST = autoAdjustDST
    }
}
