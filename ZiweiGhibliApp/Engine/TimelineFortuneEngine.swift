import Foundation

public enum TimelineScope: String, CaseIterable, Identifiable {
    case natal = "本命"
    case decade = "大限"
    case annual = "流年"
    case minor = "小限"
    case monthly = "流月"
    case daily = "流日"
    
    public var id: String { rawValue }
}

public struct TimelineFortuneReading: Identifiable {
    public var id: String { "\(scope.rawValue)_\(headline)" }
    public let scope: TimelineScope
    public let currentFocusText: String
    public let targetPalace: PalaceData
    public let palaceName: String
    public let starsDisplay: String
    public let headline: String
    public let plainOverview: String
    public let opportunities: [String]
    public let precautions: [String]
    public let fawnAdvice: String
    public let highlightedBranch: EarthlyBranch
}

public class TimelineFortuneEngine {
    
    public static func calculateReading(
        chart: AstrolabeChart,
        scope: TimelineScope,
        decadeIndex: Int = 0,
        selectedYear: Int = 2026,
        selectedMonth: Int = 1,
        selectedDay: Int = 1
    ) -> TimelineFortuneReading {
        
        switch scope {
        case .natal:
            let lifeBranch = chart.lifePalaceBranch
            let p = chart.palace(at: lifeBranch)
            return synthesizeReading(
                scope: .natal,
                palace: p,
                chart: chart,
                focusText: "本命元辰（終身核心人格與潛能基石）",
                timeLabel: "終身元辰"
            )
            
        case .decade:
            let safeIdx = min(max(decadeIndex, 0), chart.palaces.count - 1)
            let p = chart.palaces[safeIdx]
            return synthesizeReading(
                scope: .decade,
                palace: p,
                chart: chart,
                focusText: "\(p.decadeStartAge) - \(p.decadeEndAge) 歲 大限十年運勢主場",
                timeLabel: "\(p.decadeStartAge)-\(p.decadeEndAge)歲大限"
            )
            
        case .annual:
            let yearBranchIdx = ((selectedYear - 4) % 12 + 12) % 12
            let annualBranch = EarthlyBranch(rawValue: yearBranchIdx) ?? .wu
            
            let yearStemIdx = ((selectedYear - 4) % 10 + 10) % 10
            let annualStem = HeavenlyStem(rawValue: yearStemIdx) ?? .bing
            
            let p = chart.palace(at: annualBranch)
            return synthesizeReading(
                scope: .annual,
                palace: p,
                chart: chart,
                focusText: "\(selectedYear) 歲次【\(annualStem.name)\(annualBranch.name)年】流年氣場",
                timeLabel: "\(selectedYear)年（\(annualStem.name)\(annualBranch.name)）",
                annualYear: selectedYear
            )
            
        case .minor:
            let birthBranch = chart.lunarInfo.yearBranch
            let startBranchMap: [EarthlyBranch: EarthlyBranch] = [
                .yin: .chen, .wu: .chen, .xu: .chen,
                .shen: .xu, .zi: .xu, .chen: .xu,
                .si: .wei, .you: .wei, .chou: .wei,
                .hai: .chou, .mao: .chou, .wei: .chou
            ]
            let startBranch = startBranchMap[birthBranch] ?? .chen
            let currentYear = Calendar.current.component(.year, from: Date())
            let birthYear = Calendar.current.component(.year, from: chart.solarDate)
            let nominalAge = max(currentYear - birthYear + 1, 1)
            let minorIdx = (startBranch.rawValue + (nominalAge - 1)) % 12
            let minorBranch = EarthlyBranch(rawValue: minorIdx) ?? .chen
            let p = chart.palace(at: minorBranch)
            
            return synthesizeReading(
                scope: .minor,
                palace: p,
                chart: chart,
                focusText: "實歲 \(nominalAge) 歲 小限心境微氣候",
                timeLabel: "\(nominalAge)歲小限"
            )
            
        case .monthly:
            let safeMonth = min(max(selectedMonth, 1), 12)
            let currentYear = Calendar.current.component(.year, from: Date())
            let yearBranchIdx = ((currentYear - 4) % 12 + 12) % 12
            // 順行起流月 (流年支起正月)
            let monthBranchIdx = (yearBranchIdx + (safeMonth - 1)) % 12
            let monthBranch = EarthlyBranch(rawValue: monthBranchIdx) ?? .zi
            let p = chart.palace(at: monthBranch)
            let monthNames = ["", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月"]
            let mName = monthNames[safeMonth]
            
            return synthesizeReading(
                scope: .monthly,
                palace: p,
                chart: chart,
                focusText: "農曆 \(mName) 流月吉凶氣候",
                timeLabel: "農曆\(mName)"
            )
            
        case .daily:
            let safeDay = min(max(selectedDay, 1), 30)
            let dayBranchIdx = (safeDay - 1) % 12
            let dayBranch = EarthlyBranch(rawValue: dayBranchIdx) ?? .zi
            let p = chart.palace(at: dayBranch)
            
            return synthesizeReading(
                scope: .daily,
                palace: p,
                chart: chart,
                focusText: "農曆 \(safeDay) 日 流日值日氣候",
                timeLabel: "農曆\(safeDay)日"
            )
        }
    }
    
    // MARK: - 核心演算法：根據宮位類別 + 坐鎮星曜 + 四化煞曜 動態生成深度解析
    private static func synthesizeReading(
        scope: TimelineScope,
        palace: PalaceData,
        chart: AstrolabeChart,
        focusText: String,
        timeLabel: String,
        annualYear: Int? = nil
    ) -> TimelineFortuneReading {
        
        let branch = palace.earthlyBranch
        let palaceType = palace.type
        let majorStars = palace.majorStars
        let luckyStars = palace.luckyStars
        let fierceStars = palace.fierceStars
        
        let majorNames = majorStars.map { $0.name }
        let starsStr = majorStars.map {
            let b = $0.brightness != nil ? "[\($0.brightness!.rawValue)]" : ""
            let tf = $0.natalTransformation != nil ? " 化\($0.natalTransformation!.rawValue)" : ""
            return "\($0.name)\(b)\(tf)"
        }.joined(separator: "、")
        
        let displayStars = starsStr.isEmpty ? "命無正曜 (借對宮星曜吉光照耀)" : starsStr
        
        let hasJi = palace.stars.contains { $0.natalTransformation == .ji }
        let hasLu = palace.stars.contains { $0.natalTransformation == .lu }
        let hasQuan = palace.stars.contains { $0.natalTransformation == .quan }
        let hasKe = palace.stars.contains { $0.natalTransformation == .ke }
        
        // 1. 動態主標題
        let headline = buildHeadline(
            scope: scope,
            timeLabel: timeLabel,
            palaceType: palaceType,
            majorNames: majorNames,
            hasLu: hasLu,
            hasJi: hasJi,
            hasQuan: hasQuan
        )
        
        // 2. 動態白話深度詳解
        let overview = buildOverview(
            scope: scope,
            timeLabel: timeLabel,
            palace: palace,
            displayStars: displayStars,
            majorNames: majorNames,
            hasLu: hasLu,
            hasJi: hasJi,
            hasQuan: hasQuan,
            hasKe: hasKe
        )
        
        // 3. 機遇與利好
        let opportunities = buildOpportunities(
            palaceType: palaceType,
            majorNames: majorNames,
            luckyStars: luckyStars,
            hasLu: hasLu,
            hasQuan: hasQuan
        )
        
        // 4. 暗礁與避坑
        let precautions = buildPrecautions(
            palaceType: palaceType,
            majorNames: majorNames,
            fierceStars: fierceStars,
            hasJi: hasJi
        )
        
        // 5. 小鹿兒專屬溫馨指引
        let fawnAdvice = buildFawnAdvice(
            scope: scope,
            palaceType: palaceType,
            hasJi: hasJi,
            majorNames: majorNames
        )
        
        let palaceTitle = "\(scope.rawValue)焦點：\(palaceType.name) (\(branch.name)宮)"
        
        return TimelineFortuneReading(
            scope: scope,
            currentFocusText: focusText,
            targetPalace: palace,
            palaceName: palaceTitle,
            starsDisplay: displayStars,
            headline: headline,
            plainOverview: overview,
            opportunities: opportunities,
            precautions: precautions,
            fawnAdvice: fawnAdvice,
            highlightedBranch: branch
        )
    }
    
    // MARK: - 動態標題建構
    private static func buildHeadline(
        scope: TimelineScope,
        timeLabel: String,
        palaceType: PalaceType,
        majorNames: [String],
        hasLu: Bool,
        hasJi: Bool,
        hasQuan: Bool
    ) -> String {
        let starsKeyword = majorNames.prefix(2).joined()
        let starTag = starsKeyword.isEmpty ? "星曜借照" : "【\(starsKeyword)】"
        
        if hasLu {
            return "\(starTag) \(timeLabel)逢化祿吉慶，\(palaceType.name)生機勃發收穫豐碩"
        }
        if hasQuan {
            return "\(starTag) \(timeLabel)權柄在握，\(palaceType.name)雷厲風行拓局先鋒"
        }
        if hasJi {
            return "\(starTag) \(timeLabel)修心蓄力期，\(palaceType.name)以穩為上防暗礁波折"
        }
        
        switch palaceType {
        case .career:
            return "\(starTag) \(timeLabel)行至官祿主場：事業突破在即，才幹展露贏得信任"
        case .wealth:
            return "\(starTag) \(timeLabel)聚焦財帛運轉：求財管道明朗，穩紮穩打積累基石"
        case .marriage:
            return "\(starTag) \(timeLabel)緣牽夫妻情誼：以心印心相惜，共築溫暖情感港灣"
        case .travel:
            return "\(starTag) \(timeLabel)出門吉星相照：異地開拓順遂，動態交流打開格局"
        case .property:
            return "\(starTag) \(timeLabel)安固田宅基業：聚財安家之時，居家溫馨福澤庇蔭"
        case .health:
            return "\(starTag) \(timeLabel)調和身心元氣：順應四季節奏，養精蓄銳厚積薄發"
        case .friends:
            return "\(starTag) \(timeLabel)人脈圈層流轉：良師益友相攜，貴人提攜共贏契機"
        case .happiness:
            return "\(starTag) \(timeLabel)心靈福澤充盈：放寬心胸自洽，精神富足樂得自在"
        case .life:
            return "\(starTag) \(timeLabel)本命元辰閃耀：立足核心原則，開拓個人獨特天地"
        default:
            return "\(starTag) \(timeLabel)臨\(palaceType.name)：順應星勢節奏，步步落實漸入佳境"
        }
    }
    
    // MARK: - 動態白話詳解
    private static func buildOverview(
        scope: TimelineScope,
        timeLabel: String,
        palace: PalaceData,
        displayStars: String,
        majorNames: [String],
        hasLu: Bool,
        hasJi: Bool,
        hasQuan: Bool,
        hasKe: Bool
    ) -> String {
        let pName = palace.type.name
        let starsDesc: String
        if majorNames.contains("紫微") || majorNames.contains("天府") {
            starsDesc = "貴星坐鎮，自帶沉穩格局與開拓擔當，易獲貴人賞識與同儕信賴。"
        } else if majorNames.contains("武曲") || majorNames.contains("太陰") {
            starsDesc = "財星照耀，注重實質成果與資源沉澱，善於在變局中捕捉務實商機。"
        } else if majorNames.contains("天機") || majorNames.contains("巨門") {
            starsDesc = "智慧與策劃星曜活躍，思維敏捷清晰，能靠優異的談判與方案規劃出奇制勝。"
        } else if majorNames.contains("太陽") || majorNames.contains("天梁") {
            starsDesc = "浩然正氣與庇蔭星臨門，樂於助人累積深厚福德，出外逢凶化吉。"
        } else if majorNames.contains("七殺") || majorNames.contains("破軍") || majorNames.contains("貪狼") {
            starsDesc = "殺破狼生機躍動，破除陳規舊習、主動求新求變，具有驚人的開拓爆發力。"
        } else {
            starsDesc = "星曜氣場平和，借對宮吉曜照拂，處事順遂圓融、彈性極大。"
        }
        
        var transDesc = ""
        if hasLu { transDesc += " 本宮逢生年化祿，財祿與人緣如虎添翼，是全力推進目標的最佳時機！" }
        if hasQuan { transDesc += " 宮內坐鎮化權，主導權與執行力極強，宜把握競爭先機。" }
        if hasKe { transDesc += " 遇化科吉曜，文思泉湧、考運考績順遂，美名廣傳。" }
        if hasJi { transDesc += " 逢化忌干擾，提示此階段切勿心浮氣躁，重大決定宜三思而後行，穩健是第一要務。" }
        
        switch scope {
        case .natal:
            return "你的本命元辰由 \(displayStars) 鎮守，為一生的性格內核與天賦底層代碼。\(starsDesc)\(transDesc) 任何大限流年的起伏皆以本命格局為根基，只要認清自我長處並持續深耕，自能成就不凡人生！"
        case .decade:
            return "在 \(timeLabel) 這關鍵十年中，時空核心聚焦於【\(pName)】所管轄的生命領域。此十年由 \(displayStars) 牽動，\(starsDesc)\(transDesc) 適合鎖定長期核心賽道，建立不可替代的專業護城河。"
        case .annual:
            return "西曆 \(timeLabel)，你的流年命宮行至 \(palace.earthlyBranch.name) 宮，正好對應本命【\(pName)】。受 \(displayStars) 氣場所引領，\(starsDesc)\(transDesc) 整體年度節奏鮮明，務必抓住核心矛盾集中發力！"
        case .minor:
            return "小限反映 \(timeLabel) 的個人內心心境、情緒起伏與健康微氣候。小限行至【\(pName)】，宮內見 \(displayStars)。\(starsDesc)\(transDesc) 宜多傾聽內在真實聲音，注重身心放鬆與情緒平衡。"
        case .monthly:
            return "農曆 \(timeLabel) 運勢行至 \(palace.earthlyBranch.name) 宮【\(pName)】。受 \(displayStars) 值月主導，\(starsDesc)\(transDesc) 本月節奏緊湊明快，適合把積累的待辦要務逐一落地執行。"
        case .daily:
            return "今日流日氣場專注於【\(pName)】，由 \(displayStars) 值日守護。\(starsDesc)\(transDesc) 直覺與行動力在線，適合做出關鍵決策與落實今日核心任務！"
        }
    }
    
    // MARK: - 動態機遇
    private static func buildOpportunities(
        palaceType: PalaceType,
        majorNames: [String],
        luckyStars: [StarItem],
        hasLu: Bool,
        hasQuan: Bool
    ) -> [String] {
        var list: [String] = []
        
        switch palaceType {
        case .career:
            list.append("職場上有望承接核心業務或獲得晉升拔擢，發揮關鍵影響力。")
            list.append("專業技能備受同行或長官認可，能建立起無可替代的個人信譽。")
        case .wealth:
            list.append("求財管道多元通達，適合推進穩健理財計畫或開啟副業獲利。")
            list.append("對市場價值具備敏銳嗅覺，能做出精準務實的財務決策。")
        case .marriage:
            list.append("親密關係迎來深度溝通契機，能增進彼此默契與長遠安全感。")
            list.append("單身者容易在志趣相投的圈層中結識成熟且具包容力的優質良緣。")
        case .travel:
            list.append("出外公差、遠行求學或跨領域探索運氣極佳，能拓寬眼界與格局。")
            list.append("異地貴人主動釋放善意，跨界合作容易談成重大共識。")
        case .friends:
            list.append("能結識視野開闊的同頻夥伴，同儕互助協同效應顯著。")
            list.append("適合組織團隊或參與優質社群，人脈資源將轉化為實質助力。")
        default:
            list.append("行事果決有條理，能迅速排除日常障礙並贏得身邊人的支持。")
            list.append("心態積極樂觀，面對突發狀況能隨機應變、化被動為主動。")
        }
        
        if hasLu || hasQuan {
            list.append("自帶旺氣光環，關鍵時刻總有長輩或關鍵資源主動到位扶持。")
        }
        if !luckyStars.isEmpty {
            list.append("吉曜拱照，文書簽約、考試合格或重要認證皆能順利過關。")
        }
        
        return Array(list.prefix(3))
    }
    
    // MARK: - 動態暗礁與避坑
    private static func buildPrecautions(
        palaceType: PalaceType,
        majorNames: [String],
        fierceStars: [StarItem],
        hasJi: Bool
    ) -> [String] {
        var list: [String] = []
        
        if hasJi {
            list.append("此階段切忌急躁冒進或跟風投資，重要條款與金錢往來務必白紙黑字。")
            list.append("溝通時保持心平氣和，切莫因口直心快而引發不必要的口舌誤會。")
        }
        
        if !fierceStars.isEmpty {
            let fierceNames = fierceStars.map { $0.name }.joined(separator: "、")
            list.append("宮逢煞曜（\(fierceNames)），需防範突發急躁、情緒緊繃或交通行車安全。")
        }
        
        switch palaceType {
        case .career:
            list.append("切莫事必躬親導致體力透支，適時授權更能維持高效領導力。")
        case .wealth:
            list.append("嚴拒高槓桿賭徒心態與熟人借貸代墊，守住流動資金才是真正贏家。")
        case .marriage:
            list.append("遇爭執多給彼此緩衝空間，切莫在盛怒之下做出過激承諾或決斷。")
        case .health:
            list.append("注意規律作息與飲食均衡，及時抒解肩頸疲勞與精神壓力。")
        default:
            if list.isEmpty {
                list.append("行事切忌三分鐘熱度，維持專注度方能收穫最甜美果實。")
            }
        }
        
        return Array(list.prefix(2))
    }
    
    // MARK: - 動態小鹿兒溫馨錦囊
    private static func buildFawnAdvice(
        scope: TimelineScope,
        palaceType: PalaceType,
        hasJi: Bool,
        majorNames: [String]
    ) -> String {
        if hasJi {
            return "小鹿兒特別叮嚀：化忌是老天爺給予的沉澱修煉禮物！放慢腳步、深呼吸，不爭一時長短，熬過風雨便是繁花似錦！"
        }
        switch scope {
        case .annual:
            return "小鹿兒流年錦囊：今年是開拓視野的幸運年份！多穿搭大地色與墨綠系，常帶微笑，身邊處處皆是你的開運貴人！"
        case .monthly:
            return "小鹿兒流月叮嚀：這個月行動力滿分！給自己泡一杯清香溫茶，踏實走好每一步，幸運就在前方等著你！"
        case .daily:
            return "小鹿兒每日一句：今天是你創造美好記憶的一天，順心而行、善待自己，美好自會如約而至！"
        case .decade:
            return "小鹿兒大限錦囊：人生十年一大變！選對方向、專注深耕，時間會給出最驚喜的答案！"
        default:
            return "小鹿兒心靈寄語：認同自己的獨特步伐，順應天時、知命造命，你永遠是自己生命中最棒的舵手！"
        }
    }
}
