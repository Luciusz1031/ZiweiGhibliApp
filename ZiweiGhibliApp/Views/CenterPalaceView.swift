import SwiftUI

public struct CenterPalaceView: View {
    public let chart: AstrolabeChart
    public var onOpenPatterns: () -> Void = {}
    public var onOpenSettings: () -> Void = {}
    
    @State private var compassRotation: Double = 0
    
    public var body: some View {
        ZStack {
            // 黃銅復古邊框底襯
            RoundedRectangle(cornerRadius: 16)
                .fill(GhibliTheme.parchmentCard.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(GhibliTheme.magicBrass, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            
            // 核心內容
            VStack(spacing: 5) {
                // 標題與齒輪裝飾
                HStack {
                    Button(action: {
                        HapticManager.triggerImpact(style: .light)
                        onOpenSettings()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13))
                            .foregroundColor(GhibliTheme.magicBrass)
                    }
                    
                    Spacer()
                    
                    Text("天 紀 星 盤")
                        .font(GhibliTheme.titleFont(size: 15))
                        .foregroundColor(GhibliTheme.forestMoss)
                        .tracking(2)
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.triggerImpact(style: .light)
                        onOpenPatterns()
                    }) {
                        Image(systemName: "scroll.fill")
                            .font(.system(size: 13))
                            .foregroundColor(GhibliTheme.calciferOrange)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 6)
                
                // 生辰與造別
                HStack(spacing: 8) {
                    Text(chart.gender.rawValue)
                        .font(GhibliTheme.noteFont(size: 11))
                        .foregroundColor(GhibliTheme.forestMoss)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(GhibliTheme.laputaSky.opacity(0.2))
                        .cornerRadius(6)
                    
                    Text(chart.elementBureau.name)
                        .font(GhibliTheme.bodyFont(size: 12))
                        .foregroundColor(GhibliTheme.calciferOrange)
                        .fontWeight(.bold)
                }
                
                // 農曆四柱八字
                Text(chart.lunarInfo.baZiString)
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(4)
                
                // 命主與身主
                HStack(spacing: 12) {
                    Text("命主：\(chart.lifeMasterStar)")
                        .font(GhibliTheme.noteFont(size: 10))
                        .foregroundColor(GhibliTheme.spiritPurple)
                    
                    Text("身主：\(chart.bodyMasterStar)")
                        .font(GhibliTheme.noteFont(size: 10))
                        .foregroundColor(GhibliTheme.forestMoss)
                }
                
                // 真太陽時校準資訊
                HStack(spacing: 3) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 9))
                        .foregroundColor(GhibliTheme.magicBrass)
                    
                    Text("\(chart.city.name) (偏\(chart.solarCorrection.totalOffsetMinutes >= 0 ? "+" : "")\(String(format: "%.1f", chart.solarCorrection.totalOffsetMinutes))分)")
                        .font(GhibliTheme.noteFont(size: 9))
                        .foregroundColor(GhibliTheme.magicBrass)
                }
                
                // 格局提示標籤按鈕
                if !chart.patterns.isEmpty {
                    Button(action: onOpenPatterns) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 8))
                            Text("檢測到 \(chart.patterns.count) 個天紀格局")
                                .font(GhibliTheme.noteFont(size: 9))
                        }
                        .foregroundColor(GhibliTheme.calciferOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(GhibliTheme.calciferOrange.opacity(0.12))
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 4)
                }
            }
            .padding(6)
        }
    }
}
