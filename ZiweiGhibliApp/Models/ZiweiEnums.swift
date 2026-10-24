import Foundation

// MARK: - 天干 (Heavenly Stems)
public enum HeavenlyStem: Int, CaseIterable, Codable, Identifiable {
    case jia = 0, yi, bing, ding, wu, ji, geng, xin, ren, gui
    
    public var id: Int { rawValue }
    
    public var name: String {
        switch self {
        case .jia: return "甲"
        case .yi: return "乙"
        case .bing: return "丙"
        case .ding: return "丁"
        case .wu: return "戊"
        case .ji: return "己"
        case .geng: return "庚"
        case .xin: return "辛"
        case .ren: return "壬"
        case .gui: return "癸"
        }
    }
    
    /// 五行屬性
    public var element: String {
        switch self {
        case .jia, .yi: return "木"
        case .bing, .ding: return "火"
        case .wu, .ji: return "土"
        case .geng, .xin: return "金"
        case .ren, .gui: return "水"
        }
    }
    
    /// 陰陽屬性 (奇數為陽，偶數為陰：甲丙戊庚壬為陽，乙丁己辛癸為陰)
    public var isYang: Bool {
        return rawValue % 2 == 0
    }
}

// MARK: - 地支 (Earthly Branches)
public enum EarthlyBranch: Int, CaseIterable, Codable, Identifiable {
    case zi = 0, chou, yin, mao, chen, si, wu, wei, shen, you, xu, hai
    
    public var id: Int { rawValue }
    
    public var name: String {
        switch self {
        case .zi: return "子"
        case .chou: return "丑"
        case .yin: return "寅"
        case .mao: return "卯"
        case .chen: return "辰"
        case .si: return "巳"
        case .wu: return "午"
        case .wei: return "未"
        case .shen: return "申"
        case .you: return "酉"
        case .xu: return "戌"
        case .hai: return "亥"
        }
    }
    
    /// 生肖
    public var zodiac: String {
        switch self {
        case .zi: return "鼠"
        case .chou: return "牛"
        case .yin: return "虎"
        case .mao: return "兔"
        case .chen: return "龍"
        case .si: return "蛇"
        case .wu: return "馬"
        case .wei: return "羊"
        case .shen: return "猴"
        case .you: return "雞"
        case .xu: return "狗"
        case .hai: return "豬"
        }
    }
    
    /// 對應時辰區間 (平時)
    public var timeRangeText: String {
        switch self {
        case .zi: return "23:00 - 01:00"
        case .chou: return "01:00 - 03:00"
        case .yin: return "03:00 - 05:00"
        case .mao: return "05:00 - 07:00"
        case .chen: return "07:00 - 09:00"
        case .si: return "09:00 - 11:00"
        case .wu: return "11:00 - 13:00"
        case .wei: return "13:00 - 15:00"
        case .shen: return "15:00 - 17:00"
        case .you: return "17:00 - 19:00"
        case .xu: return "19:00 - 21:00"
        case .hai: return "21:00 - 23:00"
        }
    }
}

// MARK: - 十二宮名 (Twelve Palaces)
public enum PalaceType: Int, CaseIterable, Codable {
    case life = 0       // 命宮
    case siblings       // 兄弟宮
    case marriage       // 夫妻宮
    case children       // 子女宮
    case wealth         // 財帛宮
    case health         // 疾厄宮
    case travel         // 遷移宮
    case friends        // 交友宮 (僕役)
    case career         // 官祿宮 (事業)
    case property       // 田宅宮
    case happiness      // 福德宮
    case parents        // 父母宮
    
    public var name: String {
        switch self {
        case .life: return "命宮"
        case .siblings: return "兄弟"
        case .marriage: return "夫妻"
        case .children: return "子女"
        case .wealth: return "財帛"
        case .health: return "疾厄"
        case .travel: return "遷移"
        case .friends: return "交友"
        case .career: return "官祿"
        case .property: return "田宅"
        case .happiness: return "福德"
        case .parents: return "父母"
        }
    }
    
    /// 宮位別稱（如官祿即事業，交友即僕役）
    public var altName: String {
        switch self {
        case .friends: return "僕役"
        case .career: return "事業"
        default: return name
        }
    }
}

// MARK: - 五行局 (Five Elements Bureau)
public enum ElementBureau: Int, CaseIterable, Codable {
    case water2 = 2 // 水二局
    case wood3  = 3 // 木三局
    case metal4 = 4 // 金四局
    case earth5 = 5 // 土五局
    case fire6  = 6 // 火六局
    
    public var number: Int { rawValue }
    
    public var name: String {
        switch self {
        case .water2: return "水二局"
        case .wood3: return "木三局"
        case .metal4: return "金四局"
        case .earth5: return "土五局"
        case .fire6: return "火六局"
        }
    }
}

// MARK: - 四化 (Four Transformations)
public enum TransformationType: String, CaseIterable, Codable {
    case lu = "祿"    // 化祿
    case quan = "權"  // 化權
    case ke = "科"    // 化科
    case ji = "忌"    // 化忌
    
    public var fullName: String {
        return "化" + rawValue
    }
}

// MARK: - 星曜廟旺利陷 (Star Brightness)
public enum StarBrightness: String, CaseIterable, Codable {
    case miao = "廟"   // 最吉、光芒萬丈
    case wang = "旺"   // 次吉
    case de = "得"     // 得地
    case li = "利"     // 利益
    case ping = "平"   // 平和
    case bu = "不"     // 不得地
    case xian = "陷"   // 落陷、最暗淡
}

// MARK: - 星曜類別 (Star Category)
public enum StarCategory: String, Codable {
    case major        // 十四主星
    case lucky        // 六吉星
    case fierce       // 六煞星
    case transformation // 四化
    case auxiliary    // 祿存、天馬、生年干支雜曜
    case minor        // 小星、神煞
}

// MARK: - 性別與陰陽
public enum Gender: String, CaseIterable, Codable {
    case male = "乾造 (男)"
    case female = "坤造 (女)"
    
    public var isMale: Bool {
        return self == .male
    }
}
