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
                // 1. 維度分頁水平滑動膠囊欄 (Metis 頂部標籤)
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
                                Text(tab)
                                    .font(GhibliTheme.bodyFont(size: 13))
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
                
                // 2. 命宮主星標籤與大標題 (Metis 標題設計)
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
                            Text("[時辰基準：午時]")
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
                
                // 3. 六維雷達圖卡片 (Metis 標誌性雷達圖，完美置中對齊)
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
                
                // 4. 核心三維度卡片 (核心優勢 / 關係模式 / 成長課題)
                VStack(spacing: 10) {
                    advantageRow(icon: "star.fill", title: "核心優勢", text: report.coreAdvantage, color: GhibliTheme.magicBrass)
                    advantageRow(icon: "shield.fill", title: "關係模式", text: report.relationshipPattern, color: GhibliTheme.laputaSky)
                    advantageRow(icon: "chart.line.uptrend.xyaxis", title: "成長課題", text: report.growthChallenge, color: GhibliTheme.calciferOrange)
                }
                .padding(.horizontal, 12)
                
                // 5. 已逢格局 (Matched Patterns)
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
                
                // 6. 當前選中維度深度解讀
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(GhibliTheme.magicBrass)
                        Text("【\(selectedTab)】深度剖析")
                            .font(GhibliTheme.titleFont(size: 17))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                    
                    if let text = report.dimensionReadings[selectedTab] {
                        Text(text)
                            .font(GhibliTheme.bodyFont(size: 14))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.92))
                            .lineSpacing(5)
                    }
                    
                    if selectedTab == "命格總覽" {
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("💡 行動指引與開運路徑：")
                            .font(GhibliTheme.titleFont(size: 14))
                            .foregroundColor(GhibliTheme.forestMoss)
                        
                        Text(report.actionableAdvice)
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                            .lineSpacing(4)
                        
                        // 一句話定調
                        Text(report.oneSentenceVerdict)
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                            .foregroundColor(GhibliTheme.calciferOrange)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(GhibliTheme.calciferOrange.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.top, 4)
                    }
                }
                .padding(14)
                .parchmentStyle(isHighlighted: true)
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            }
            .padding(.top, 6)
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
