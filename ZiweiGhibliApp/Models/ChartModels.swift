import Foundation

// MARK: - 單個星曜模型
public struct StarItem: Identifiable, Codable, Hashable {
    public var id: String { name }
    public let name: String
    public let category: StarCategory
    public var brightness: StarBrightness?
    public var natalTransformation: TransformationType?   // 本命生年四化
    public var decadeTransformation: TransformationType?  // 大限四化
    public var annualTransformation: TransformationType?  // 流年四化
    public let element: String
    
    public init(name: String,
                category: StarCategory,
                brightness: StarBrightness? = nil,
                natalTransformation: TransformationType? = nil,
                decadeTransformation: TransformationType? = nil,
                annualTransformation: TransformationType? = nil,
                element: String = "") {
        self.name = name
        self.category = category
        self.brightness = brightness
        self.natalTransformation = natalTransformation
        self.decadeTransformation = decadeTransformation
        self.annualTransformation = annualTransformation
        self.element = element
    }
}

// MARK: - 單個宮位模型 (共12個宮位，分佈在十二地支)
public struct PalaceData: Identifiable, Codable {
    public var id: Int { earthlyBranch.rawValue }
    public let earthlyBranch: EarthlyBranch    // 宮位地支 (子..亥)
    public let heavenlyStem: HeavenlyStem      // 宮位天干
    public var type: PalaceType                // 宮位名 (命宮、夫妻宮...)
    public var isLifePalace: Bool              // 是否為命宮
    public var isBodyPalace: Bool              // 是否為身宮
    public var stars: [StarItem]               // 駐留星曜
    
    public var decadeStartAge: Int             // 大限起歲 (如 24)
    public var decadeEndAge: Int               // 大限止歲 (如 33)
    
    // 動態標記 (用於大限流年時光輪盤)
    public var isCurrentDecade: Bool = false
    public var isCurrentAnnual: Bool = false
    public var dynamicAnnualName: String? = nil // 當前流年宮位名 (如流年命宮、流年財帛)
    
    public var majorStars: [StarItem] {
        stars.filter { $0.category == .major }
    }
    
    public var luckyStars: [StarItem] {
        stars.filter { $0.category == .lucky }
    }
    
    public var fierceStars: [StarItem] {
        stars.filter { $0.category == .fierce }
    }
    
    public var auxiliaryStars: [StarItem] {
        stars.filter { $0.category == .auxiliary || $0.category == .minor }
    }
    
    public init(earthlyBranch: EarthlyBranch,
                heavenlyStem: HeavenlyStem,
                type: PalaceType,
                isLifePalace: Bool = false,
                isBodyPalace: Bool = false,
                stars: [StarItem] = [],
                decadeStartAge: Int = 0,
                decadeEndAge: Int = 0) {
        self.earthlyBranch = earthlyBranch
        self.heavenlyStem = heavenlyStem
        self.type = type
        self.isLifePalace = isLifePalace
        self.isBodyPalace = isBodyPalace
        self.stars = stars
        self.decadeStartAge = decadeStartAge
        self.decadeEndAge = decadeEndAge
    }
}

// MARK: - 倪海廈《天紀》命盤格局定義
public struct TianjiPattern: Identifiable, Codable, Hashable {
    public var id: String { name }
    public let name: String            // 格局名稱 (如: 紫府同宮格, 日月並明格)
    public let isAuspicious: Bool      // 是否為吉格
    public let description: String     // 格局解說
    public let tianjiComment: String   // 倪海廈《天紀》原著講義斷語
    public let classicalPoem: String   // 古籍全書詩賦
    
    public init(name: String, isAuspicious: Bool, description: String, tianjiComment: String, classicalPoem: String = "") {
        self.name = name
        self.isAuspicious = isAuspicious
        self.description = description
        self.tianjiComment = tianjiComment
        self.classicalPoem = classicalPoem
    }
}

// MARK: - 完整紫微斗數命盤
public struct AstrolabeChart: Identifiable, Codable {
    public var id: UUID = UUID()
    public let solarDate: Date
    public let city: CityLocation
    public let gender: Gender
    public let lunarInfo: LunarDateInfo
    public let solarCorrection: SolarCorrectionResult
    
    public let elementBureau: ElementBureau    // 五行局 (如：木三局)
    public let lifePalaceBranch: EarthlyBranch // 命宮地支
    public let bodyPalaceBranch: EarthlyBranch // 身宮地支
    public let lifeMasterStar: String          // 命主
    public let bodyMasterStar: String          // 身主
    
    public var palaces: [PalaceData]           // 12 宮位數據 (依地支順序 0..11)
    public var patterns: [TianjiPattern]       // 檢測出的倪師天紀格局
    public let config: SchoolConfig            // 當前採用的流派設定
    
    // 依地支取得宮位便捷方法
    public func palace(at branch: EarthlyBranch) -> PalaceData {
        return palaces.first { $0.earthlyBranch == branch } ?? palaces[branch.rawValue]
    }
}
