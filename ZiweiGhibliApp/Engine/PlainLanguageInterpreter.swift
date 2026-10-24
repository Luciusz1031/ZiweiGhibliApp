import Foundation

public struct PlainPalaceInterpretation {
    public let lifeTheme: String          // 白話核心主題 (例如: 「你的天賦個性與人生超能力」)
    public let summary: String            // 一句話白話總結
    public let starHighlights: [String]   // 各主星的白話特色
    public let transformationAdvice: String? // 四化的白話提醒
    public let fawnAdvice: String         // 小鹿兒的溫馨開運建議
    public let strengthTag: String        // 核心超能力標籤
}

public class PlainLanguageInterpreter {
    
    /// 為指定宮位生成通俗易懂的白話文解說
    public static func interpret(palace: PalaceData, chart: AstrolabeChart) -> PlainPalaceInterpretation {
        let stars = palace.stars
        let majorNames = palace.majorStars.map { $0.name }
        
        let theme = getPalacePlainTheme(type: palace.type)
        let highlights = majorNames.map { getStarPlainPersona(starName: $0) }
        
        let summary = generatePlainSummary(type: palace.type, majorNames: majorNames)
        let transformationAdvice = generateTransformationPlainNote(stars: stars)
        let fawnAdvice = generateFawnAdvice(type: palace.type, majorNames: majorNames, hasJi: stars.contains { $0.natalTransformation == .ji })
        let strengthTag = getPalaceStrengthTag(type: palace.type, majorNames: majorNames)
        
        return PlainPalaceInterpretation(
            lifeTheme: theme,
            summary: summary,
            starHighlights: highlights,
            transformationAdvice: transformationAdvice,
            fawnAdvice: fawnAdvice,
            strengthTag: strengthTag
        )
    }
    
    // MARK: - 宮位白話主題
    public static func getPalacePlainTheme(type: PalaceType) -> String {
        switch type {
        case .life: return "我的天賦個性與本質超能力"
        case .siblings: return "我的手足相處與閨蜜好友圈"
        case .marriage: return "我的理想伴侶特徵與戀愛相處心法"
        case .children: return "我的晚輩緣分與生活創意靈感"
        case .wealth: return "我的財富雷達與吸金賺錢管道"
        case .health: return "我的身體元氣與生活減壓指南"
        case .travel: return "我出門在外、遠行出差的機運氣場"
        case .friends: return "我的職場人脈與同儕社交圈"
        case .career: return "最能讓我發光發熱的事業發展舞台"
        case .property: return "我的家庭安全感與資產理財根基"
        case .happiness: return "讓我內心真正感到放鬆與幸福的充電方式"
        case .parents: return "我的長輩貴人運與父母家庭緣分"
        }
    }
    
    // MARK: - 十四主星現代白話人設
    public static func getStarPlainPersona(starName: String) -> String {
        switch starName {
        case "紫微": return "【紫微星】自帶氣場的領袖風範，自尊心強、格局開闊，天生適合引領團隊。"
        case "天機": return "【天機星】靈活敏銳的智多星軍師，思路清晰、學習力強，點子總是比別人快一步。"
        case "太陽": return "【太陽星】熱情溫暖的光芒發射體，為人慷慨大方、富正義感，樂於照耀身邊所有人。"
        case "武曲": return "【武曲星】雷厲風行的實幹派掌門，說話耿直、行動力極強，對金錢與效率有敏銳嗅覺。"
        case "天同": return "【天同星】福氣滿滿的生活美學家，親和力強、愛好和平，懂得在日常細節中享受美好。"
        case "廉貞": return "【廉貞星】公關手腕高超的策略家，目標明確、敢愛敢恨，自帶強烈自信與個人風格。"
        case "天府": return "【天府星】穩健大度的大掌櫃，擅長守財理財、處事圓融包容，生活講究品質與品味。"
        case "太陰": return "【太陰星】細膩溫柔的療癒系精靈，感知力強、富同理心，有出色的美感與耐心。"
        case "貪狼": return "【貪狼星】多才多藝的人氣社交王，好奇心旺盛、幽默風趣，對新鮮事物永遠充滿熱情。"
        case "巨門": return "【巨門星】觀察力犀利的說服大師，思慮縝密、直覺準確，能靠邏輯與語言贏得眾人信服。"
        case "天相": return "【天相星】優雅得體的金牌秘書長，富有正義感、品味極高，是身邊親友最信任的智囊。"
        case "天梁": return "【天梁星】沉穩罩得住的靠山老大哥，自帶長輩風範、樂於助人，常能在關鍵時刻化險為夷。"
        case "七殺": return "【七殺星】敢拼敢衝的開拓先鋒，獨立果決、不怕困難，在競爭挑戰中往往越挫越勇。"
        case "破軍": return "【破軍星】敢破敢立的創意改革者，不喜墨守成規、敢於冒險創新，擁有驚人的爆發力。"
        default: return "【\(starName)】輔助星曜，能為宮位增添獨特個人魅力與機會。"
        }
    }
    
    // MARK: - 白話一句話總結
    private static func generatePlainSummary(type: PalaceType, majorNames: [String]) -> String {
        if majorNames.isEmpty {
            return "此宮位借對宮星曜照耀，代表這方面發展彈性極大，適應力強，懂得借力使力！"
        }
        let starsStr = majorNames.joined(separator: "與")
        switch type {
        case .life:
            return "你的本命是由 \(starsStr) 掌舵，展現出獨具一格的個人魅力與處世格局！"
        case .marriage:
            return "你的感情世界由 \(starsStr) 守護，理想伴侶多具備這類特質，相處講求互相尊重與心靈共鳴。"
        case .wealth:
            return "你的求財管道受 \(starsStr) 影響，適合發揮自身優勢獲取正財與持續累積。"
        case .career:
            return "你在工作事業上展現 \(starsStr) 的風采，越能發揮這份特質，越容易被重用與看見！"
        default:
            return "在 \(type.name) 方面呈現 \(starsStr) 的鮮明特質，順著特質發展就能游刃有餘。"
        }
    }
    
    // MARK: - 四化的白話提醒
    private static func generateTransformationPlainNote(stars: [StarItem]) -> String? {
        var notes: [String] = []
        for s in stars {
            if let tf = s.natalTransformation {
                switch tf {
                case .lu:
                    notes.append("✨ \(s.name)化祿：像收到幸運紅包！帶來豐沛資源、好人緣與豐盛反饋。")
                case .quan:
                    notes.append("👑 \(s.name)化權：展現領導魄力！有主導權與話語權，適合扛起重任大顯身手。")
                case .ke:
                    notes.append("📜 \(s.name)化科：智慧與名氣發光！容易受到貴人賞識、考運或專業知名度極佳。")
                case .ji:
                    notes.append("🌱 \(s.name)化忌：此處是一份靈魂修煉功課，提醒你多放鬆別鑽牛角尖，順其自然反而更順利！")
                }
            }
        }
        return notes.isEmpty ? nil : notes.joined(separator: "\n")
    }
    
    // MARK: - 小鹿兒的開運小叮嚀
    private static func generateFawnAdvice(type: PalaceType, majorNames: [String], hasJi: Bool) -> String {
        if hasJi {
            return "🦌 小鹿兒悄悄話：此宮位帶有一份宇宙功課，不用緊張喔！當事情不如預期時，請記得先喝杯溫茶深呼吸。放慢腳步、接納不完美，轉個念頭好運就會自然流向你～"
        }
        switch type {
        case .life:
            return "🦌 小鹿兒悄悄話：你的本質是非常有力量的！相信自己的直覺，不用去迎合別人的標準，活出自己的節奏就是最好的開運法。"
        case .wealth:
            return "🦌 小鹿兒悄悄話：賺錢就像在森林中採果子，先專注把自己的專業籃子編織好，豐盛的財富自會滿載而歸！"
        case .marriage:
            return "🦌 小鹿兒悄悄話：好的愛情就像並肩在微風中散步。多傾聽對方的需要，也坦白表達自己的感受，溫暖彼此就是長久的秘密。"
        case .career:
            return "🦌 小鹿兒悄悄話：在工作中多發揮你擅長的事，遇到瓶頸時不妨向身邊前輩請益，你的努力大家其實都默默看在眼裡！"
        case .happiness:
            return "🦌 小鹿兒悄悄話：別忘了給自己的心靈留一片安靜的森林。多接觸大自然、看本好書或聽喜歡的音樂，能幫你充飽靈魂的電！"
        default:
            return "🦌 小鹿兒悄悄話：凡事順應天時、廣結善緣。帶著善良與微笑過生活，幸運星就會一直陪伴在你的左右！"
        }
    }
    
    // MARK: - 超能力標籤
    private static func getPalaceStrengthTag(type: PalaceType, majorNames: [String]) -> String {
        if majorNames.contains("紫微") { return "👑 王者風範" }
        if majorNames.contains("天機") { return "💡 靈活機智" }
        if majorNames.contains("太陽") { return "☀️ 溫暖博愛" }
        if majorNames.contains("武曲") { return "⚔️ 實幹果敢" }
        if majorNames.contains("天同") { return "🌸 福星高照" }
        if majorNames.contains("廉貞") { return "🎯 敏銳策略" }
        if majorNames.contains("天府") { return "🏰 沉穩大氣" }
        if majorNames.contains("太陰") { return "🌙 溫柔敏察" }
        if majorNames.contains("貪狼") { return "🎨 社交魅力" }
        if majorNames.contains("巨門") { return "📢 雄辯口才" }
        if majorNames.contains("天相") { return "🕊️ 正義體面" }
        if majorNames.contains("天梁") { return "🛡️ 庇蔭護佑" }
        if majorNames.contains("七殺") { return "⚡ 勇猛開拓" }
        if majorNames.contains("破軍") { return "🚀 突破創新" }
        return "✨ 靈動百變"
    }
}
