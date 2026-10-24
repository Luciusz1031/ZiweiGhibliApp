import SwiftUI

public struct MetisChartGridView: View {
    public let chart: AstrolabeChart
    @Binding public var selectedBranch: EarthlyBranch?
    
    // 時空階層狀態
    @State private var activeScope: TimelineScope = .natal
    @State private var selectedDecadeIndex: Int = 0
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = 1
    @State private var selectedDay: Int = 1
    
    // Metis 星盤過濾器開關
    @State private var filterMode: String = "三合" // 飛星 / 三合 / 四化
    
    public init(chart: AstrolabeChart, selectedBranch: Binding<EarthlyBranch?>) {
        self.chart = chart
        self._selectedBranch = selectedBranch
    }
    
    public var body: some View {
        let fortuneReading = TimelineFortuneEngine.calculateReading(
            chart: chart,
            scope: activeScope,
            decadeIndex: selectedDecadeIndex,
            selectedYear: selectedYear,
            selectedMonth: selectedMonth,
            selectedDay: selectedDay
        )
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                // 1. 頂部時光階層切換標籤 (本命 / 大限 / 流年 / 小限 / 流月 / 流日)
                timelineScopeTabs
                
                // 2. 時光二級切換器 (年份、大限年齡、月份、日數)
                timelineSubPicker
                
                // 3. 4x4 天圓地方宮格 (Metis 風格配色，自動高亮當前時空焦點宮位)
                grid4x4(highlightedBranch: fortuneReading.highlightedBranch)
                    .padding(.horizontal, 4)
                
                // 4. 時空運勢白話文深度解析與小鹿兒建議卡片 (解決沒有解析說明的問題！)
                timelineReadingCard(reading: fortuneReading)
                    .padding(.horizontal, 8)
                
                // 5. 底部飛星 / 三合 / 四化 過濾切換列
                filterBar
                    .padding(.bottom, 24)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - 1. 時光階層切換標籤
    private var timelineScopeTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(TimelineScope.allCases) { scope in
                    let isSelected = (activeScope == scope)
                    Button(action: {
                        HapticManager.triggerSelection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            activeScope = scope
                        }
                    }) {
                        Text(scope.rawValue)
                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? GhibliTheme.magicBrass : GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .shadow(color: isSelected ? Color.black.opacity(0.12) : Color.clear, radius: 2, y: 1)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
        }
    }
    
    // MARK: - 2. 時光二級切換器
    @ViewBuilder
    private var timelineSubPicker: some View {
        Group {
            switch activeScope {
            case .natal:
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text("當前檢視本命元辰盤・點選周圍十二宮位可查閱倪師《天紀》原著講義")
                        .font(GhibliTheme.noteFont(size: 11))
                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                
            case .decade:
                // 大限十年歲數滾軸
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
                                        .font(.system(size: 11.5, weight: .bold))
                                        .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                    Text(p.type.name)
                                        .font(.system(size: 9.5))
                                        .foregroundColor(isSelected ? GhibliTheme.cloudWhite : GhibliTheme.magicBrass)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isSelected ? GhibliTheme.calciferOrange : GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
            case .annual:
                // 流年年份滾軸 (前後 6 年)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        let currentY = Calendar.current.component(.year, from: Date())
                        ForEach((currentY - 2)...(currentY + 6), id: \.self) { y in
                            let isSelected = (selectedYear == y)
                            Button(action: {
                                HapticManager.triggerSelection()
                                selectedYear = y
                            }) {
                                Text("\(y) 年")
                                    .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(isSelected ? GhibliTheme.calciferOrange : GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
            case .minor:
                Text("小限行運：依生年地支起算，隨實歲流轉反映個人心境氣候")
                    .font(GhibliTheme.noteFont(size: 11))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                    .padding(.horizontal, 10)
                
            case .monthly:
                // 農曆月份選擇器 (正月至十二月)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        let monthNames = ["", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月"]
                        ForEach(1...12, id: \.self) { m in
                            let isSelected = (selectedMonth == m)
                            Button(action: {
                                HapticManager.triggerSelection()
                                selectedMonth = m
                            }) {
                                Text(monthNames[m])
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
            case .daily:
                // 農曆日數選擇器 (初一至三十)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(1...30, id: \.self) { d in
                            let isSelected = (selectedDay == d)
                            Button(action: {
                                HapticManager.triggerSelection()
                                selectedDay = d
                            }) {
                                Text("\(d)日")
                                    .font(.system(size: 10.5, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - 3. 4x4 天圓地方宮格
    @ViewBuilder
    private func grid4x4(highlightedBranch: EarthlyBranch) -> some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let spacing: CGFloat = 3.5
            let cellSize = (totalWidth - (spacing * 3)) / 4.0
            let centerSize = (cellSize * 2) + spacing
            
            VStack(spacing: spacing) {
                // Row 0: 巳(5), 午(6), 未(7), 申(8)
                HStack(spacing: spacing) {
                    cellView(branch: .si, size: cellSize, highlightedBranch: highlightedBranch)
                    cellView(branch: .wu, size: cellSize, highlightedBranch: highlightedBranch)
                    cellView(branch: .wei, size: cellSize, highlightedBranch: highlightedBranch)
                    cellView(branch: .shen, size: cellSize, highlightedBranch: highlightedBranch)
                }
                
                // Middle 2 Rows:
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        cellView(branch: .chen, size: cellSize, highlightedBranch: highlightedBranch)
                        cellView(branch: .mao, size: cellSize, highlightedBranch: highlightedBranch)
                    }
                    .frame(width: cellSize)
                    
                    // 中宮 (METIS 現代風天心)
                    metisCenterHub(size: centerSize)
                        .frame(width: centerSize, height: centerSize)
                    
                    VStack(spacing: spacing) {
                        cellView(branch: .you, size: cellSize, highlightedBranch: highlightedBranch)
                        cellView(branch: .xu, size: cellSize, highlightedBranch: highlightedBranch)
                    }
                    .frame(width: cellSize)
                }
                
                // Row 3: 寅(2), 丑(1), 子(0), 亥(11)
                HStack(spacing: spacing) {
                    cellView(branch: .yin, size: cellSize, highlightedBranch: highlightedBranch)
                    cellView(branch: .chou, size: cellSize, highlightedBranch: highlightedBranch)
                    cellView(branch: .zi, size: cellSize, highlightedBranch: highlightedBranch)
                    cellView(branch: .hai, size: cellSize, highlightedBranch: highlightedBranch)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    // 單個宮位卡片
    @ViewBuilder
    private func cellView(branch: EarthlyBranch, size: CGFloat, highlightedBranch: EarthlyBranch) -> some View {
        let palace = chart.palace(at: branch)
        let isFocused = (highlightedBranch == branch)
        
        ZStack {
            PalaceCardView(
                palace: palace,
                isSelected: (selectedBranch == branch),
                onTap: { selectedBranch = branch }
            )
            
            // 當前時空焦點宮位外圈光暈標記
            if isFocused {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(GhibliTheme.calciferOrange, lineWidth: 2.2)
                    .shadow(color: GhibliTheme.calciferOrange.opacity(0.4), radius: 3)
            }
        }
        .frame(width: size, height: size)
    }
    
    // MARK: - 4. 時空運勢白話文深度解析與小鹿兒建議卡片 (核心解決沒有說明問題！)
    @ViewBuilder
    private func timelineReadingCard(reading: TimelineFortuneReading) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 標頭欄
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("【\(reading.scope.rawValue)】時空運勢")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(GhibliTheme.forestMoss)
                        
                        Text(reading.palaceName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(GhibliTheme.spiritPurple)
                            .clipShape(Capsule())
                    }
                    Text(reading.currentFocusText)
                        .font(GhibliTheme.noteFont(size: 11))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                // 坐鎮星曜
                VStack(alignment: .trailing, spacing: 1) {
                    Text("焦點星曜")
                        .font(GhibliTheme.noteFont(size: 9))
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text(reading.starsDisplay)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(GhibliTheme.calciferOrange)
                        .lineLimit(1)
                }
            }
            
            Divider()
            
            // 主標題
            Text(reading.headline)
                .font(GhibliTheme.titleFont(size: 16))
                .foregroundColor(GhibliTheme.forestMoss)
            
            // 白話詳細運勢走向
            Text(reading.plainOverview)
                .font(GhibliTheme.bodyFont(size: 13))
                .foregroundColor(GhibliTheme.forestMoss.opacity(0.92))
                .lineSpacing(4)
            
            // 🌟 機遇與利好
            VStack(alignment: .leading, spacing: 5) {
                Text("🌟 時空機遇與利好：")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(GhibliTheme.forestMoss)
                
                ForEach(reading.opportunities, id: \.self) { opp in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(GhibliTheme.magicBrass)
                        Text(opp)
                            .font(GhibliTheme.bodyFont(size: 12))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.6))
            .cornerRadius(8)
            
            // ⚠️ 避坑提醒
            if !reading.precautions.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("⚠️ 需留意的暗礁與避坑：")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(GhibliTheme.calciferOrange)
                    
                    ForEach(reading.precautions, id: \.self) { pre in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(GhibliTheme.calciferOrange)
                            Text(pre)
                                .font(GhibliTheme.bodyFont(size: 12))
                                .foregroundColor(GhibliTheme.forestMoss)
                        }
                    }
                }
                .padding(10)
                .background(GhibliTheme.calciferOrange.opacity(0.08))
                .cornerRadius(8)
            }
            
            // 🦌 小鹿兒溫馨指引
            HStack(alignment: .top, spacing: 8) {
                CuteDeerMascotView(size: 36)
                Text(reading.fawnAdvice)
                    .font(GhibliTheme.bodyFont(size: 12))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .lineSpacing(3)
            }
            .padding(10)
            .background(GhibliTheme.laputaSky.opacity(0.12))
            .cornerRadius(10)
        }
        .padding(14)
        .parchmentStyle(isHighlighted: true)
    }
    
    // MARK: - 5. 底部過濾切換列
    private var filterBar: some View {
        HStack(spacing: 12) {
            ForEach(["飛星", "三合", "四化"], id: \.self) { filter in
                let isSel = (filterMode == filter)
                Button(action: {
                    HapticManager.triggerImpact(style: .light)
                    filterMode = filter
                }) {
                    Text(filter)
                        .font(.system(size: 11, weight: isSel ? .bold : .medium))
                        .foregroundColor(isSel ? GhibliTheme.magicBrass : GhibliTheme.forestMoss.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(isSel ? GhibliTheme.magicBrass.opacity(0.12) : Color.clear)
                        .cornerRadius(6)
                }
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Metis 風格中宮天心儀表
    @ViewBuilder
    private func metisCenterHub(size: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GhibliTheme.borderBrass.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            
            VStack(spacing: 4) {
                Text(chart.userName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(GhibliTheme.forestMoss)
                
                HStack(spacing: 4) {
                    Text(chart.gender.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(GhibliTheme.forestMoss)
                    Text(chart.elementBureau.name)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(GhibliTheme.calciferOrange)
                    if chart.isUnknownHour {
                        Text("[子時]")
                            .font(.system(size: 9))
                            .foregroundColor(GhibliTheme.spiritPurple)
                    }
                }
                
                Text(chart.lunarInfo.baZiString)
                    .font(.system(size: 9.5, weight: .medium, design: .serif))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(spacing: 8) {
                    Text("命主 \(chart.lifeMasterStar)")
                        .font(.system(size: 9))
                        .foregroundColor(GhibliTheme.spiritPurple)
                    Text("身主 \(chart.bodyMasterStar)")
                        .font(.system(size: 9))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                
                Text("真太陽時 \(String(format: "%+.1f", chart.solarCorrection.totalOffsetMinutes))分")
                    .font(.system(size: 8))
                    .foregroundColor(GhibliTheme.magicBrass)
            }
            .padding(6)
        }
    }
}
