import SwiftUI

public enum LuckMode: String, CaseIterable, Identifiable {
    case natal = "本命盤"
    case decade = "大限運"
    case annual = "流年運"
    
    public var id: String { rawValue }
}

public struct TimeSliderView: View {
    @Binding public var currentMode: LuckMode
    @Binding public var selectedDecadeIndex: Int? // 0..11
    @Binding public var selectedYear: Int        // e.g. 2026
    
    public let chart: AstrolabeChart
    
    public var body: some View {
        VStack(spacing: 8) {
            // 模式切換按鈕
            HStack(spacing: 6) {
                ForEach(LuckMode.allCases) { mode in
                    Button(action: {
                        HapticManager.triggerImpact(style: .light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            currentMode = mode
                        }
                    }) {
                        Text(mode.rawValue)
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(currentMode == mode ? .white : GhibliTheme.forestMoss)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(currentMode == mode ? GhibliTheme.magicBrass : GhibliTheme.parchmentCard)
                                    .shadow(color: currentMode == mode ? GhibliTheme.magicBrass.opacity(0.3) : .clear, radius: 3)
                            )
                    }
                }
            }
            
            // 模式對應的時間輪軸
            Group {
                switch currentMode {
                case .natal:
                    Text("當前檢視本命盤・點選周圍十二宮位可查閱倪師《天紀》詳細斷語")
                        .font(GhibliTheme.noteFont(size: 11))
                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.8))
                        .padding(.vertical, 4)
                    
                case .decade:
                    decadeScroller
                    
                case .annual:
                    annualScroller
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(GhibliTheme.parchmentBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
                )
        )
    }
    
    // 大限滑動選擇器
    private var decadeScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<12, id: \.self) { idx in
                    let p = chart.palaces[idx]
                    let isSelected = (selectedDecadeIndex == idx)
                    Button(action: {
                        HapticManager.triggerSelection()
                        selectedDecadeIndex = idx
                    }) {
                        VStack(spacing: 2) {
                            Text("\(p.decadeStartAge)-\(p.decadeEndAge)歲")
                                .font(GhibliTheme.titleFont(size: 12))
                                .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                            Text(p.type.name)
                                .font(GhibliTheme.noteFont(size: 10))
                                .foregroundColor(isSelected ? GhibliTheme.cloudWhite : GhibliTheme.magicBrass)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // 流年滑動選擇器
    private var annualScroller: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = Array((currentYear - 2)...(currentYear + 7))
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(years, id: \.self) { year in
                    let isSelected = (selectedYear == year)
                    let (stem, branch) = ChineseCalendarHelper.calculateDayStemBranch(for: Calendar.current.date(from: DateComponents(year: year, month: 6, day: 1))!)
                    
                    Button(action: {
                        HapticManager.triggerSelection()
                        selectedYear = year
                    }) {
                        VStack(spacing: 2) {
                            Text("\(year)年")
                                .font(GhibliTheme.titleFont(size: 12))
                                .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                            Text("\(stem.name)\(branch.name)歲次")
                                .font(GhibliTheme.noteFont(size: 9))
                                .foregroundColor(isSelected ? GhibliTheme.cloudWhite : GhibliTheme.calciferOrange)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? GhibliTheme.calciferOrange : GhibliTheme.parchmentCard)
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
