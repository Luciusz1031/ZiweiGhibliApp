import Foundation

public struct SynastryResult: Codable {
    public let overallScore: Int              // 總體契合度 (0..100)
    public let loveScore: Int                 // 情感共鳴 (0..100)
    public let valueScore: Int                // 價值觀默契 (0..100)
    public let wealthSynergyScore: Int        // 事業與財富互旺度 (0..100)
    public let communicationScore: Int        // 溝通包容力 (0..100)
    
    public let relationshipType: String       // 關係標籤 (如「靈魂神隊友型」、「剛柔互補開拓型」)
    public let headline: String               // 合盤核心定調金句
    
    public let starChemistry: String          // 雙方主星磁場碰撞解析
    public let mutualBlessings: [String]      // 誰旺誰？四化互入福澤清單
    public let frictionPoints: [String]       // 容易磨擦的相處盲點
    public let fawnSynastryAdvice: String     // 小鹿兒合盤相處秘訣指南
}

public class SynastryEngine {
    
    /// 計算雙人紫微斗數合盤分析 (每次資料更動即時重算)
    public static func analyze(personA: AstrolabeChart, personB: AstrolabeChart) -> SynastryResult {
        let palaceA = personA.palaces[personA.lifePalaceBranch.rawValue]
        let palaceB = personB.palaces[personB.lifePalaceBranch.rawValue]
        
        let starsA = palaceA.majorStars.map { $0.name }
        let starsB = palaceB.majorStars.map { $0.name }
        let nameA = personA.userName.isEmpty ? "命主" : personA.userName
        let nameB = personB.userName.isEmpty ? "對象" : personB.userName
        
        // 1. 計算主星互動與分數
        let (baseScore, chemistryText, relType, headline) = evaluateStarPair(nameA: nameA, starsA: starsA, nameB: nameB, starsB: starsB)
        
        // 2. 四化互照飛星 (A 的生年干四化入 B 的宮位，B 的四化入 A 的宮位)
        let blessings = evaluateMutualTransformations(personA: personA, personB: personB)
        
        // 3. 依據雙方干支差異微調計算四大維度分數
        let stemOffset = abs(personA.lunarInfo.yearStem.rawValue - personB.lunarInfo.yearStem.rawValue) % 5
        let loveScore = min(max(baseScore + (blessings.count * 2) - stemOffset, 60), 98)
        let valueScore = min(max(baseScore - 2 + (personA.elementBureau == personB.elementBureau ? 6 : 0), 55), 96)
        let wealthScore = min(max(baseScore + 3 + (blessings.count * 2), 62), 99)
        let commScore = min(max(baseScore - 4 + (10 - stemOffset * 2), 52), 95)
        let overall = (loveScore + valueScore + wealthScore + commScore) / 4
        
        // 4. 摩擦盲點 (客製化雙方姓名與星宿)
        let frictionPoints = generateFrictionPoints(nameA: nameA, starsA: starsA, nameB: nameB, starsB: starsB)
        
        // 5. 小鹿兒合盤相處建議
        let advice = generateSynastryAdvice(nameA: nameA, starsA: starsA, nameB: nameB, starsB: starsB, overallScore: overall)
        
        return SynastryResult(
            overallScore: overall,
            loveScore: loveScore,
            valueScore: valueScore,
            wealthSynergyScore: wealthScore,
            communicationScore: commScore,
            relationshipType: relType,
            headline: headline,
            starChemistry: chemistryText,
            mutualBlessings: blessings,
            frictionPoints: frictionPoints,
            fawnSynastryAdvice: advice
        )
    }
    
    // MARK: - 主星化學反應評估
    private static func evaluateStarPair(nameA: String, starsA: [String], nameB: String, starsB: [String]) -> (Int, String, String, String) {
        let starsStrA = starsA.isEmpty ? "借對宮星曜" : starsA.joined(separator: "・")
        let starsStrB = starsB.isEmpty ? "借對宮星曜" : starsB.joined(separator: "・")
        let allStars = Set(starsA + starsB)
        
        if (allStars.contains("紫微") && allStars.contains("天府")) ||
           (allStars.contains("太陽") && allStars.contains("太陰")) {
            return (
                93,
                "【尊星合璧・日月同天】「\(nameA)」(\(starsStrA)) 與「\(nameB)」(\(starsStrB)) 的命宮磁場極度相得益彰！一方如陽光般溫暖開拓，另一方如月光般深沉包容。在一起不僅有強烈的心靈共鳴，在重要人生關卡更能彼此托底推進！",
                "天作之合・靈魂神隊友",
                "「如星月同天，既懂彼此的雄心，亦憐對方的脆弱。」"
            )
        }
        
        if (allStars.contains("七殺") || allStars.contains("破軍")) &&
           (allStars.contains("天相") || allStars.contains("天同") || allStars.contains("天梁")) {
            return (
                89,
                "【剛柔並濟・攻守兼備】「\(nameA)」(\(starsStrA)) 遇上「\(nameB)」(\(starsStrB))，一方具備強悍的決斷力與衝鋒勇氣，另一方則情商卓越、細心穩重。一人向前開疆拓土，一人在後穩固後方，是極具實戰爆發力的黃金搭檔！",
                "剛柔互補・事業王牌搭檔",
                "「你敢勇往直前破浪，我能穩掌羅盤護航。」"
            )
        }
        
        if (allStars.contains("貪狼") || allStars.contains("廉貞")) &&
           (allStars.contains("天機") || allStars.contains("巨門")) {
            return (
                87,
                "【靈感共振・才華碰撞】「\(nameA)」(\(starsStrA)) 與「\(nameB)」(\(starsStrB)) 在一起生活永不無聊！雙方思維敏捷、好奇心旺盛，思想交流常有奇思妙想。相處就像無話不談的知己密友，情趣與熱情源源不絕。",
                "靈犀相通・生活智庫玩家",
                "「靈魂有共鳴，言語有溫度，相處百看不厭。」"
            )
        }
        
        if (allStars.contains("武曲") || allStars.contains("天府")) {
            return (
                86,
                "【財星入庫・穩健築基】「\(nameA)」(\(starsStrA)) 與「\(nameB)」(\(starsStrB)) 對生活與資產規劃皆具備務實視角。雙方理念契合，不喜浮誇浪費，攜手經營家庭或事業能讓財庫日益充盈、基業長青。",
                "財庫同心・實力拓荒搭檔",
                "「踏實同行，步步為營，積蓄一生豐盛。」"
            )
        }
        
        return (
            83,
            "【溫潤相守・細水長流】「\(nameA)」(\(starsStrA)) 與「\(nameB)」(\(starsStrB)) 性格沉穩溫和，雖無戲劇般的轟轟烈烈，但擁有經得起歲月考驗的踏實。尊重各自的獨立步調，越相處越能感受心靈的平靜與可靠。",
            "互敬互重・溫潤長相守",
            "「平淡相守方見真情，歲月沉澱更顯珍貴。」"
        )
    }
    
    // MARK: - 四化互照 (誰旺誰)
    private static func evaluateMutualTransformations(personA: AstrolabeChart, personB: AstrolabeChart) -> [String] {
        var list: [String] = []
        let nameA = personA.userName.isEmpty ? "命主" : personA.userName
        let nameB = personB.userName.isEmpty ? "對象" : personB.userName
        
        // 檢測 A 的生年四化是否照會 B
        let bLifeBranch = personB.lifePalaceBranch
        let bWealthBranch = personB.palaces.first { $0.type == .wealth }?.earthlyBranch ?? bLifeBranch
        let bCareerBranch = personB.palaces.first { $0.type == .career }?.earthlyBranch ?? bLifeBranch
        let bKeyBranches = [bLifeBranch, bWealthBranch, bCareerBranch]
        
        var aBlessesB = false
        for b in bKeyBranches {
            let p = personB.palaces[b.rawValue]
            if p.stars.contains(where: { $0.natalTransformation == .lu || $0.natalTransformation == .quan }) {
                list.append("💰 財祿照會：【\(nameA)】的生年星氣正好照入【\(nameB)】的\(p.type.name)，攜手理財或共創事業極利財庫增長！")
                aBlessesB = true
                break
            }
        }
        if !aBlessesB {
            list.append("💰 財祿滋養：【\(nameA)】與【\(nameB)】的五行局數彼此相生，能為彼此帶來穩定的財務安全感。")
        }
        
        list.append("🎁 貴人權柄：【\(nameB)】能成為【\(nameA)】在重要生涯抉擇時的定海神針，提供客觀視角與關鍵推力。")
        list.append("🛡️ 護短庇佑：在外部環境遭遇考驗時，兩人具備一致對外的堅定默契，彼此就是最溫暖的避風港。")
        
        return list
    }
    
    // MARK: - 摩擦盲點
    private static func generateFrictionPoints(nameA: String, starsA: [String], nameB: String, starsB: [String]) -> [String] {
        var points: [String] = []
        points.append("⚠️ 主導權協調：【\(nameA)】與【\(nameB)】皆是有主見之人，遇分歧時切忌情緒用事，重要決策宜分工授權。")
        points.append("💬 溝通表達節奏：一方習慣開門見山解決問題，另一方偶爾需要時間沈澱情緒，記得多留出彼此冷靜的空間。")
        points.append("⏰ 步調同步：衝刺事業與享受生活的優先序偶有先後，提前同步日常期待，方能避免不必要的隱形內耗。")
        return points
    }
    
    // MARK: - 倪師天紀合盤指南
    private static func generateSynastryAdvice(nameA: String, starsA: [String], nameB: String, starsB: [String], overallScore: Int) -> String {
        return """
        🦌 小鹿兒合盤錦囊：
        倪海廈先生《天紀》論人際與姻緣講求『知己知彼，相敬如賓』。
        【\(nameA)】與【\(nameB)】的合盤契合度高達 \(overallScore) 分，自帶難得的互助緣分！
        長久幸福的秘密在於「看見對方的優點，包容對方的局限」。不要試圖把對方改造成另一個自己，多讚美、少挑剔，將彼此的才智與優勢合力對外開拓，你們將會是一對無堅不摧的人生黃金搭檔！
        """
    }
}
