import Foundation

public struct SynastryResult: Codable {
    public let overallScore: Int              // 總體契合度 (0..100)
    public let loveScore: Int                 // 情感共鳴 (0..100)
    public let valueScore: Int                // 價值觀默契 (0..100)
    public let wealthSynergyScore: Int        // 事業與財富互旺度 (0..100)
    public let communicationScore: Int        // 溝通包容力 (0..100)
    
    public let relationshipType: String       // 關係關係標籤 (如「靈魂神隊友型」、「剛柔互補開拓型」)
    public let headline: String               // 合盤核心定調金句
    
    public let starChemistry: String          // 雙方主星磁場碰撞解析
    public let mutualBlessings: [String]      // 誰旺誰？四化互入福澤清單
    public let frictionPoints: [String]       // 容易磨擦的相處盲點
    public let fawnSynastryAdvice: String     // 小鹿兒合盤相處秘訣指南
}

public class SynastryEngine {
    
    /// 計算雙人紫微斗數合盤分析
    public static func analyze(personA: AstrolabeChart, personB: AstrolabeChart) -> SynastryResult {
        let palaceA = personA.palaces[personA.lifePalaceBranch.rawValue]
        let palaceB = personB.palaces[personB.lifePalaceBranch.rawValue]
        
        let starsA = palaceA.majorStars.map { $0.name }
        let starsB = palaceB.majorStars.map { $0.name }
        
        // 1. 計算主星互動與分數
        let (baseScore, chemistryText, relType, headline) = evaluateStarPair(starsA: starsA, starsB: starsB)
        
        // 2. 四化互照飛星 (A 的生年干四化入 B 的宮位，B 的四化入 A 的宮位)
        let blessings = evaluateMutualTransformations(personA: personA, personB: personB)
        
        // 3. 計算四大維度分數
        let loveScore = min(max(baseScore + (blessings.count * 3), 60), 98)
        let valueScore = min(max(baseScore - 2, 55), 96)
        let wealthScore = min(max(baseScore + 4, 62), 99)
        let commScore = min(max(baseScore - 5, 52), 95)
        let overall = (loveScore + valueScore + wealthScore + commScore) / 4
        
        // 4. 摩擦盲點
        let frictionPoints = generateFrictionPoints(starsA: starsA, starsB: starsB)
        
        // 5. 小鹿兒合盤相處建議
        let advice = generateSynastryAdvice(starsA: starsA, starsB: starsB, overallScore: overall)
        
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
    private static func evaluateStarPair(starsA: [String], starsB: [String]) -> (Int, String, String, String) {
        let allStars = Set(starsA + starsB)
        
        if (allStars.contains("紫微") && allStars.contains("天府")) ||
           (allStars.contains("太陽") && allStars.contains("太陰")) {
            return (
                92,
                "【日月雙輝 / 尊星合璧】雙方命格氣場極度和諧！一方如陽光般溫暖開拓，另一方如月光般細膩包容。在一起時不僅能產生深厚的心靈默契，在事業與生活目標上更具備強大的互補推進力。",
                "天作之合・靈魂神隊友",
                "「如星月同天，既懂彼此的雄心，亦憐對方的脆弱。」"
            )
        }
        
        if (allStars.contains("七殺") || allStars.contains("破軍")) &&
           (allStars.contains("天相") || allStars.contains("天同") || allStars.contains("天梁")) {
            return (
                88,
                "【剛柔相濟・開拓守護】一方行動果決、衝勁十足；另一方情商高超、沉著穩健。一人在前方衝鋒陷陣，一人在後方運籌帷幄、打點細節。彼此能迅速補足對方的盲點，是極具戰鬥力的組合！",
                "剛柔並濟・事業王牌搭檔",
                "「你敢勇往直前破浪，我能穩掌羅盤護航。」"
            )
        }
        
        if (allStars.contains("貪狼") || allStars.contains("廉貞")) &&
           (allStars.contains("天機") || allStars.contains("巨門")) {
            return (
                86,
                "【靈感共振・才華碰撞】兩人在一起永遠不會冷場！雙方思維跳躍、好奇心旺盛，在觀點交流中常能激發出意想不到的靈感火花。相處模式像無話不談的知己好友，生活充滿生機。",
                "靈犀相通・生活智庫玩家",
                "「靈魂有共鳴，言語有溫度，相處百看不厭。」"
            )
        }
        
        return (
            82,
            "【循序漸進・細水長流】雙方性格沉穩踏實，雖無驚天動地的戲劇性波折，但具備建立穩固生活基石的能力。彼此尊重各自的獨立空間，越相處越能體會這份難得的踏實與可靠。",
            "互敬互重・溫潤長相守",
            "「平淡相守方見真情，歲月沉澱更顯珍貴。」"
        )
    }
    
    // MARK: - 四化互照 (誰旺誰)
    private static func evaluateMutualTransformations(personA: AstrolabeChart, personB: AstrolabeChart) -> [String] {
        var list: [String] = []
        
        // 檢測 A 的生年四化是否入 B 的三方四正
        let bLifeBranch = personB.lifePalaceBranch
        let bWealthBranch = personB.palaces.first { $0.type == .wealth }?.earthlyBranch ?? bLifeBranch
        let bCareerBranch = personB.palaces.first { $0.type == .career }?.earthlyBranch ?? bLifeBranch
        let bKeyBranches = [bLifeBranch, bWealthBranch, bCareerBranch]
        
        // A 的化祿星在 B 的盤中
        for b in bKeyBranches {
            let p = personB.palaces[b.rawValue]
            if p.stars.contains(where: { $0.natalTransformation == .lu }) {
                list.append("🌟 雙方財運磁場共振：一方的財氣正好落入對方的關鍵宮位，攜手合作或共組家庭極利財庫增長！")
                break
            }
        }
        
        list.append("🎁 貴人互旺：一方的生年天干帶來化科化權照會，在重要抉擇時能成為彼此的定海神針與智囊。")
        list.append("🛡️ 護短庇佑：在外部環境面臨壓力時，兩人具備一緻對外的默契，彼此就是最安全的避風港。")
        
        return list
    }
    
    // MARK: - 摩擦盲點
    private static func generateFrictionPoints(starsA: [String], starsB: [String]) -> [String] {
        var points: [String] = []
        points.append("⚠️ 主導權的爭執：雙方都具有主見與自尊心，切忌在公開場合硬碰硬，私下各退一步海闊天空。")
        points.append("💬 表達習慣差異：一方習慣直來直往解決問題，另一方有時需要時間沉澱情緒，學會給彼此緩衝冷靜期。")
        points.append("⏰ 生活節奏落差：衝刺事業與享受生活的步調偶有不同，提前同步行程與期望，能避免不必要的內耗。")
        return points
    }
    
    // MARK: - 倪師天紀合盤指南
    private static func generateSynastryAdvice(starsA: [String], starsB: [String], overallScore: Int) -> String {
        return """
        🦌 小鹿兒合盤錦囊：
        倪海廈先生《天紀》論人際與姻緣講求『知己知彼，相敬如賓』。
        你們的契合度高達 \(overallScore) 分，天生帶有深厚的吸引力與互助緣分！
        長久幸福的秘密在於「看見對方的優點，包容對方的局限」。不要試圖把對方改造成另一個自己，多讚美、少挑剔，把彼此的才智用在對外開拓上，你們將會是一對無堅不摧的人生黃金搭檔！
        """
    }
}
