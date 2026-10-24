import SwiftUI

public struct MetisChartGridView: View {
    public let chart: AstrolabeChart
    @Binding public var selectedBranch: EarthlyBranch?
    
    // Metis 星盤過濾器開關
    @State private var filterMode: String = "三合" // 飛星 / 三合 / 四化
    @State private var activeTimelineTab: String = "本命" // 本命 / 大限 / 流年
    
    public var body: some View {
        VStack(spacing: 6) {
            // 頂部時光階層切換 (本命 / 大限 / 流年 / 流月)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(["本命", "大限", "流年", "小限", "流月", "流日"], id: \.self) { tab in
                        let isSelected = (activeTimelineTab == tab)
                        Button(action: {
                            HapticManager.triggerSelection()
                            activeTimelineTab = tab
                        }) {
                            Text(tab)
                                .font(.system(size: 11, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                )
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
            }
            
            // 4x4 天圓地方宮格 (Metis 風格配色)
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let spacing: CGFloat = 3.5
                let cellSize = (totalWidth - (spacing * 3)) / 4.0
                let centerSize = (cellSize * 2) + spacing
                
                VStack(spacing: spacing) {
                    // Row 0: 巳(5), 午(6), 未(7), 申(8)
                    HStack(spacing: spacing) {
                        cellView(branch: .si, size: cellSize)
                        cellView(branch: .wu, size: cellSize)
                        cellView(branch: .wei, size: cellSize)
                        cellView(branch: .shen, size: cellSize)
                    }
                    
                    // Middle 2 Rows:
                    HStack(spacing: spacing) {
                        VStack(spacing: spacing) {
                            cellView(branch: .chen, size: cellSize)
                            cellView(branch: .mao, size: cellSize)
                        }
                        .frame(width: cellSize)
                        
                        // 中宮 (METIS 現代風天心)
                        metisCenterHub(size: centerSize)
                            .frame(width: centerSize, height: centerSize)
                        
                        VStack(spacing: spacing) {
                            cellView(branch: .you, size: cellSize)
                            cellView(branch: .xu, size: cellSize)
                        }
                        .frame(width: cellSize)
                    }
                    
                    // Row 3: 寅(2), 丑(1), 子(0), 亥(11)
                    HStack(spacing: spacing) {
                        cellView(branch: .yin, size: cellSize)
                        cellView(branch: .chou, size: cellSize)
                        cellView(branch: .zi, size: cellSize)
                        cellView(branch: .hai, size: cellSize)
                    }
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            .padding(.horizontal, 4)
            
            // 底部飛星 / 三合 / 四化 過濾切換列
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(isSel ? GhibliTheme.magicBrass.opacity(0.12) : Color.clear)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(.top, 2)
        }
    }
    
    // 單個宮位
    @ViewBuilder
    private func cellView(branch: EarthlyBranch, size: CGFloat) -> some View {
        let palace = chart.palace(at: branch)
        PalaceCardView(
            palace: palace,
            isSelected: (selectedBranch == branch),
            onTap: { selectedBranch = branch }
        )
        .frame(width: size, height: size)
    }
    
    // Metis 風格中宮天心儀表
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
                // 姓名與 METIS 標誌
                Text(chart.userName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(GhibliTheme.forestMoss)
                
                // 性別與局數
                HStack(spacing: 4) {
                    Text(chart.gender.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(GhibliTheme.forestMoss)
                    Text(chart.elementBureau.name)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(GhibliTheme.calciferOrange)
                    if chart.isUnknownHour {
                        Text("[午時]")
                            .font(.system(size: 9))
                            .foregroundColor(GhibliTheme.spiritPurple)
                    }
                }
                
                // 生辰與八字
                Text(chart.lunarInfo.baZiString)
                    .font(.system(size: 9.5, weight: .medium, design: .serif))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // 命主與身主
                HStack(spacing: 8) {
                    Text("命主 \(chart.lifeMasterStar)")
                        .font(.system(size: 9))
                        .foregroundColor(GhibliTheme.spiritPurple)
                    Text("身主 \(chart.bodyMasterStar)")
                        .font(.system(size: 9))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                
                // 真太陽時
                Text("真太陽時 \(String(format: "%+.1f", chart.solarCorrection.totalOffsetMinutes))分")
                    .font(.system(size: 8))
                    .foregroundColor(GhibliTheme.magicBrass)
            }
            .padding(6)
        }
    }
}
