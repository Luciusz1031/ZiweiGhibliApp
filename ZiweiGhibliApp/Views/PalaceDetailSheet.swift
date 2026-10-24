import SwiftUI

public struct PalaceDetailSheet: View {
    public let palace: PalaceData
    public let chart: AstrolabeChart
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ZStack {
                GhibliTheme.parchmentBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. 宮位頂部標題卷軸
                        VStack(spacing: 6) {
                            HStack {
                                Text("\(palace.heavenlyStem.name)\(palace.earthlyBranch.name)位・\(palace.type.name)")
                                    .font(GhibliTheme.titleFont(size: 22))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                
                                if palace.isLifePalace {
                                    Text("本命元辰")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(GhibliTheme.spiritPurple)
                                        .clipShape(Capsule())
                                }
                                if palace.isBodyPalace {
                                    Text("身宮寄託")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(GhibliTheme.forestMoss)
                                        .clipShape(Capsule())
                                }
                            }
                            
                            Text("大限年齡行運：\(palace.decadeStartAge) 歲 至 \(palace.decadeEndAge) 歲")
                                .font(GhibliTheme.bodyFont(size: 13))
                                .foregroundColor(GhibliTheme.magicBrass)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .parchmentStyle(isHighlighted: true)
                        
                        // 2. 小鹿兒白話解說專區
                        let interp = PlainLanguageInterpreter.interpret(palace: palace, chart: chart)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                CuteDeerMascotView(size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("小鹿兒白話生活解讀")
                                        .font(GhibliTheme.titleFont(size: 16))
                                        .foregroundColor(GhibliTheme.forestMoss)
                                    Text(interp.lifeTheme)
                                        .font(GhibliTheme.noteFont(size: 11))
                                        .foregroundColor(GhibliTheme.magicBrass)
                                }
                            }
                            
                            Text(interp.summary)
                                .font(GhibliTheme.bodyFont(size: 13))
                                .foregroundColor(GhibliTheme.forestMoss)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.6))
                                .cornerRadius(8)
                            
                            ForEach(interp.starHighlights, id: \.self) { h in
                                Text(h)
                                    .font(GhibliTheme.bodyFont(size: 12))
                                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                            }
                            
                            if let trans = interp.transformationAdvice {
                                Text(trans)
                                    .font(GhibliTheme.bodyFont(size: 12))
                                    .foregroundColor(GhibliTheme.calciferOrange)
                            }
                            
                            Text(interp.fawnAdvice)
                                .font(GhibliTheme.bodyFont(size: 12))
                                .foregroundColor(GhibliTheme.forestMoss)
                                .padding(10)
                                .background(GhibliTheme.laputaSky.opacity(0.15))
                                .cornerRadius(10)
                        }
                        .padding()
                        .parchmentStyle(isHighlighted: true)
                        
                        // 3. 星曜陣容解析
                        VStack(alignment: .leading, spacing: 10) {
                            Text("駐留星曜與廟旺神煞")
                                .font(GhibliTheme.titleFont(size: 16))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            ForEach(palace.stars) { star in
                                HStack {
                                    Text(star.name)
                                        .font(GhibliTheme.bodyFont(size: 15))
                                        .foregroundColor(starColor(for: star))
                                        .fontWeight(.bold)
                                    
                                    if let b = star.brightness {
                                        Text("(\(b.rawValue))")
                                            .font(GhibliTheme.noteFont(size: 12))
                                            .foregroundColor(GhibliTheme.magicBrass)
                                    }
                                    
                                    Spacer()
                                    
                                    if let ntf = star.natalTransformation {
                                        HStack(spacing: 2) {
                                            TransformationBadge(type: ntf)
                                            Text("生年\(ntf.fullName)")
                                                .font(GhibliTheme.noteFont(size: 11))
                                                .foregroundColor(GhibliTheme.calciferOrange)
                                        }
                                    }
                                }
                                .padding(.vertical, 3)
                                Divider()
                            }
                        }
                        .padding()
                        .parchmentStyle()
                        
                        // 3. 倪海廈《天紀》論宮精要
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(GhibliTheme.magicBrass)
                                Text("倪海廈《天紀》心法指南")
                                    .font(GhibliTheme.titleFont(size: 16))
                                    .foregroundColor(GhibliTheme.forestMoss)
                            }
                            
                            Text(getTianjiPalaceAdvice(palace: palace))
                                .font(GhibliTheme.bodyFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                                .lineSpacing(4)
                        }
                        .padding()
                        .parchmentStyle()
                        
                        // 4. 三方四正會照宮位
                        VStack(alignment: .leading, spacing: 8) {
                            Text("三方四正照會關係")
                                .font(GhibliTheme.titleFont(size: 16))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            let (opposite, trine1, trine2) = getSanFangBranches(for: palace.earthlyBranch)
                            Text("• 對宮 (遷移沖照)：\(chart.palace(at: opposite).earthlyBranch.name)宮 [\(chart.palace(at: opposite).type.name)]")
                            Text("• 三合會照一：\(chart.palace(at: trine1).earthlyBranch.name)宮 [\(chart.palace(at: trine1).type.name)]")
                            Text("• 三合會照二：\(chart.palace(at: trine2).earthlyBranch.name)宮 [\(chart.palace(at: trine2).type.name)]")
                        }
                        .font(GhibliTheme.bodyFont(size: 13))
                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                        .padding()
                        .parchmentStyle()
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(GhibliTheme.forestMoss)
                }
            }
        }
    }
    
    private func starColor(for star: StarItem) -> Color {
        switch star.category {
        case .major: return GhibliTheme.forestMoss
        case .lucky: return Color(red: 0.15, green: 0.45, blue: 0.25)
        case .fierce: return GhibliTheme.tabooRed
        default: return GhibliTheme.spiritPurple
        }
    }
    
    private func getSanFangBranches(for branch: EarthlyBranch) -> (opposite: EarthlyBranch, trine1: EarthlyBranch, trine2: EarthlyBranch) {
        let opp = EarthlyBranch(rawValue: (branch.rawValue + 6) % 12)!
        let t1 = EarthlyBranch(rawValue: (branch.rawValue + 4) % 12)!
        let t2 = EarthlyBranch(rawValue: (branch.rawValue + 8) % 12)!
        return (opp, t1, t2)
    }
    
    private func getTianjiPalaceAdvice(palace: PalaceData) -> String {
        if palace.isLifePalace {
            return "倪師《天紀》曰：命宮為先天性格與一生之根基。若逢吉星入廟，天性開朗自立；若逢煞曜，則為砥礪奮發之動力。天紀強調『心態改則命運改』，識得本性方能順應天道。"
        }
        switch palace.type {
        case .marriage:
            return "倪師論夫妻宮：婚姻乃相處之道。看夫妻宮須同時兼看對宮官祿與福德宮。若逢化忌，不可輕言離異，當以禮敬修身，晚婚或各自保有事業空間為上策化解之道。"
        case .wealth:
            return "倪師論財帛宮：財宮看進財之渠道與理財之格局。祿存入財多主善積蓄；武曲入財善經營金融；貪狼化祿利橫財偏門。天紀云：聚財當行善，厚德方能載物。"
        case .career:
            return "倪師論官祿宮：看個人事業傾向與社會成就。七殺、破軍坐官祿利開拓白手起家；天梁、天相利公職技術輔政。順應星曜特質擇業，自能事半功倍。"
        default:
            return "《天紀》心法：宮位非死板吉凶，吉中藏凶、凶中見吉。四化飛星與大限流年如四時輪替，春夏耕耘、秋冬收藏，把握時機方為智者。"
        }
    }
}
