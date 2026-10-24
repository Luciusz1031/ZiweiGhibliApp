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

// MARK: - 維度深度解析模型 (子頁面詳細資料)
public struct MetisDimensionDetail: Identifiable, Codable {
    public var id: String { dimensionName }
    public let dimensionName: String
    public let iconName: String
    public let score: Int
    public let ratingText: String
    public let palaceName: String
    public let palaceBranchName: String
    public let majorStarsDisplay: String
    public let transformations: [String]
    public let coreEssence: String
    public let advantages: [String]
    public let blindSpots: [String]
    public let actionStrategies: [String]
    public let luckyFawnTips: String
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
    
    // 各維度完整子頁面深度細節模型
    public let dimensionDetails: [String: MetisDimensionDetail]
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
        
        // 6. 生成各維度深度子頁面細節模型
        let dimensionDetails = generateAllDimensionDetails(
            chart: chart,
            scores: scores,
            life: lifePalace,
            career: careerPalace,
            wealth: wealthPalace,
            marriage: marriagePalace,
            health: healthPalace
        )
        
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
            dimensionReadings: dimensionReadings,
            dimensionDetails: dimensionDetails
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
    
    // MARK: - 生成全維度詳細資料
    private static func generateAllDimensionDetails(
        chart: AstrolabeChart,
        scores: DimensionalScores,
        life: PalaceData,
        career: PalaceData,
        wealth: PalaceData,
        marriage: PalaceData,
        health: PalaceData
    ) -> [String: MetisDimensionDetail] {
        var dict: [String: MetisDimensionDetail] = [:]
        
        let friendsPalace = chart.palaces.first { $0.type == .friends } ?? life
        let propertyPalace = chart.palaces.first { $0.type == .property } ?? life
        let parentsPalace = chart.palaces.first { $0.type == .parents } ?? life
        
        func formatStars(_ p: PalaceData) -> String {
            let list = p.majorStars.map { "\($0.name)\($0.brightness != nil ? "[\($0.brightness!.rawValue)]" : "")" }
            return list.isEmpty ? "借對宮吉星拱照" : list.joined(separator: "、")
        }
        
        func formatTransformations(_ p: PalaceData) -> [String] {
            return p.stars.compactMap {
                if let tf = $0.natalTransformation {
                    return "\($0.name)化\(tf.rawValue)"
                }
                return nil
            }
        }
        
        // 1. 財富
        dict["財富"] = MetisDimensionDetail(
            dimensionName: "財富",
            iconName: "dollarsign.circle.fill",
            score: Int(scores.wealth),
            ratingText: scores.wealth >= 85 ? "財源亨通・多元吸金體質" : "穩健蓄財・技術致富格局",
            palaceName: "財帛宮",
            palaceBranchName: "\(wealth.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(wealth),
            transformations: formatTransformations(wealth),
            coreEssence: "以 \(formatStars(wealth)) 為求財根基。你的賺錢邏輯不靠道聽途說的盲目投機，而是靠個人無可替代的專業技術、獨特商業嗅覺與穩步累積，方能水到渠成。",
            advantages: [
                "具備極佳的價值嗅覺，擅長將專業知識或技能轉化為穩定現金流。",
                "抗風險能力佳，在大環境動盪時懂得提前守住流動性資金。",
                "正財根基紮實，中年後複利累積效應越發顯著。"
            ],
            blindSpots: [
                "人情開銷或因抹不開面子而幫他人代墊墊款，易產生隱形損失。",
                "切忌高槓桿投機短炒，穩紮穩打才是守成良方。"
            ],
            actionStrategies: [
                "將每月結餘固定分配至不動產或指數型穩健資產中，遠離高風險誘惑。",
                "深耕本業關鍵壁壘，持續提升個人單位時間價值。"
            ],
            luckyFawnTips: "小鹿兒招財錦囊：在皮夾常備一張嶄新開運金鈔，日常多穿搭深綠、駝色系衣飾，財氣最聚！"
        )
        
        // 2. 事業
        dict["事業"] = MetisDimensionDetail(
            dimensionName: "事業",
            iconName: "briefcase.fill",
            score: Int(scores.career),
            ratingText: scores.career >= 85 ? "大將之風・開疆拓土先鋒" : "中流砥柱・核心骨幹骨相",
            palaceName: "官祿宮",
            palaceBranchName: "\(career.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(career),
            transformations: formatTransformations(career),
            coreEssence: "官祿宮坐鎮 \(formatStars(career))，職場自帶擔當與執行力。適合在需要獨立決策、戰略規劃或核心技術的舞台發揮長才，越早獨當一面越容易成器。",
            advantages: [
                "遇突發難題沉著果斷，能在混亂中理出清晰執行線路。",
                "對效率與成果高度負責，極容易獲得高層與合作夥伴信賴。",
                "勇於革新與優化流程，是推動組織向前變革的靈魂人物。"
            ],
            blindSpots: [
                "過於求好心切時容易事必躬親，導致自身精疲力竭。",
                "對下屬或隊友期望過高，需多留給他人犯錯成長的空間。"
            ],
            actionStrategies: [
                "學會授權分工，將精力聚焦於最高價值的戰略方向與人脈樞紐。",
                "定期梳理個人職場作品集與里程碑，建立個人品牌聲量。"
            ],
            luckyFawnTips: "小鹿兒事業錦囊：辦公桌左手邊擺放一盆生機盎然的常青綠植，能為你帶來貴人助力與清晰思路！"
        )
        
        // 3. 感情
        dict["感情"] = MetisDimensionDetail(
            dimensionName: "感情",
            iconName: "heart.fill",
            score: Int(scores.relationship),
            ratingText: scores.relationship >= 85 ? "情深意篤・心靈共鳴伴侶" : "相互扶持・並肩作戰良緣",
            palaceName: "夫妻宮",
            palaceBranchName: "\(marriage.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(marriage),
            transformations: formatTransformations(marriage),
            coreEssence: "夫妻宮由 \(formatStars(marriage)) 守護。你在親密關係中重視的是精神層面的深度對話與三觀契合，比起海誓山盟，你更珍惜患難與共、平淡真實的默契溫暖。",
            advantages: [
                "對感情專一真誠，一旦認定對方願意傾力守護與付出。",
                "擅長在日常細節中照顧伴侶感受，給予實質安全感。",
                "遇分歧時願以家庭大局為重，具備成熟的包容度。"
            ],
            blindSpots: [
                "有時習慣將煩惱悶在心裡自己扛，容易讓伴侶感到疏離。",
                "說話過於耿直講理，感情相處更需要柔軟共情與溫暖擁抱。"
            ],
            actionStrategies: [
                "每週安排專屬約會夜，放下手機，純粹分享生活趣事與心情。",
                "多用正面肯定句代替批評建議，讚美能化解一切冰霜。"
            ],
            luckyFawnTips: "小鹿兒姻緣錦囊：臥室擺放柔和暖色系床頭夜燈，多噴點溫馨木質調香氛，良緣自然甜甜蜜蜜！"
        )
        
        // 4. 性格
        dict["性格"] = MetisDimensionDetail(
            dimensionName: "性格",
            iconName: "person.crop.circle.fill",
            score: Int(scores.personality),
            ratingText: "自尊獨立・內蘊剛毅之質",
            palaceName: "命宮 (本命元辰)",
            palaceBranchName: "\(life.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(life),
            transformations: formatTransformations(life),
            coreEssence: "以 \(formatStars(life)) 為人格內核。你天生具有鮮明的主見與抗壓韌性，外表或許溫文儒雅，但內心自有一套不可動搖的原則與價值尺度。",
            advantages: [
                "挫敗復原力極強，在逆境中往往能激發出超乎常人的爆發力。",
                "知世故而不世故，珍惜真誠朋友，不屑於虛偽迎合。",
                "自省能力高，能不斷在實踐中進化升級思維格局。"
            ],
            blindSpots: [
                "容易因自我要求過高而陷入精神內耗，需學會放過自己。",
                "防備心較重，初期不容易輕易向他人打開心扉。"
            ],
            actionStrategies: [
                "每天留給自己 15 分鐘放空靜心，與內在的小孩好好對話。",
                "接受不完美是人生的常態，七分奮鬥、三分隨緣最自在。"
            ],
            luckyFawnTips: "小鹿兒開運錦囊：晨起喝一杯溫開水，面向陽光深呼吸三次，喚醒元辰神清氣爽！"
        )
        
        // 5. 健康
        dict["健康"] = MetisDimensionDetail(
            dimensionName: "健康",
            iconName: "cross.fill",
            score: Int(scores.health),
            ratingText: scores.health >= 85 ? "元氣充沛・筋骨強健之態" : "調和陰陽・養生蓄力時期",
            palaceName: "疾厄宮",
            palaceBranchName: "\(health.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(health),
            transformations: formatTransformations(health),
            coreEssence: "疾厄宮坐鎮 \(formatStars(health))。平日精力充沛，但需預防過度透支身體。你的健康關鍵在於情緒壓力疏導與順應四季的作息節律。",
            advantages: [
                "身體自我修復力佳，平時注意養生便能長久維持健康狀態。",
                "對身體信號相對敏感，能及時察覺不適並調整生活節奏。"
            ],
            blindSpots: [
                "工作投入時易忘記喝水與走動，久坐易引發肩頸腰背緊繃。",
                "晚餐時間若不規律，容易對消化系統產生額外負擔。"
            ],
            actionStrategies: [
                "培養每週 2-3 次流汗運動（如慢跑、游泳、健走），促進代謝。",
                "睡前 30 分鐘關閉 3C 藍光螢幕，聽輕柔白噪音有助深度睡眠。"
            ],
            luckyFawnTips: "小鹿兒養生錦囊：隨身攜帶溫水保溫杯，多喝溫潤花草茶，脾胃溫暖人就長壽！"
        )
        
        // 6. 人際貴人
        dict["人際貴人"] = MetisDimensionDetail(
            dimensionName: "人際貴人",
            iconName: "person.3.fill",
            score: 88,
            ratingText: "高朋滿座・長輩同儕照應",
            palaceName: "交友宮 / 遷移宮",
            palaceBranchName: "\(friendsPalace.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(friendsPalace),
            transformations: formatTransformations(friendsPalace),
            coreEssence: "交友宮呈現 \(formatStars(friendsPalace)) 之相。你的貴人運多出自專業圈層與遠行機遇，以誠待人、言出必行是吸引大咖前輩提攜的致勝法寶。",
            advantages: [
                "自帶親和力與可信度，容易在重要場合結交優質人脈。",
                "為人仗義知恩圖報，身邊總有願意鼎力相助的鐵桿摯友。"
            ],
            blindSpots: [
                "對朋友防備心低，需防範酒肉朋友或居心叵測者的言語誘惑。"
            ],
            actionStrategies: [
                "定期篩選人脈圈，多花時間深耕 5-10 位同頻共振的良師益友。",
                "主動為他人創造價值，善緣如同回力鏢必將豐厚回饋自身。"
            ],
            luckyFawnTips: "小鹿兒人緣錦囊：常懷感恩心，逢年過節主動向長輩前輩發送真誠祝福，貴人運長存！"
        )
        
        // 7. 田宅
        dict["田宅"] = MetisDimensionDetail(
            dimensionName: "田宅",
            iconName: "house.fill",
            score: 89,
            ratingText: "基業安穩・福宅庇蔭後代",
            palaceName: "田宅宮",
            palaceBranchName: "\(propertyPalace.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(propertyPalace),
            transformations: formatTransformations(propertyPalace),
            coreEssence: "田宅宮代表家庭安全感、不動產資產與祖業福蔭。宮內星曜和順，一生中極有機會擁有舒適溫馨、地段優越的理想居所。",
            advantages: [
                "對房屋地段與居家舒適度有極佳品味，置產眼光精準。",
                "居家環境常能為你提供滿滿的充電能量與心靈安定感。"
            ],
            blindSpots: [
                "裝潢修繕時易因追求完美而超支預算，需提前做好規劃。"
            ],
            actionStrategies: [
                "資產累積到一定階段，優先配置穩健地段抗通膨的不動產。",
                "保持家中通風明亮、玄關乾淨無雜物，家肥屋潤氣自華。"
            ],
            luckyFawnTips: "小鹿兒家宅錦囊：客廳擺放圓葉植物或天然水晶礦石，全家人和樂融融福運滿堂！"
        )
        
        // 8. 婚戀
        dict["婚戀"] = dict["感情"]!
        
        // 9. 父母長輩
        dict["父母長輩"] = MetisDimensionDetail(
            dimensionName: "父母長輩",
            iconName: "hands.sparkles.fill",
            score: 86,
            ratingText: "承蒙庇蔭・孝悌福祿隨身",
            palaceName: "父母宮",
            palaceBranchName: "\(parentsPalace.earthlyBranch.name)宮",
            majorStarsDisplay: formatStars(parentsPalace),
            transformations: formatTransformations(parentsPalace),
            coreEssence: "父母宮坐鎮 \(formatStars(parentsPalace))。長輩的家訓與言傳身教是你人生道路上的重要指路明燈，孝順父母乃世間第一大福田。",
            advantages: [
                "自幼承蒙父母長輩關照，家庭觀念深厚而有溫度。",
                "在職場中容易得到年長主管或資深導師的特別青睞。"
            ],
            blindSpots: [
                "偶有兩代觀念代溝，切勿因性急而口出重言傷害長輩。"
            ],
            actionStrategies: [
                "定期致電關心父母生活細節，陪伴是最好的孝順方式。",
                "虛心請教長輩人生閱歷，他們的智慧能幫你避開許多暗坑。"
            ],
            luckyFawnTips: "小鹿兒福報錦囊：多給父母長輩添置保暖舒適衣物，百善孝為先，天地自護持！"
        )
        
        return dict
    }
}
