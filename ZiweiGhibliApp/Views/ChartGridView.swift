import SwiftUI

public struct ChartGridView: View {
    public let chart: AstrolabeChart
    @Binding public var selectedBranch: EarthlyBranch?
    public var onOpenPatterns: () -> Void = {}
    public var onOpenSettings: () -> Void = {}
    
    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let spacing: CGFloat = 4
            let cellSize = (totalWidth - (spacing * 3)) / 4.0
            let centerSize = (cellSize * 2) + spacing
            
            VStack(spacing: spacing) {
                // 第一列 (Top): 巳(5), 午(6), 未(7), 申(8)
                HStack(spacing: spacing) {
                    palaceView(branch: .si, size: cellSize)
                    palaceView(branch: .wu, size: cellSize)
                    palaceView(branch: .wei, size: cellSize)
                    palaceView(branch: .shen, size: cellSize)
                }
                
                // 中間兩列 (Middle 2 rows with Center 2x2):
                HStack(spacing: spacing) {
                    // 左側兩宮 (辰4 在上, 卯3 在下)
                    VStack(spacing: spacing) {
                        palaceView(branch: .chen, size: cellSize)
                        palaceView(branch: .mao, size: cellSize)
                    }
                    .frame(width: cellSize)
                    
                    // 中宮 (天心 2x2 區域)
                    CenterPalaceView(
                        chart: chart,
                        onOpenPatterns: onOpenPatterns,
                        onOpenSettings: onOpenSettings
                    )
                    .frame(width: centerSize, height: centerSize)
                    
                    // 右側兩宮 (酉9 在上, 戌10 在下)
                    VStack(spacing: spacing) {
                        palaceView(branch: .you, size: cellSize)
                        palaceView(branch: .xu, size: cellSize)
                    }
                    .frame(width: cellSize)
                }
                
                // 第四列 (Bottom): 寅(2), 丑(1), 子(0), 亥(11)
                HStack(spacing: spacing) {
                    palaceView(branch: .yin, size: cellSize)
                    palaceView(branch: .chou, size: cellSize)
                    palaceView(branch: .zi, size: cellSize)
                    palaceView(branch: .hai, size: cellSize)
                }
            }
            .frame(width: totalWidth)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    @ViewBuilder
    private func palaceView(branch: EarthlyBranch, size: CGFloat) -> some View {
        let palace = chart.palace(at: branch)
        PalaceCardView(
            palace: palace,
            isSelected: (selectedBranch == branch),
            onTap: {
                selectedBranch = branch
            }
        )
        .frame(width: size, height: size)
    }
}
