import Foundation

public class AstrolabeTextReportGenerator {
    
    /// 產生通俗易懂、結構完整的全套命盤白話文解說報告（可一鍵分享至 LINE、微信、Email、備忘錄）
    public static func generateFullReport(for chart: AstrolabeChart) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hant_TW")
        df.dateFormat = "yyyy年MM月dd日 HH:mm"
        
        let birthStr = chart.isUnknownHour ?
            "\(df.string(from: chart.solarDate)) (時辰未定・以子時起盤)" :
            df.string(from: chart.solarDate)
        
        let metisReport = MetisAnalysisEngine.generateReport(for: chart)
        
        var report = """
        🦌【小鹿兒算命・紫微斗數天命全覽報告】
        ━━━━━━━━━━━━━━━━━━━━
        【命主基本資料】
        • 命主姓名：\(chart.userName)（\(chart.gender.rawValue)）
        • 國曆生辰：\(birthStr)
        • 農曆八字：\(chart.lunarInfo.baZiString)
        • 農曆生辰：\(chart.lunarInfo.lunarDateString)
        • 五行局數：\(chart.elementBureau.name)
        • 命宮坐鎮：\(chart.lifePalaceBranch.name)宮（命主：\(chart.lifeMasterStar)）
        • 身宮坐鎮：\(chart.bodyPalaceBranch.name)宮（身主：\(chart.bodyMasterStar)）
        • 流派標準：倪海廈先生《天紀》排盤體系・真太陽時精密校驗
        
        ━━━━━━━━━━━━━━━━━━━━
        ✨【白話核心天命總綱】
        「\(metisReport.headline)」
        \(metisReport.subHeadline)
        
        【天命長篇解讀】
        \(metisReport.detailedOverview)
        
        ━━━━━━━━━━━━━━━━━━━━
        🔮【三大核心天命指引】
        🌟 核心優勢與超能力：
        \(metisReport.coreAdvantage)
        
        🧭 情感與關係互動模式：
        \(metisReport.relationshipPattern)
        
        📈 人生蛻變與成長課題：
        \(metisReport.growthChallenge)
        
        ━━━━━━━━━━━━━━━━━━━━
        🌟【六維天命能量雷達指數】
        • 綜合格局：\(Int(metisReport.scores.overall)) 分
        • 事業突破：\(Int(metisReport.scores.career)) 分
        • 財富累積：\(Int(metisReport.scores.wealth)) 分
        • 感情穩定：\(Int(metisReport.scores.relationship)) 分
        • 個性特質：\(Int(metisReport.scores.personality)) 分
        • 健康元氣：\(Int(metisReport.scores.health)) 分
        
        ━━━━━━━━━━━━━━━━━━━━
        📂【各大維度專屬深度剖析】
        """
        
        let dimensions = ["財富", "事業", "感情", "性格", "健康", "人際貴人", "田宅", "父母長輩"]
        for dim in dimensions {
            if let detail = metisReport.dimensionDetails[dim] {
                report += """
                
                【\(detail.dimensionName)解析】（得分：\(detail.score)分・評級：\(detail.ratingText)）
                • 核心宮位：\(detail.palaceName) (\(detail.palaceBranchName))
                • 坐鎮星曜：\(detail.majorStarsDisplay)
                • 核心天命：\(detail.coreEssence)
                • 天賦優勢：\(detail.advantages.joined(separator: "；"))
                • 避坑提醒：\(detail.blindSpots.joined(separator: "；"))
                • 落地策略：\(detail.actionStrategies.joined(separator: "；"))
                • 小鹿開運：\(detail.luckyFawnTips)
                """
            }
        }
        
        report += "\n\n━━━━━━━━━━━━━━━━━━━━\n"
        report += "📜【十二宮位坐鎮星曜與白話主題】\n"
        for palace in chart.palaces {
            let interp = PlainLanguageInterpreter.interpret(palace: palace, chart: chart)
            let starsStr = palace.majorStars.map { $0.name }.joined(separator: "、")
            let displayStars = starsStr.isEmpty ? "借對宮星曜" : starsStr
            report += "• 【\(palace.type.name)】(\(palace.earthlyBranch.name)宮)：\(displayStars)（\(palace.decadeStartAge)-\(palace.decadeEndAge)歲）\n  ↳ 主題：\(interp.lifeTheme)\n  ↳ 解讀：\(interp.summary)\n"
        }
        
        report += "\n━━━━━━━━━━━━━━━━━━━━\n"
        report += "🏛️【倪海廈《天紀》經典格局匹配】\n"
        if chart.patterns.isEmpty {
            report += "本命格局平正溫和，無極端偏煞，行運以穩健中求進展為上。\n"
        } else {
            for pattern in chart.patterns {
                report += "★【\(pattern.name)】（\(pattern.isAuspicious ? "吉格" : "變局")）\n"
                report += "  描述：\(pattern.description)\n"
                report += "  倪師點評：\(pattern.tianjiComment)\n"
                if !pattern.classicalPoem.isEmpty {
                    report += "  古賦斷訣：\(pattern.classicalPoem)\n"
                }
            }
        }
        
        report += """
        
        ━━━━━━━━━━━━━━━━━━━━
        🦌【小鹿兒開運修心指引】
        \(metisReport.actionableAdvice)
        
        一言定調：\(metisReport.oneSentenceVerdict)
        
        「算命之目的，絕非消極認命，而在於知己知彼，順應天時。人人皆有先天命盤之強弱，然心念一轉，言行即變；言行一變，命運自開。」
        ━━━━━━━━━━━━━━━━━━━━
        本報告由《小鹿兒算命》App 自動運算生成・祝您福祿安康、順遂平安！
        """
        
        return report
    }
}
