import SwiftUI

public struct VerticalPalaceListView: View {
    public let chart: AstrolabeChart
    public var onSelectPalace: (PalaceData) -> Void
    
    // 預設將命宮、事業、財帛、夫妻排在前面，或依序滾動
    public var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // 1. 頂部水平快速切換快捷導航
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chart.palaces) { palace in
                            Button(action: {
                                HapticManager.triggerSelection()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    proxy.scrollTo(palace.id, anchor: .top)
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
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(palace.isLifePalace ? GhibliTheme.parchmentCard : Color.white.opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(palace.isLifePalace ? GhibliTheme.magicBrass : GhibliTheme.borderBrass.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(GhibliTheme.forestMoss)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(GhibliTheme.parchmentBg)
                
                // 2. 直列卡片資訊流 (垂直滾動，填滿螢幕空間)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        // 命盤總覽鹿兒問候卡
                        headerOverviewCard
                        
                        // 依序展示 12 宮位完整卡片
                        ForEach(chart.palaces) { palace in
                            let interp = PlainLanguageInterpreter.interpret(palace: palace, chart: chart)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                // 卡片頂部欄 (宮位名、地支、大限歲數、特色標籤)
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
                                            
                                            Text(interp.lifeTheme)
                                                .font(GhibliTheme.bodyFont(size: 11))
                                                .foregroundColor(GhibliTheme.magicBrass)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(interp.strengthTag)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(GhibliTheme.calciferOrange)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(GhibliTheme.calciferOrange.opacity(0.12))
                                            .clipShape(Capsule())
                                        
                                        Text("大限 \(palace.decadeStartAge)-\(palace.decadeEndAge)歲")
                                            .font(GhibliTheme.noteFont(size: 10))
                                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.6))
                                    }
                                }
                                
                                Divider()
                                    .background(GhibliTheme.borderBrass.opacity(0.5))
                                
                                // 星曜與四化標籤
                                HStack(spacing: 8) {
                                    if palace.majorStars.isEmpty {
                                        Text("無主星（借對宮星曜照耀，適應力強）")
                                            .font(GhibliTheme.noteFont(size: 12))
                                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                                    } else {
                                        ForEach(palace.majorStars) { star in
                                            HStack(spacing: 3) {
                                                Text(star.name)
                                                    .font(GhibliTheme.titleFont(size: 14))
                                                    .foregroundColor(GhibliTheme.forestMoss)
                                                
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
                                    
                                    Spacer()
                                    
                                    // 點選查閱古籍/天紀深度講義
                                    Button(action: {
                                        HapticManager.triggerImpact(style: .light)
                                        onSelectPalace(palace)
                                    }) {
                                        HStack(spacing: 3) {
                                            Text("天紀古籍")
                                                .font(GhibliTheme.noteFont(size: 10))
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 8))
                                        }
                                        .foregroundColor(GhibliTheme.magicBrass)
                                    }
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
                            .parchmentStyle(isHighlighted: palace.isLifePalace)
                            .id(palace.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    // 命盤頂部小鹿兒總覽歡迎卡
    private var headerOverviewCard: some View {
        HStack(spacing: 12) {
            CuteDeerMascotView(size: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("小鹿兒為你解盤")
                        .font(GhibliTheme.titleFont(size: 16))
                        .foregroundColor(GhibliTheme.forestMoss)
                    Spacer()
                    Text(chart.elementBureau.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(GhibliTheme.calciferOrange)
                }
                
                Text("\(chart.gender.rawValue)・\(chart.lunarInfo.baZiString)")
                    .font(GhibliTheme.noteFont(size: 11))
                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.75))
                
                Text("命主：\(chart.lifeMasterStar)  身主：\(chart.bodyMasterStar)  (滑動探索12宮白話解說)")
                    .font(GhibliTheme.noteFont(size: 10))
                    .foregroundColor(GhibliTheme.magicBrass)
            }
        }
        .padding(12)
        .parchmentStyle(isHighlighted: true)
    }
}
