import SwiftUI

public struct VerticalPalaceListView: View {
    public let chart: AstrolabeChart
    public var onSelectPalace: (PalaceData) -> Void
    
    // 當前選中的宮位地支 (預設為命宮)
    @State private var selectedBranch: EarthlyBranch
    
    public init(chart: AstrolabeChart, onSelectPalace: @escaping (PalaceData) -> Void) {
        self.chart = chart
        self.onSelectPalace = onSelectPalace
        self._selectedBranch = State(initialValue: chart.lifePalaceBranch)
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // 1. 頂部水平快速切換快捷導航欄
                navigationTabBar(proxy: proxy)
                
                // 2. 直列卡片資訊流 (標準 VStack，確保各宮位節點已載入，精準快速平滑捲動)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        headerOverviewCard
                        
                        ForEach(chart.palaces) { palace in
                            palaceCard(for: palace)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    // MARK: - 頂部水平宮位標籤導航欄
    @ViewBuilder
    private func navigationTabBar(proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chart.palaces) { palace in
                    let isSelected = (selectedBranch == palace.earthlyBranch)
                    Button(action: {
                        HapticManager.triggerSelection()
                        selectedBranch = palace.earthlyBranch
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            proxy.scrollTo(palace.earthlyBranch, anchor: .top)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(PalaceIconHelper.icon(for: palace.type))
                                .font(.system(size: 13))
                            Text(palace.type.name)
                                .font(GhibliTheme.bodyFont(size: 12))
                            
                            if palace.isLifePalace {
                                Text("命")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .background(GhibliTheme.spiritPurple)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? GhibliTheme.magicBrass : GhibliTheme.borderBrass.opacity(0.4), lineWidth: isSelected ? 1.5 : 1)
                                )
                        )
                        .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                        .shadow(color: isSelected ? Color.black.opacity(0.12) : Color.clear, radius: 2, y: 1)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(GhibliTheme.parchmentBg)
    }
    
    // MARK: - 單個宮位卡片
    @ViewBuilder
    private func palaceCard(for palace: PalaceData) -> some View {
        let isCardSelected = (selectedBranch == palace.earthlyBranch)
        let interp = PlainLanguageInterpreter.interpret(palace: palace, chart: chart)
        
        VStack(alignment: .leading, spacing: 10) {
            // 卡片頂部欄 (宮位名、地支、大限歲數、特色標籤)
            palaceHeader(for: palace)
            
            Divider()
            
            // 白話宮位核心定位
            Text(interp.lifeTheme)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundColor(GhibliTheme.forestMoss)
                .lineSpacing(3)
            
            // 宮內主星與星宿標籤
            if !palace.majorStars.isEmpty {
                majorStarsRow(for: palace)
            }
            
            // 白話星曜性格特質
            if !interp.starHighlights.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(interp.starHighlights, id: \.self) { highlight in
                        Text(highlight)
                            .font(GhibliTheme.bodyFont(size: 12))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                            .lineSpacing(2)
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
            }
            
            // 四化白話提醒
            if let transNote = interp.transformationAdvice {
                Text(transNote)
                    .font(GhibliTheme.bodyFont(size: 12))
                    .foregroundColor(GhibliTheme.calciferOrange)
                    .padding(.horizontal, 6)
            }
            
            // 小鹿兒溫馨開運建議對話框
            HStack(alignment: .top, spacing: 8) {
                CuteDeerMascotView(size: 38)
                
                Text(interp.fawnAdvice)
                    .font(GhibliTheme.bodyFont(size: 12))
                    .foregroundColor(GhibliTheme.forestMoss)
                    .lineSpacing(3)
            }
            .padding(8)
            .background(GhibliTheme.laputaSky.opacity(0.12))
            .cornerRadius(10)
        }
        .padding(12)
        .parchmentStyle(isHighlighted: isCardSelected || palace.isLifePalace)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCardSelected ? GhibliTheme.calciferOrange : Color.clear, lineWidth: 2)
        )
        .id(palace.earthlyBranch)
        .onTapGesture {
            HapticManager.triggerImpact(style: .light)
            selectedBranch = palace.earthlyBranch
        }
    }
    
    // MARK: - 宮位卡片標頭
    @ViewBuilder
    private func palaceHeader(for palace: PalaceData) -> some View {
        HStack(alignment: .center) {
            HStack(spacing: 6) {
                Text(PalaceIconHelper.icon(for: palace.type))
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(palace.type.name)
                            .font(GhibliTheme.titleFont(size: 18))
                            .foregroundColor(GhibliTheme.forestMoss)
                        
                        Text("(\(palace.heavenlyStem.name)\(palace.earthlyBranch.name))")
                            .font(GhibliTheme.noteFont(size: 11))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.6))
                        
                        if palace.isLifePalace {
                            Text("本命元辰")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(GhibliTheme.spiritPurple)
                                .clipShape(Capsule())
                        }
                        if palace.isBodyPalace {
                            Text("身宮")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(GhibliTheme.forestMoss)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("大限年齡：\(palace.decadeStartAge) - \(palace.decadeEndAge) 歲")
                        .font(GhibliTheme.noteFont(size: 10))
                        .foregroundColor(GhibliTheme.magicBrass)
                }
            }
            
            Spacer()
            
            // 點選查閱古籍/天紀深度講義
            Button(action: {
                HapticManager.triggerImpact(style: .light)
                selectedBranch = palace.earthlyBranch
                onSelectPalace(palace)
            }) {
                HStack(spacing: 3) {
                    Text("天紀古籍")
                        .font(GhibliTheme.noteFont(size: 10))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8))
                }
                .foregroundColor(GhibliTheme.magicBrass)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(GhibliTheme.magicBrass.opacity(0.1))
                .cornerRadius(6)
            }
        }
    }
    
    // MARK: - 主星列
    @ViewBuilder
    private func majorStarsRow(for palace: PalaceData) -> some View {
        HStack(spacing: 6) {
            ForEach(palace.majorStars) { star in
                HStack(spacing: 2) {
                    Text(star.name)
                        .font(GhibliTheme.titleFont(size: 14))
                        .foregroundColor(GhibliTheme.spiritPurple)
                    
                    if let b = star.brightness {
                        Text(b.rawValue)
                            .font(GhibliTheme.noteFont(size: 9))
                            .foregroundColor(GhibliTheme.magicBrass)
                    }
                    
                    if let tf = star.natalTransformation {
                        TransformationBadge(type: tf)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.7))
                .cornerRadius(6)
            }
        }
    }
    
    // MARK: - 命盤頂部小鹿兒總覽歡迎卡
    private var headerOverviewCard: some View {
        HStack(alignment: .top, spacing: 10) {
            CuteDeerMascotView(size: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("鹿兒為您奉上十二宮解說")
                    .font(GhibliTheme.titleFont(size: 14))
                    .foregroundColor(GhibliTheme.forestMoss)
                
                Text("點選上方任一宮位標籤，即可快速滑動至該宮位！點擊右上方「天紀古籍」可隨時研讀倪師天紀專門講義～")
                    .font(GhibliTheme.bodyFont(size: 11.5))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GhibliTheme.parchmentCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
        )
    }
}
