import Foundation

public class ZiweiEngine {
    
    // MARK: - 主排盤入口 (Main Chart Generation)
    public static func generateChart(
        birthDate: Date,
        city: CityLocation,
        gender: Gender,
        userName: String = "命主",
        isUnknownHour: Bool = false,
        config: SchoolConfig = .default
    ) -> AstrolabeChart {
        
        // 1. 真太陽時校準
        let solarCorrection = SolarTimeCalculator.calculateTrueSolarTime(
            for: birthDate,
            city: city,
            adjustDST: config.autoAdjustDST
        )
        
        let targetDate = config.useTrueSolarTime ? solarCorrection.trueSolarDate : birthDate
        let hourBranch = solarCorrection.hourBranch
        
        // 2. 轉換為農曆干支資訊
        let lunarInfo = ChineseCalendarHelper.getLunarDateInfo(
            from: targetDate,
            hourBranch: hourBranch,
            isLateZi: solarCorrection.isLateZi,
            dayChangeRule: config.dayChangeRule
        )
        
        // 3. 處理閏月規則 (如果為閏月)
        var effectiveMonth = lunarInfo.lunarMonth
        if lunarInfo.isLeapMonth {
            switch config.leapMonthRule {
            case .halfSplit:
                if lunarInfo.lunarDay > 15 {
                    effectiveMonth = (effectiveMonth % 12) + 1
                }
            case .nextMonth:
                effectiveMonth = (effectiveMonth % 12) + 1
            case .currentMonth:
                break
            }
        }
        
        // 4. 定命宮與身宮
        // 寅宮(2)起正月順數至生月，再由生月宮位逆數至生時即為命宮；順數至生時為身宮
        let monthBranchIndex = (EarthlyBranch.yin.rawValue + effectiveMonth - 1) % 12
        let lifeBranchIndex = (monthBranchIndex - hourBranch.rawValue + 12) % 12
        let bodyBranchIndex = (monthBranchIndex + hourBranch.rawValue) % 12
        
        let lifePalaceBranch = EarthlyBranch(rawValue: lifeBranchIndex)!
        let bodyPalaceBranch = EarthlyBranch(rawValue: bodyBranchIndex)!
        
        // 5. 安十二宮天干 (五虎遁月法)
        let branchStems = calculatePalaceStems(yearStem: lunarInfo.yearStem)
        let lifePalaceStem = branchStems[lifeBranchIndex]
        
        // 6. 定五行局
        let elementBureau = calculateElementBureau(lifeStem: lifePalaceStem, lifeBranch: lifePalaceBranch)
        
        // 7. 安十二宮宮名
        var palaces: [PalaceData] = []
        for branch in EarthlyBranch.allCases {
            let offset = (lifeBranchIndex - branch.rawValue + 12) % 12
            let palaceType = PalaceType(rawValue: offset)!
            let stem = branchStems[branch.rawValue]
            
            let isLife = (branch == lifePalaceBranch)
            let isBody = (branch == bodyPalaceBranch)
            
            let palace = PalaceData(
                earthlyBranch: branch,
                heavenlyStem: stem,
                type: palaceType,
                isLifePalace: isLife,
                isBodyPalace: isBody
            )
            palaces.append(palace)
        }
        
        // 8. 起大限歲數
        // 陽男陰女順行，陰男陽女逆行
        let isYangYear = lunarInfo.yearStem.isYang
        let isClockwise = (isYangYear && gender.isMale) || (!isYangYear && !gender.isMale)
        let bureauNum = elementBureau.number
        
        for i in 0..<12 {
            let step = isClockwise ? i : (12 - i) % 12
            let targetBranchIndex = (lifeBranchIndex + step) % 12
            let startAge = bureauNum + (i * 10)
            let endAge = startAge + 9
            
            palaces[targetBranchIndex].decadeStartAge = startAge
            palaces[targetBranchIndex].decadeEndAge = endAge
        }
        
        // 9. 安十四主星
        let ziweiBranch = calculateZiweiBranch(lunarDay: lunarInfo.lunarDay, bureau: elementBureau)
        let tianfuBranch = calculateTianfuBranch(ziweiBranch: ziweiBranch)
        
        // 星曜暫存映射：地支 index -> [StarItem]
        var starsMap: [Int: [StarItem]] = [:]
        for i in 0..<12 { starsMap[i] = [] }
        
        // 紫微星系
        let ziweiStars: [(name: String, offset: Int, element: String)] = [
            ("紫微", 0, "土"),
            ("天機", -1, "木"),
            ("太陽", -3, "火"),
            ("武曲", -4, "金"),
            ("天同", -5, "水"),
            ("廉貞", -8, "火")
        ]
        for star in ziweiStars {
            let bIndex = (ziweiBranch.rawValue + star.offset + 24) % 12
            let brightness = getStarBrightness(starName: star.name, branch: EarthlyBranch(rawValue: bIndex)!)
            starsMap[bIndex]?.append(StarItem(name: star.name, category: .major, brightness: brightness, element: star.element))
        }
        
        // 天府星系
        let tianfuStars: [(name: String, offset: Int, element: String)] = [
            ("天府", 0, "土"),
            ("太陰", 1, "水"),
            ("貪狼", 2, "木"),
            ("巨門", 3, "水"),
            ("天相", 4, "水"),
            ("天梁", 5, "土"),
            ("七殺", 6, "金"),
            ("破軍", 10, "水")
        ]
        for star in tianfuStars {
            let bIndex = (tianfuBranch.rawValue + star.offset) % 12
            let brightness = getStarBrightness(starName: star.name, branch: EarthlyBranch(rawValue: bIndex)!)
            starsMap[bIndex]?.append(StarItem(name: star.name, category: .major, brightness: brightness, element: star.element))
        }
        
        // 10. 安六吉六煞與輔曜
        // 左輔 (辰宮起正月順數)、右弼 (戌宮起正月逆數)
        let zuoFuIndex = (EarthlyBranch.chen.rawValue + (effectiveMonth - 1)) % 12
        let youBiIndex = (EarthlyBranch.xu.rawValue - (effectiveMonth - 1) + 12) % 12
        starsMap[zuoFuIndex]?.append(StarItem(name: "左輔", category: .lucky, element: "土"))
        starsMap[youBiIndex]?.append(StarItem(name: "右弼", category: .lucky, element: "水"))
        
        // 文昌 (巳宮起子時逆數)、文曲 (辰宮起子時順數)
        let wenChangIndex = (EarthlyBranch.si.rawValue - hourBranch.rawValue + 12) % 12
        let wenQuIndex = (EarthlyBranch.chen.rawValue + hourBranch.rawValue) % 12
        starsMap[wenChangIndex]?.append(StarItem(name: "文昌", category: .lucky, element: "金"))
        starsMap[wenQuIndex]?.append(StarItem(name: "文曲", category: .lucky, element: "水"))
        
        // 天魁、天鉞
        let (kuiIndex, yueIndex) = calculateKuiYue(yearStem: lunarInfo.yearStem)
        starsMap[kuiIndex]?.append(StarItem(name: "天魁", category: .lucky, element: "火"))
        starsMap[yueIndex]?.append(StarItem(name: "天鉞", category: .lucky, element: "火"))
        
        // 祿存、擎羊、陀羅
        let luCunIndex = calculateLuCun(yearStem: lunarInfo.yearStem)
        let qingYangIndex = (luCunIndex + 1) % 12
        let tuoLuoIndex = (luCunIndex - 1 + 12) % 12
        starsMap[luCunIndex]?.append(StarItem(name: "祿存", category: .auxiliary, element: "土"))
        starsMap[qingYangIndex]?.append(StarItem(name: "擎羊", category: .fierce, element: "金"))
        starsMap[tuoLuoIndex]?.append(StarItem(name: "陀羅", category: .fierce, element: "金"))
        
        // 地空、地劫 (亥宮起子時)
        let diJieIndex = (EarthlyBranch.hai.rawValue + hourBranch.rawValue) % 12
        let diKongIndex = (EarthlyBranch.hai.rawValue - hourBranch.rawValue + 12) % 12
        starsMap[diKongIndex]?.append(StarItem(name: "地空", category: .fierce, element: "火"))
        starsMap[diJieIndex]?.append(StarItem(name: "地劫", category: .fierce, element: "火"))
        
        // 天馬
        let tianMaIndex = calculateTianMa(yearBranch: lunarInfo.yearBranch)
        starsMap[tianMaIndex]?.append(StarItem(name: "天馬", category: .auxiliary, element: "火"))
        
        // 11. 生年四化標註 (含倪師天紀庚干日武陰同)
        let fourTransformations = calculateFourTransformations(yearStem: lunarInfo.yearStem, gengRule: config.gengRule)
        for (bIndex, starList) in starsMap {
            var updatedList: [StarItem] = []
            for var star in starList {
                if star.name == fourTransformations.lu {
                    star.natalTransformation = .lu
                } else if star.name == fourTransformations.quan {
                    star.natalTransformation = .quan
                } else if star.name == fourTransformations.ke {
                    star.natalTransformation = .ke
                } else if star.name == fourTransformations.ji {
                    star.natalTransformation = .ji
                }
                updatedList.append(star)
            }
            starsMap[bIndex] = updatedList
        }
        
        // 將星曜裝入各宮位
        for i in 0..<12 {
            palaces[i].stars = starsMap[i] ?? []
        }
        
        // 12. 命主與身主
        let lifeMaster = calculateLifeMaster(lifeBranch: lifePalaceBranch)
        let bodyMaster = calculateBodyMaster(yearBranch: lunarInfo.yearBranch)
        
        // 13. 倪海廈《天紀》經典格局檢測
        let patterns = TianjiPatternMatcher.matchPatterns(palaces: palaces, lifeBranch: lifePalaceBranch)
        
        return AstrolabeChart(
            userName: userName,
            isUnknownHour: isUnknownHour,
            solarDate: birthDate,
            city: city,
            gender: gender,
            lunarInfo: lunarInfo,
            solarCorrection: solarCorrection,
            elementBureau: elementBureau,
            lifePalaceBranch: lifePalaceBranch,
            bodyPalaceBranch: bodyPalaceBranch,
            lifeMasterStar: lifeMaster,
            bodyMasterStar: bodyMaster,
            palaces: palaces,
            patterns: patterns,
            config: config
        )
    }
    
    // MARK: - 輔助計算方法 (Helper Functions)
    
    /// 五虎遁年起月干：決定 12 宮天干 (寅宮起算)
    private static func calculatePalaceStems(yearStem: HeavenlyStem) -> [HeavenlyStem] {
        let tigerStartStemMap: [HeavenlyStem: HeavenlyStem] = [
            .jia: .bing, .ji: .bing,
            .yi: .wu,   .geng: .wu,
            .bing: .geng, .xin: .geng,
            .ding: .ren,  .ren: .ren,
            .wu: .jia,   .gui: .jia
        ]
        let startStem = tigerStartStemMap[yearStem] ?? .bing
        var stems: [HeavenlyStem] = Array(repeating: .jia, count: 12)
        
        // 寅宮 index = 2
        for i in 0..<12 {
            let branchIndex = (EarthlyBranch.yin.rawValue + i) % 12
            let stemIndex = (startStem.rawValue + i) % 10
            stems[branchIndex] = HeavenlyStem(rawValue: stemIndex)!
        }
        return stems
    }
    
    /// 納音定五行局
    private static func calculateElementBureau(lifeStem: HeavenlyStem, lifeBranch: EarthlyBranch) -> ElementBureau {
        // 天干配數：甲乙1, 丙丁2, 戊己3, 庚辛4, 壬癸5
        let stemNum = (lifeStem.rawValue / 2) + 1
        // 地支配數：子丑午未1, 寅卯申酉2, 辰巳戌亥3
        let branchNum: Int
        switch lifeBranch {
        case .zi, .chou, .wu, .wei: branchNum = 1
        case .yin, .mao, .shen, .you: branchNum = 2
        case .chen, .si, .xu, .hai: branchNum = 3
        }
        
        var sum = stemNum + branchNum
        if sum > 5 { sum -= 5 }
        
        // 1=木, 2=金, 3=水, 4=火, 5=土
        switch sum {
        case 1: return .wood3
        case 2: return .metal4
        case 3: return .water2
        case 4: return .fire6
        case 5: return .earth5
        default: return .wood3
        }
    }
    
    /// 安紫微星地支公式
    private static func calculateZiweiBranch(lunarDay: Int, bureau: ElementBureau) -> EarthlyBranch {
        let x = bureau.number
        let remainder = lunarDay % x
        var q = lunarDay / x
        var k = 0
        
        if remainder != 0 {
            k = x - remainder
            q = (lunarDay + k) / x
        }
        
        // 寅宮為起點 (2)
        var targetIndex = (EarthlyBranch.yin.rawValue + q - 1) % 12
        if k % 2 == 1 {
            // 奇數逆數
            targetIndex = (targetIndex - k + 12) % 12
        } else {
            // 偶數順數
            targetIndex = (targetIndex + k) % 12
        }
        return EarthlyBranch(rawValue: targetIndex) ?? .yin
    }
    
    /// 安天府星地支公式 (寅申對稱軸)
    private static func calculateTianfuBranch(ziweiBranch: EarthlyBranch) -> EarthlyBranch {
        let tianfuIndex = (EarthlyBranch.chen.rawValue - ziweiBranch.rawValue + 12) % 12
        return EarthlyBranch(rawValue: tianfuIndex) ?? .chen
    }
    
    /// 四化查表 (包含倪海廈《天紀》庚干體系)
    private static func calculateFourTransformations(yearStem: HeavenlyStem, gengRule: GengTransformationRule) -> (lu: String, quan: String, ke: String, ji: String) {
        switch yearStem {
        case .jia: return ("廉貞", "破軍", "武曲", "太陽")
        case .yi:  return ("天機", "天梁", "紫微", "太陰")
        case .bing: return ("天同", "天機", "文昌", "廉貞")
        case .ding: return ("太陰", "天同", "天機", "巨門")
        case .wu:  return ("貪狼", "太陰", "右弼", "天機")
        case .ji:  return ("武曲", "貪狼", "天梁", "文曲")
        case .geng: return gengRule.stars
        case .xin: return ("巨門", "太陽", "文曲", "文昌")
        case .ren: return ("天梁", "紫微", "左輔", "武曲")
        case .gui: return ("破軍", "巨門", "太陰", "貪狼")
        }
    }
    
    /// 祿存
    private static func calculateLuCun(yearStem: HeavenlyStem) -> Int {
        switch yearStem {
        case .jia: return EarthlyBranch.yin.rawValue
        case .yi: return EarthlyBranch.mao.rawValue
        case .bing, .wu: return EarthlyBranch.si.rawValue
        case .ding, .ji: return EarthlyBranch.wu.rawValue
        case .geng: return EarthlyBranch.shen.rawValue
        case .xin: return EarthlyBranch.you.rawValue
        case .ren: return EarthlyBranch.hai.rawValue
        case .gui: return EarthlyBranch.zi.rawValue
        }
    }
    
    /// 天魁、天鉞
    private static func calculateKuiYue(yearStem: HeavenlyStem) -> (Int, Int) {
        switch yearStem {
        case .jia, .wu, .geng:
            return (EarthlyBranch.chou.rawValue, EarthlyBranch.wei.rawValue)
        case .yi, .ji:
            return (EarthlyBranch.zi.rawValue, EarthlyBranch.shen.rawValue)
        case .bing, .ding:
            return (EarthlyBranch.hai.rawValue, EarthlyBranch.you.rawValue)
        case .xin:
            return (EarthlyBranch.wu.rawValue, EarthlyBranch.yin.rawValue)
        case .ren, .gui:
            return (EarthlyBranch.mao.rawValue, EarthlyBranch.si.rawValue)
        }
    }
    
    /// 天馬
    private static func calculateTianMa(yearBranch: EarthlyBranch) -> Int {
        switch yearBranch {
        case .shen, .zi, .chen: return EarthlyBranch.yin.rawValue
        case .yin, .wu, .xu: return EarthlyBranch.shen.rawValue
        case .si, .you, .chou: return EarthlyBranch.hai.rawValue
        case .hai, .mao, .wei: return EarthlyBranch.si.rawValue
        }
    }
    
    /// 命主星
    private static func calculateLifeMaster(lifeBranch: EarthlyBranch) -> String {
        switch lifeBranch {
        case .zi: return "貪狼"
        case .chou, .hai: return "巨門"
        case .yin, .xu: return "祿存"
        case .mao, .you: return "文曲"
        case .chen, .shen: return "廉貞"
        case .si, .wei: return "武曲"
        case .wu: return "破軍"
        }
    }
    
    /// 身主星
    private static func calculateBodyMaster(yearBranch: EarthlyBranch) -> String {
        switch yearBranch {
        case .zi, .wu: return "火星"
        case .chou, .wei: return "天相"
        case .yin, .shen: return "天梁"
        case .mao, .you: return "天同"
        case .chen, .xu: return "文昌"
        case .si, .hai: return "天機"
        }
    }
    
    /// 廟旺利陷字典查表
    private static func getStarBrightness(starName: String, branch: EarthlyBranch) -> StarBrightness {
        let b = branch.rawValue
        switch starName {
        case "紫微":
            if b == 午 { return .miao }
            if [卯, 辰, 巳, 未, 申, 酉].contains(b) { return .wang }
            if [寅, 戌].contains(b) { return .de }
            if [丑, 亥].contains(b) { return .li }
            return .ping
        case "天機":
            if [子, 午].contains(b) { return .miao }
            if [卯, 辰].contains(b) { return .wang }
            if [巳, 申].contains(b) { return .de }
            if [寅, 酉].contains(b) { return .li }
            if [丑, 未].contains(b) { return .xian }
            return .ping
        case "太陽":
            if [巳, 午].contains(b) { return .miao }
            if [寅, 卯, 辰].contains(b) { return .wang }
            if b == 未 { return .de }
            if b == 申 { return .li }
            if [酉, 戌, 亥, 子, 丑].contains(b) { return .xian }
            return .ping
        case "武曲":
            if [辰, 戌, 丑, 未].contains(b) { return .miao }
            if [寅, 申, 子, 午].contains(b) { return .wang }
            if [巳, 亥].contains(b) { return .ping }
            return .de
        case "天同":
            if [寅, 申].contains(b) { return .wang }
            if [子, 巳].contains(b) { return .miao }
            if [卯, 辰].contains(b) { return .ping }
            if [午, 酉, 戌, 丑, 未].contains(b) { return .xian }
            return .li
        case "廉貞":
            if [寅, 申].contains(b) { return .miao }
            if [子, 午, 未].contains(b) { return .wang }
            if [辰, 戌].contains(b) { return .li }
            if [巳, 亥].contains(b) { return .xian }
            return .ping
        case "天府":
            if [寅, 申, 子, 午].contains(b) { return .miao }
            if [辰, 戌, 丑, 未].contains(b) { return .wang }
            if [巳, 亥].contains(b) { return .de }
            return .ping
        case "太陰":
            if [酉, 戌, 亥, 子].contains(b) { return .miao }
            if [丑, 寅].contains(b) { return .wang }
            if [卯, 辰, 巳, 午, 未, 申].contains(b) { return .xian }
            return .li
        case "貪狼":
            if [丑, 未].contains(b) { return .miao }
            if [辰, 戌].contains(b) { return .wang }
            if [寅, 申].contains(b) { return .de }
            if [子, 午].contains(b) { return .wang }
            if [巳, 亥].contains(b) { return .xian }
            return .li
        case "巨門":
            if [卯, 酉].contains(b) { return .miao }
            if [子, 午, 寅].contains(b) { return .wang }
            if [巳, 申].contains(b) { return .de }
            if [辰, 戌, 丑, 未].contains(b) { return .xian }
            return .ping
        case "天相":
            if [寅, 申, 子].contains(b) { return .miao }
            if [辰, 戌, 午].contains(b) { return .wang }
            if [巳, 亥, 丑, 未].contains(b) { return .de }
            return .xian
        case "天梁":
            if [午, 辰, 戌].contains(b) { return .miao }
            if [寅, 卯, 子].contains(b) { return .wang }
            if [丑, 未].contains(b) { return .wang }
            if [巳, 申, 亥].contains(b) { return .xian }
            return .ping
        case "七殺":
            if [寅, 申, 子, 午].contains(b) { return .miao }
            if [巳, 亥, 辰, 戌].contains(b) { return .wang }
            if [丑, 未].contains(b) { return .de }
            return .ping
        case "破軍":
            if [子, 午].contains(b) { return .miao }
            if [辰, 戌].contains(b) { return .wang }
            if [丑, 未].contains(b) { return .de }
            if [寅, 申].contains(b) { return .xian }
            return .ping
        default:
            return .ping
        }
    }
    
    // 地支常數捷徑
    private static let 子 = 0, 丑 = 1, 寅 = 2, 卯 = 3, 辰 = 4, 巳 = 5
    private static let 午 = 6, 未 = 7, 申 = 8, 酉 = 9, 戌 = 10, 亥 = 11
}
