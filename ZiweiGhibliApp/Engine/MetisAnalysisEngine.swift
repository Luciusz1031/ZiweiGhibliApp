import Foundation

// MARK: - 六維雷達圖數值
public struct DimensionalScores: Codable {
    public let overall: Double       // 綜合評分 (0..100)
    public let career: Double        // 事業 (0..100)
    public let wealth: Double        // 財運 (0..100)
    public let relationship: Double  // 感情 (0..100)
    public let personality: Double   // 性格 (0..100)
    public let health: Double        // 健康 (0..100)
    
    public init(overall: Double, career: Double, wealth: Double, relationship: Double, personality: Double, health: Double) {
        self.overall = overall
        self.career = career
        self.wealth = wealth
        self.relationship = relationship
        self.personality = personality
        self.health = health
    }
}

// MARK: - 命盤維度分析模型
public struct MetisAnalysisReport: Codable {
    public let headline: String               // 霸氣震撼命格主標題 (如「敢推倒重來，敢走在前頭」)
    public let subHeadline: String            // 副標題簡介
    public let scores: DimensionalScores      // 六維雷達圖得分
    
    // 核心三維度卡片
    public let coreAdvantage: String          // 🌟 核心優勢
    public let relationshipPattern: String    // 🧭 關係模式
    public let growthChallenge: String        // 📈 成長課題
    
    // 深度命格解讀
    public let detailedOverview: String       // 命格總覽長篇剖析
    public let actionableAdvice: String       // 具體建議與行動方向
    public let oneSentenceVerdict: String     // 一句話定調
    
    // 各維度切換解讀
    public let dimensionReadings: [String: String]
}

public class MetisAnalysisEngine {
    
    /// 依據命盤資料生成如同 Metis Ziwei 的全方位高階結構化分析報告
    public static func generateReport(for chart: AstrolabeChart) -> MetisAnalysisReport {
        let lifePalace = chart.palaces[chart.lifePalaceBranch.rawValue]
        let majorNames = lifePalace.majorStars.map { $0.name }
        
        let careerPalace = chart.palaces.first { $0.type == .career } ?? lifePalace
        let wealthPalace = chart.palaces.first { $0.type == .wealth } ?? lifePalace
        let marriagePalace = chart.palaces.first { $0.type == .marriage } ?? lifePalace
        let healthPalace = chart.palaces.first { $0.type == .health } ?? lifePalace
        
        // 1. 計算六維評分
        let scores = calculateScores(
            life: lifePalace,
            career: careerPalace,
            wealth: wealthPalace,
            marriage: marriagePalace,
            health: healthPalace
        )
        
        // 2. 生成標題與副標
        let (headline, subHeadline) = generateHeadline(majorNames: majorNames, bureau: chart.elementBureau)
        
        // 3. 核心三維度
        let coreAdvantage = generateCoreAdvantage(majorNames: majorNames)
        let relationshipPattern = generateRelationshipPattern(majorNames: majorNames)
        let growthChallenge = generateGrowthChallenge(majorNames: majorNames)
        
        // 4. 命格長篇總覽
        let detailedOverview = generateDetailedOverview(majorNames: majorNames, chart: chart)
        let actionableAdvice = generateActionableAdvice(majorNames: majorNames, chart: chart)
        let oneSentenceVerdict = generateOneSentenceVerdict(majorNames: majorNames)
        
        // 5. 各維度分頁解讀 (供 Metis 風格標籤頁切換)
        var dimensionReadings: [String: String] = [:]
        dimensionReadings["命格總覽"] = detailedOverview
        dimensionReadings["財富"] = "你的財帛宮由 \(wealthPalace.majorStars.map { $0.name }.joined(separator: "、")) 鎮守。賺錢邏輯以穩紮穩打或專業開拓為主。求財切忌急躁投機，建立起個人核心技術與被動收入管道，財庫方能固若金湯。"
        dimensionReadings["事業"] = "官祿宮展現出 \(careerPalace.majorStars.map { $0.name }.joined(separator: "、")) 的特質。適合在需要自主決策、策略佈局或技術專長的領域施展拳腳。越早獨立承擔專案，越能獲得長官貴人青睞。"
        dimensionReadings["感情"] = "夫妻宮主星為 \(marriagePalace.majorStars.map { $0.name }.joined(separator: "、"))。在親密關係中，你需要的是精神上能互相尊重、並肩前進的戰友型伴侶。相處關鍵在於放下掌控欲，給予彼此呼吸的空間。"
        dimensionReadings["性格"] = "內心深處自尊心高且富有獨立見解，不喜歡人云亦云。面對挫折時有極強的自我復原力，但有時容易因求好心切而讓自己神經緊繃。"
        dimensionReadings["健康"] = "留意工作勞累導致的睡眠品質與腸胃代謝問題。平時宜多進行散步、冥想等放鬆運動，順應四時規律作息。"
        dimensionReadings["人際貴人"] = "你天生具有吸引有實力夥伴的氣場。貴人往往出現在專業交流與跨界合作之中，多展現誠意與擔當，自能廣結善緣。"
        dimensionReadings["田宅"] = "居家環境喜好明亮整潔、有條不紊。具備不動產增值之潛力，成家立業後能為自身帶來強大的精神安定感。"
        dimensionReadings["婚戀"] = "情感專一而執著，在相處上講究真誠與默契。適當的讚美與傾聽，是昇華彼此關係的最強開運法寶。"
        dimensionReadings["父母長輩"] = "與長輩相處宜以敬重為先。父母的教誨是你成長過程中重要的基石，多花時間陪伴能收穫心靈的平靜與福氣。"
        
        return MetisAnalysisReport(
            headline: headline,
            subHeadline: subHeadline,
            scores: scores,
            coreAdvantage: coreAdvantage,
            relationshipPattern: relationshipPattern,
            growthChallenge: growthChallenge,
            detailedOverview: detailedOverview,
            actionableAdvice: actionableAdvice,
            oneSentenceVerdict: oneSentenceVerdict,
            dimensionReadings: dimensionReadings
        )
    }
    
    // MARK: - 六維評分算法
    private static func calculateScores(
        life: PalaceData,
        career: PalaceData,
        wealth: PalaceData,
        marriage: PalaceData,
        health: PalaceData
    ) -> DimensionalScores {
        func scorePalace(_ p: PalaceData, base: Double) -> Double {
            var s = base
            for star in p.stars {
                if let b = star.brightness {
                    switch b {
                    case .miao, .wang: s += 5
                    case .de, .li: s += 3
                    case .ping: s += 1
                    case .bu, .xian: s -= 4
                    }
                }
                if star.category == .lucky { s += 4 }
                if star.category == .fierce { s -= 4 }
                if star.natalTransformation == .lu { s += 8 }
                if star.natalTransformation == .quan { s += 6 }
                if star.natalTransformation == .ke { s += 5 }
                if star.natalTransformation == .ji { s -= 6 }
            }
            return min(max(s, 45.0), 96.0)
        }
        
        let pScore = scorePalace(life, base: 78.0)
        let cScore = scorePalace(career, base: 75.0)
        let wScore = scorePalace(wealth, base: 72.0)
        let mScore = scorePalace(marriage, base: 68.0)
        let hScore = scorePalace(health, base: 70.0)
        let overall = (pScore * 0.25) + (cScore * 0.25) + (wScore * 0.2) + (mScore * 0.15) + (hScore * 0.15)
        
        return DimensionalScores(
            overall: round(overall),
            career: round(cScore),
            wealth: round(wScore),
            relationship: round(mScore),
            personality: round(pScore),
            health: round(hScore)
        )
    }
    
    // MARK: - Metis 風格強烈金句標題
    private static func generateHeadline(majorNames: [String], bureau: ElementBureau) -> (String, String) {
        if majorNames.contains("破軍") {
            return ("敢推倒重來，敢走在前頭", "你適合白手起家、在生化風雲變革中開創，不適合安於溫水靜坐不動。")
        }
        if majorNames.contains("七殺") {
            return ("橫刀立馬，開疆拓土的獨行大將", "你具備無畏競爭的決斷力，在動態環境中越挫越勇，成就在於大膽跨界。")
        }
        if majorNames.contains("紫微") {
            return ("定海神針，統率全場的格局之王", "天生自帶威嚴與凝聚力，具備宏觀思維，適合主導大局與帶領團隊。")
        }
        if majorNames.contains("武曲") {
            return ("果敢實幹，百折不撓的金石之質", "行動就是你的最強武器，對金錢與效率有著天生敏銳度，白手成家典範。")
        }
        if majorNames.contains("天機") {
            return ("算無遺策，靈活應變的當代軍師", "心思細膩、洞察先機，靠智力謀略與專業技能取勝，永遠走在時代前沿。")
        }
        if majorNames.contains("太陽") {
            return ("普照四方，慷慨大度的破曉晨曦", "為人熱情正直、富有遠見，在公眾事務或群體中自帶強烈影響力。")
        }
        if majorNames.contains("太陰") {
            return ("潤物無聲，內蘊豐盈的溫柔智者", "心思細密、富有藝術直覺，善於默默耕耘，蓄積深厚的長線福澤。")
        }
        if majorNames.contains("貪狼") {
            return ("八面玲瓏，無界探索的魅力先鋒", "多才多藝、涉獵廣泛，善於調動資源與掌握人心，生活永遠充滿可能性。")
        }
        if majorNames.contains("天府") {
            return ("坐鎮中軍，海納百川的福祿元帥", "處世穩健有度、包容宏大，兼具守成與開創之能，晚景昌隆安逸。")
        }
        return ("順應天時，蓄勢待發的沉著之星", "命格內斂溫厚，循序漸進方顯英雄本色，厚積薄發必有大成。")
    }
    
    // MARK: - 核心優勢、關係、成長
    private static func generateCoreAdvantage(majorNames: [String]) -> String {
        if majorNames.contains("破軍") || majorNames.contains("七殺") {
            return "你膽子大、有執行魄力，開新路不畏艱難，挫敗之後能以驚人速度滿血復活。"
        }
        if majorNames.contains("紫微") || majorNames.contains("天府") {
            return "你有大局觀與領導協調能力，面對混亂場面能沉著冷靜，天然能贏得他人信賴。"
        }
        if majorNames.contains("天機") || majorNames.contains("巨門") {
            return "邏輯分析能力極強，能一眼洞察事物本質與漏洞，靠智慧與策略克敵制勝。"
        }
        return "處事踏實有韌性，善於在平凡中積累不凡，抗風險能力與耐力出類拔萃。"
    }
    
    private static func generateRelationshipPattern(majorNames: [String]) -> String {
        return "對待人際要麼愛恨分明、敢擔責任；一旦認可對方，護起人來拼盡全力，絕不拖泥帶水。"
    }
    
    private static func generateGrowthChallenge(majorNames: [String]) -> String {
        return "衝勁足但有時定力稍缺，折騰時需要朝著明確長線目標聚焦收尾，格局方能真正成形。"
    }
    
    // MARK: - 深度剖析長文
    private static func generateDetailedOverview(majorNames: [String], chart: AstrolabeChart) -> String {
        let starsStr = majorNames.isEmpty ? "命無正曜借對宮" : majorNames.joined(separator: "、")
        return """
        你天生是個具有自我主見與求變意識的人。對老規矩往往有著本能的審視與反思，當別人在按部就班時，你的大腦已經在思考未來的破局點。你的骨子裡有種不服輸的韌勁，在壓力面前往往能爆發出驚人潛力。性格剛正、不喜阿諛奉承，比起表面功夫更注重實質成果與心安理得。
        
        命宮由 \(starsStr) 坐鎮，結合 \(chart.elementBureau.name) 的五行氣場，賦予了你獨特的人生節奏。在年少或起步階段，難免經歷一番摸索與考驗，甚至走過一些看似彎路的修煉；但每一次的推倒重來，都在為你提煉出更加堅固的人生底層邏輯。
        """
    }
    
    private static func generateActionableAdvice(majorNames: [String], chart: AstrolabeChart) -> String {
        return """
        建議你主動跳出舒適圈，靠一門不可替代的專業技術或核心手藝向外闖蕩，這才是你積累深厚籌碼的最佳路徑。做事要有長線思維，認準一個領域至少精雕細琢三年，切忌頻繁換道。把決定權握在自己手裡，遇大事沉得住氣，你的輝煌期必將隨歲月沉澱而燦然大成！
        """
    }
    
    private static func generateOneSentenceVerdict(majorNames: [String]) -> String {
        return "「知世故而不世故，歷千帆仍持初心；敢於破局重來者，終將自成天地。」"
    }
}
