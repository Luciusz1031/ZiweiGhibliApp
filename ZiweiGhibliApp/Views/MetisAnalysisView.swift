import SwiftUI

public struct MetisAnalysisView: View {
    public let chart: AstrolabeChart
    
    @State private var selectedTab: String = "命格總覽"
    
    // Metis 維度標籤清單
    private let dimensionTabs = [
        "命格總覽", "財富", "事業", "感情", "性格", "健康", "人際貴人", "田宅", "婚戀", "父母長輩"
    ]
    
    public var body: some View {
        let report = MetisAnalysisEngine.generateReport(for: chart)
        let lifePalace = chart.palaces[chart.lifePalaceBranch.rawValue]
        
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // 1. 維度分頁水平滑動膠囊欄 (點選立即切換子頁面！)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dimensionTabs, id: \.self) { tab in
                            let isSelected = (selectedTab == tab)
                            Button(action: {
                                HapticManager.triggerSelection()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedTab = tab
                                }
                            }) {
                                HStack(spacing: 4) {
                                    if tab != "命格總覽", let detail = report.dimensionDetails[tab] {
                                        Image(systemName: detail.iconName)
                                            .font(.system(size: 11))
                                    }
                                    Text(tab)
                                        .font(GhibliTheme.bodyFont(size: 13))
                                }
                                .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isSelected ? GhibliTheme.forestMoss : GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                
                // 依據選中的分頁切換主畫面內容
                if selectedTab == "命格總覽" {
                    overviewView(report: report, lifePalace: lifePalace)
                } else if let detail = report.dimensionDetails[selectedTab] {
                    dimensionDetailView(detail: detail)
                }
            }
            .padding(.top, 6)
        }
    }
    
    // MARK: - 命格總覽子視圖
    @ViewBuilder
    private func overviewView(report: MetisAnalysisReport, lifePalace: PalaceData) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // 命宮主星標籤與大標題
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(chart.userName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(GhibliTheme.forestMoss)
                    
                    Text("命宮主星：\(lifePalace.majorStars.map { $0.name }.joined(separator: "・"))")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(GhibliTheme.spiritPurple)
                    
                    if let firstStar = lifePalace.majorStars.first, let b = firstStar.brightness {
                        Text("[\(b.rawValue)地]")
                            .font(.system(size: 10, design: .serif))
                            .foregroundColor(GhibliTheme.magicBrass)
                    }
                    
                    if chart.isUnknownHour {
                        Text("[時辰基準：子時]")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundColor(GhibliTheme.calciferOrange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(GhibliTheme.calciferOrange.opacity(0.12))
                            .cornerRadius(4)
                    }
                }
                
                Text(report.headline)
                    .font(GhibliTheme.titleFont(size: 23))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .padding(.vertical, 2)
                
                Text(report.subHeadline)
                    .font(GhibliTheme.bodyFont(size: 13))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.8))
                    .lineSpacing(3)
            }
            .padding(.horizontal, 14)
            
            // 六維雷達圖卡片 (置中對齊)
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    MetisRadarChartView(scores: report.scores, size: 190)
                    Spacer()
                }
                .padding(.vertical, 4)
                
                Text("六維分數由主星廟旺、吉煞會照與生年四化動態權衡評定")
                    .font(GhibliTheme.noteFont(size: 10))
                    .foregroundColor(Color.gray.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .parchmentStyle(isHighlighted: true)
            .padding(.horizontal, 12)
            
            // 核心三維度卡片
            VStack(spacing: 10) {
                advantageRow(icon: "star.fill", title: "核心優勢", text: report.coreAdvantage, color: GhibliTheme.magicBrass)
                advantageRow(icon: "shield.fill", title: "關係模式", text: report.relationshipPattern, color: GhibliTheme.laputaSky)
                advantageRow(icon: "chart.line.uptrend.xyaxis", title: "成長課題", text: report.growthChallenge, color: GhibliTheme.calciferOrange)
            }
            .padding(.horizontal, 12)
            
            // 已逢天紀格局
            if !chart.patterns.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(GhibliTheme.calciferOrange)
                            .font(.system(size: 12))
                        Text("已逢天紀格局：")
                            .font(GhibliTheme.titleFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(chart.patterns) { p in
                                Text(p.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(p.isAuspicious ? GhibliTheme.calciferOrange : GhibliTheme.spiritPurple)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill((p.isAuspicious ? GhibliTheme.calciferOrange : GhibliTheme.spiritPurple).opacity(0.12))
                                    )
                            }
                        }
                    }
                }
                .padding(12)
                .parchmentStyle()
                .padding(.horizontal, 12)
            }
            
            // 各大維度直覺捷徑清單 (點選任一卡片立即深入該子頁面！)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text("九大命理維度子頁面")
                        .font(GhibliTheme.titleFont(size: 15))
                        .foregroundColor(GhibliTheme.forestMoss)
                    Spacer()
                    Text("點選進入專屬解析")
                        .font(GhibliTheme.noteFont(size: 11))
                        .foregroundColor(Color.gray)
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(["財富", "事業", "感情", "性格", "健康", "人際貴人", "田宅", "婚戀", "父母長輩"], id: \.self) { dim in
                        if let d = report.dimensionDetails[dim] {
                            Button(action: {
                                HapticManager.triggerImpact(style: .light)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedTab = dim
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: d.iconName)
                                        .font(.system(size: 16))
                                        .foregroundColor(GhibliTheme.calciferOrange)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(d.dimensionName)
                                            .font(GhibliTheme.titleFont(size: 13))
                                            .foregroundColor(GhibliTheme.forestMoss)
                                        Text("\(d.score) 分・\(d.palaceName)")
                                            .font(GhibliTheme.noteFont(size: 10))
                                            .foregroundColor(Color.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9))
                                        .foregroundColor(GhibliTheme.magicBrass)
                                }
                                .padding(10)
                                .background(GhibliTheme.parchmentCard)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
            .padding(14)
            .parchmentStyle()
            .padding(.horizontal, 12)
            
            // 命格總覽長篇剖析與行動指引
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text("【命格總覽】深度剖析")
                        .font(GhibliTheme.titleFont(size: 17))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                
                Text(report.detailedOverview)
                    .font(GhibliTheme.bodyFont(size: 14))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.92))
                    .lineSpacing(5)
                
                Divider().padding(.vertical, 4)
                
                Text("💡 行動指引與開運路徑：")
                    .font(GhibliTheme.titleFont(size: 14))
                    .foregroundColor(GhibliTheme.forestMoss)
                
                Text(report.actionableAdvice)
                    .font(GhibliTheme.bodyFont(size: 13))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                    .lineSpacing(4)
                
                Text(report.oneSentenceVerdict)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundColor(GhibliTheme.calciferOrange)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(GhibliTheme.calciferOrange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 4)
            }
            .padding(14)
            .parchmentStyle(isHighlighted: true)
            .padding(.horizontal, 12)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - 專屬子頁面視圖 (點選 財富/事業/感情/健康 等直接顯示此豐富頁面)
    @ViewBuilder
    private func dimensionDetailView(detail: MetisDimensionDetail) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // 頂部維度標題與評分卡片
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Image(systemName: detail.iconName)
                            .font(.system(size: 22))
                            .foregroundColor(GhibliTheme.calciferOrange)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("【\(detail.dimensionName)】專屬命理解析")
                                .font(GhibliTheme.titleFont(size: 18))
                                .foregroundColor(GhibliTheme.forestMoss)
                            Text("對應核心宮位：\(detail.palaceName) (\(detail.palaceBranchName))")
                                .font(GhibliTheme.noteFont(size: 11))
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // 評分氣泡
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(detail.score) 分")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(GhibliTheme.calciferOrange)
                        Text(detail.ratingText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                }
                
                Divider()
                
                // 坐鎮星曜與四化標籤
                HStack(spacing: 6) {
                    Text("坐鎮主星：")
                        .font(GhibliTheme.noteFont(size: 11))
                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                    
                    Text(detail.majorStarsDisplay)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(GhibliTheme.spiritPurple)
                    
                    ForEach(detail.transformations, id: \.self) { tf in
                        Text(tf)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(GhibliTheme.calciferOrange)
                            .cornerRadius(4)
                    }
                }
            }
            .padding(14)
            .parchmentStyle(isHighlighted: true)
            .padding(.horizontal, 12)
            
            // 白話核心本質剖析
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text("白話核心天命定位")
                        .font(GhibliTheme.titleFont(size: 15))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                Text(detail.coreEssence)
                    .font(GhibliTheme.bodyFont(size: 13.5))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.92))
                    .lineSpacing(4)
            }
            .padding(14)
            .parchmentStyle()
            .padding(.horizontal, 12)
            
            // 🌟 天賦優勢與順風管道
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text("🌟 天賦優勢與順風管道")
                        .font(GhibliTheme.titleFont(size: 14))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                
                ForEach(detail.advantages, id: \.self) { adv in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundColor(GhibliTheme.magicBrass)
                            .font(.system(size: 14, weight: .bold))
                        Text(adv)
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(14)
            .parchmentStyle()
            .padding(.horizontal, 12)
            
            // ⚠️ 隱形盲點與避坑提醒
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(GhibliTheme.calciferOrange)
                    Text("⚠️ 隱形盲點與避坑提醒")
                        .font(GhibliTheme.titleFont(size: 14))
                        .foregroundColor(GhibliTheme.calciferOrange)
                }
                
                ForEach(detail.blindSpots, id: \.self) { bs in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundColor(GhibliTheme.calciferOrange)
                            .font(.system(size: 14, weight: .bold))
                        Text(bs)
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(14)
            .parchmentStyle()
            .padding(.horizontal, 12)
            
            // 🎯 落地實戰行動策略
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(GhibliTheme.forestMoss)
                    Text("🎯 落地實戰行動策略")
                        .font(GhibliTheme.titleFont(size: 14))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                
                ForEach(detail.actionStrategies, id: \.self) { act in
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 12))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .padding(.top, 2)
                        Text(act)
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .lineSpacing(2)
                    }
                }
            }
            .padding(14)
            .parchmentStyle()
            .padding(.horizontal, 12)
            
            // 🦌 小鹿兒專屬開運錦囊對話框
            HStack(alignment: .top, spacing: 10) {
                CuteDeerMascotView(size: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("小鹿兒開運錦囊：")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(GhibliTheme.forestMoss)
                    Text(detail.luckyFawnTips)
                        .font(GhibliTheme.bodyFont(size: 12.5))
                        .foregroundColor(GhibliTheme.forestMoss)
                        .lineSpacing(3)
                }
            }
            .padding(12)
            .background(GhibliTheme.laputaSky.opacity(0.12))
            .cornerRadius(12)
            .padding(.horizontal, 12)
            
            // 返回命格總覽按鈕
            Button(action: {
                HapticManager.triggerImpact(style: .light)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    selectedTab = "命格總覽"
                }
            }) {
                HStack {
                    Image(systemName: "arrow.uturn.backward")
                    Text("返回命格總覽")
                }
                .font(GhibliTheme.bodyFont(size: 13))
                .foregroundColor(GhibliTheme.magicBrass)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(GhibliTheme.parchmentCard)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
                )
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 24)
        }
    }
    
    // 核心優勢單行元件
    @ViewBuilder
    private func advantageRow(icon: String, title: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(GhibliTheme.titleFont(size: 13))
                    .foregroundColor(color)
                Text(text)
                    .font(GhibliTheme.bodyFont(size: 13))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .lineSpacing(2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .parchmentStyle()
    }
}
