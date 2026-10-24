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
            let starsStr = p.majorStars.map { "\($0.name)\($0.brightness != nil ? "[\($0.brightness!.rawValue)]" : "")" }.joined(separator: "、")
            let displayStars = starsStr.isEmpty ? "命無正曜 (借對宮吉星照耀)" : starsStr
            
            return TimelineFortuneReading(
                scope: .natal,
                currentFocusText: "本命元辰（終身核心能量軸）",
                targetPalace: p,
                palaceName: "本命宮 (\(p.earthlyBranch.name)宮)",
                starsDisplay: displayStars,
                headline: "立足本心，終身格局之定海神針",
                plainOverview: """
                本命盤是你一生的性格基石、天賦超能力與格局上限。你的本命由 \(displayStars) 鎮守，代表你天生具備獨立審視與開拓進取的勇氣。在人生長河中，無論外在運勢如何起伏，你的核心原則與處世格局都是你最厚實的底牌。只要發揮本質優勢，定能開創出屬於自己的天地！
                """,
                opportunities: [
                    "天生自帶敏銳判斷力與獨立思維，不隨波逐流。",
                    "能將專業知識轉化為實質成就，中年後福澤深厚。",
                    "貴人運長久相隨，關鍵時刻總有長輩與朋友相助。"
                ],
                precautions: [
                    "求好心切時容易給自己過大壓力，需保持身心平衡。",
                    "面對不同意見多點傾聽與包容，溝通更能事半功倍。"
                ],
                fawnAdvice: "小鹿兒溫馨提醒：認同自己的獨特節奏，不急不躁、順心而行，你比想像中更有力量！",
                highlightedBranch: lifeBranch
            )
            
        case .decade:
            let safeIdx = min(max(decadeIndex, 0), 11)
            let p = chart.palaces[safeIdx]
            let starsStr = p.majorStars.map { "\($0.name)\($0.brightness != nil ? "[\($0.brightness!.rawValue)]" : "")" }.joined(separator: "、")
            let displayStars = starsStr.isEmpty ? "借對宮星曜吉光照臨" : starsStr
            
            return TimelineFortuneReading(
                scope: .decade,
                currentFocusText: "\(p.decadeStartAge) - \(p.decadeEndAge) 歲 大限十年運勢走向",
                targetPalace: p,
                palaceName: "大限宮位：\(p.type.name) (\(p.earthlyBranch.name)宮)",
                starsDisplay: displayStars,
                headline: "步入【\(p.type.name)】十年主場，關鍵成長與厚積薄發期",
                plainOverview: """
                在 \(p.decadeStartAge) 至 \(p.decadeEndAge) 歲這黃金十年中，你的運勢焦點全神貫注於【\(p.type.name)】所管轄的人生領域。宮內由 \(displayStars) 主導，氣場生機蓬勃。這十年是深耕專業、建立不可替代地位的重要轉折點，適合鎖定長期目標紮實前行。
                """,
                opportunities: [
                    "此大限內事業與人脈資源聚集，能迎來發光發熱的重要舞台。",
                    "個人決策力大幅提升，能獨立承擔重任並贏得信任。",
                    "財庫基石逐漸穩固，適合進行長線穩健的資產規劃。"
                ],
                precautions: [
                    "避免頻繁更換賽道，專注於核心優勢方能結出豐碩果實。",
                    "合約文書與重要合作需字斟句酌，切忌口頭承諾。"
                ],
                fawnAdvice: "小鹿兒大限錦囊：十年磨一劍！只要認準正確方向並持之以恆，時間會給出最美好的回報！",
                highlightedBranch: p.earthlyBranch
            )
            
        case .annual:
            // 計算流年地支 (如 2026 -> 丙午年, 地支為午=6)
            let yearBranchIdx = (selectedYear - 4) % 12
            let normalizedBranchIdx = (yearBranchIdx + 12) % 12
            let annualBranch = EarthlyBranch(rawValue: normalizedBranchIdx)!
            
            let yearStemIdx = (selectedYear - 4) % 10
            let normalizedStemIdx = (yearStemIdx + 10) % 10
            let annualStem = HeavenlyStem(rawValue: normalizedStemIdx)!
            
            let p = chart.palace(at: annualBranch)
            let starsStr = p.majorStars.map { "\($0.name)\($0.brightness != nil ? "[\($0.brightness!.rawValue)]" : "")" }.joined(separator: "、")
            let displayStars = starsStr.isEmpty ? "星曜和順 (對宮星曜借照)" : starsStr
            
            return TimelineFortuneReading(
                scope: .annual,
                currentFocusText: "\(selectedYear) 歲次【\(annualStem.name)\(annualBranch.name)年】流年氣場",
                targetPalace: p,
                palaceName: "流年命宮臨【\(annualBranch.name)宮】(本命\(p.type.name))",
                starsDisplay: displayStars,
                headline: "\(selectedYear) 流年迎來創新變局，乘風破浪展宏圖",
                plainOverview: """
                西曆 \(selectedYear) 年（歲次\(annualStem.name)\(annualBranch.name)），你的流年命宮行至 \(annualBranch.name) 宮，受 \(displayStars) 的牽引。今年外在機會頻繁浮現，動態交流與跨界合作明顯增多，是走出舒適圈、開拓新格局的關鍵一年！
                """,
                opportunities: [
                    "職場上有望接手新專案或被賦予更多主導權限，才華得以展現。",
                    "出外遠行或跨領域交流能結識志同道合的新朋友與貴人。",
                    "進財管道呈現多元化趨勢，利於發展個人第二專長。"
                ],
                precautions: [
                    "行事切忌急功近利，重大投資決策前宜多方驗證數據。",
                    "注意調節作息與放鬆神經，避免熬夜勞累影響元氣。"
                ],
                fawnAdvice: "小鹿兒流年叮嚀：今年出門在外貴人特別多，多微笑、多主動打招呼，好運自然常伴左右！",
                highlightedBranch: annualBranch
            )
            
        case .minor:
            // 小限：依生年地支起算
            let birthBranch = chart.lunarInfo.yearBranch
            let startBranchMap: [EarthlyBranch: EarthlyBranch] = [
                .yin: .chen, .wu: .chen, .xu: .chen,
                .shen: .xu, .zi: .xu, .chen: .xu,
                .si: .wei, .you: .wei, .chou: .wei,
                .hai: .chou, .mao: .chou, .wei: .chou
            ]
            let startBranch = startBranchMap[birthBranch] ?? .chen
            // 年齡小限推算
            let currentYear = Calendar.current.component(.year, from: Date())
            let birthYear = Calendar.current.component(.year, from: chart.solarDate)
            let nominalAge = max(currentYear - birthYear + 1, 1)
            let minorIdx = (startBranch.rawValue + (nominalAge - 1)) % 12
            let minorBranch = EarthlyBranch(rawValue: minorIdx)!
            let p = chart.palace(at: minorBranch)
            
            return TimelineFortuneReading(
                scope: .minor,
                currentFocusText: "實歲 \(nominalAge) 歲 小限心境微氣候",
                targetPalace: p,
                palaceName: "小限宮位：\(minorBranch.name)宮 (本命\(p.type.name))",
                starsDisplay: p.majorStars.map { $0.name }.joined(separator: "、").ifEmpty("借宮和順"),
                headline: "當前年歲聚焦內心調適與步調梳理",
                plainOverview: """
                小限反映你當前歲數的主觀心境感受、健康元氣與日常情緒。小限入【\(minorBranch.name)宮】，提示你這一年在追求目標的同時，更要關注內心的安寧與真實需求，找到生活與奮鬥的甜蜜平衡點。
                """,
                opportunities: [
                    "靈感豐富，適合閱讀、進修或培養一門療癒身心的興趣。",
                    "家庭親友關係溫馨和睦，能為你提供堅實的情感避風港。"
                ],
                precautions: [
                    "偶有胡思亂想或精神疲勞，及時運動放空能迅速排解。",
                    "瑣碎雜事勿往心裡去，放寬心胸自得其樂。"
                ],
                fawnAdvice: "小鹿兒小限錦囊：每天給自己喝一杯溫熱花草茶的時光，溫暖自己，生活便處處美好！",
                highlightedBranch: minorBranch
            )
            
        case .monthly:
            let safeMonth = min(max(selectedMonth, 1), 12)
            // 流月推算 (以流年地支起正月)
            let currentYear = Calendar.current.component(.year, from: Date())
            let yearBranchIdx = (currentYear - 4) % 12
            let monthBranchIdx = (yearBranchIdx + (safeMonth - 1)) % 12
            let monthBranch = EarthlyBranch(rawValue: (monthBranchIdx + 12) % 12)!
            let p = chart.palace(at: monthBranch)
            let monthNames = ["", "正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"]
            let mName = monthNames[safeMonth]
            
            return TimelineFortuneReading(
                scope: .monthly,
                currentFocusText: "農曆 \(mName) 月 流月吉凶氣候",
                targetPalace: p,
                palaceName: "流月宮位：\(monthBranch.name)宮 (本命\(p.type.name))",
                starsDisplay: p.majorStars.map { $0.name }.joined(separator: "、").ifEmpty("吉星拱照"),
                headline: "農曆 \(mName) 月：節奏明快，步步落實",
                plainOverview: """
                農曆 \(mName) 月運勢行至 \(monthBranch.name) 宮。本月你的生活與工作節奏相對俐落，適合將積壓已久的待辦清單一件件踏實清理，執行效率非常高！
                """,
                opportunities: [
                    "本月談判溝通順利，能促成共識與關鍵合作方案落地。",
                    "生活中有小確幸偏財進帳或收到親友贈送的暖心禮物。"
                ],
                precautions: [
                    "忙碌中別忘了按時吃飯，保持充足水分與規律休息。"
                ],
                fawnAdvice: "小鹿兒流月叮嚀：這個月是耕耘收穫期，保持開朗心情，幸運女神就在身邊！",
                highlightedBranch: monthBranch
            )
            
        case .daily:
            let safeDay = min(max(selectedDay, 1), 30)
            let dayBranchIdx = (safeDay - 1) % 12
            let dayBranch = EarthlyBranch(rawValue: dayBranchIdx)!
            let p = chart.palace(at: dayBranch)
            
            return TimelineFortuneReading(
                scope: .daily,
                currentFocusText: "當日流日吉凶氣象（農曆 \(safeDay) 日）",
                targetPalace: p,
                palaceName: "流日值日：\(dayBranch.name)宮 (本命\(p.type.name))",
                starsDisplay: p.majorStars.map { $0.name }.joined(separator: "、").ifEmpty("祥和順暢"),
                headline: "今日氣象和潤，宜決斷關鍵要務",
                plainOverview: """
                今日流日氣場專注於【\(p.type.name)】，直覺靈感與執行力處於極佳狀態。適合安排重要會議、簽署合約或與關鍵夥伴交流，容易取得令人欣喜的進展！
                """,
                opportunities: [
                    "思維敏銳，能迅速找到複雜難題的突破捷徑。",
                    "與人為善收穫滿滿正面回饋，人氣指數持續上升。"
                ],
                precautions: [
                    "今日切忌拖延，想到就做能避免錯過良機。"
                ],
                fawnAdvice: "小鹿兒每日一句：今天是你創造美好記憶的一天，帶著微笑出發吧！",
                highlightedBranch: dayBranch
            )
        }
    }
}

fileprivate extension String {
    func ifEmpty(_ fallback: String) -> String {
        return self.isEmpty ? fallback : self
    }
}
