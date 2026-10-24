import SwiftUI

public struct SynastryView: View {
    public let personA: AstrolabeChart
    
    // 對象 B 的資料狀態 (預設提供一個預設生辰，使用者可隨時點擊修改)
    @State private var partnerDate: Date = Calendar.current.date(from: DateComponents(year: 1996, month: 11, day: 20, hour: 14, minute: 30)) ?? Date()
    @State private var partnerGender: Gender = .female
    @State private var partnerCity: CityLocation = CityDatabase.defaultCity
    @State private var partnerName: String = "對象 / 伴侶"
    @State private var isEditingPartner: Bool = false
    
    public var body: some View {
        // 即時排盤 Person B
        let personB = ZiweiEngine.generateChart(
            birthDate: partnerDate,
            city: partnerCity,
            gender: partnerGender,
            config: personA.config
        )
        
        let synastry = SynastryEngine.analyze(personA: personA, personB: personB)
        
        ScrollView {
            VStack(spacing: 14) {
                // 1. 雙人檔案卡片 (我 vs 對象)
                HStack(spacing: 10) {
                    // 盤主 A
                    VStack(spacing: 4) {
                        Text("我 (盤主)")
                            .font(GhibliTheme.noteFont(size: 11))
                            .foregroundColor(GhibliTheme.magicBrass)
                        Text(personA.gender.rawValue)
                            .font(.system(size: 10))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                        Text(personA.palaces[personA.lifePalaceBranch.rawValue].majorStars.map { $0.name }.joined(separator: "・"))
                            .font(GhibliTheme.titleFont(size: 13))
                            .foregroundColor(GhibliTheme.spiritPurple)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .parchmentStyle(isHighlighted: true)
                    
                    // 愛心連結符號
                    VStack(spacing: 2) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(GhibliTheme.calciferOrange)
                        Text("合盤")
                            .font(GhibliTheme.noteFont(size: 9))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                    
                    // 對象 B
                    Button(action: {
                        HapticManager.triggerImpact(style: .light)
                        isEditingPartner = true
                    }) {
                        VStack(spacing: 4) {
                            HStack(spacing: 2) {
                                Text(partnerName)
                                    .font(GhibliTheme.noteFont(size: 11))
                                    .foregroundColor(GhibliTheme.magicBrass)
                                Image(systemName: "pencil")
                                    .font(.system(size: 8))
                                    .foregroundColor(GhibliTheme.magicBrass)
                            }
                            Text(partnerGender.rawValue)
                                .font(.system(size: 10))
                                .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                            Text(personB.palaces[personB.lifePalaceBranch.rawValue].majorStars.map { $0.name }.joined(separator: "・"))
                                .font(GhibliTheme.titleFont(size: 13))
                                .foregroundColor(GhibliTheme.calciferOrange)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .parchmentStyle()
                    }
                }
                .padding(.horizontal, 14)
                
                // 2. 總體契合度大儀表板
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text("\(synastry.overallScore)")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundColor(GhibliTheme.calciferOrange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("分")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(GhibliTheme.forestMoss)
                            Text(synastry.relationshipType)
                                .font(GhibliTheme.titleFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss)
                        }
                    }
                    
                    Text(synastry.headline)
                        .font(GhibliTheme.bodyFont(size: 13))
                        .foregroundColor(GhibliTheme.magicBrass)
                        .padding(.top, 2)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // 四大契合子維度進度條
                    VStack(spacing: 8) {
                        scoreProgressRow(title: "💖 情感默契", score: synastry.loveScore, color: GhibliTheme.calciferOrange)
                        scoreProgressRow(title: "🌱 價值觀契合", score: synastry.valueScore, color: GhibliTheme.forestMoss)
                        scoreProgressRow(title: "🪙 事業財富互旺", score: synastry.wealthSynergyScore, color: GhibliTheme.magicBrass)
                        scoreProgressRow(title: "💬 溝通包容力", score: synastry.communicationScore, color: GhibliTheme.laputaSky)
                    }
                }
                .padding(14)
                .parchmentStyle(isHighlighted: true)
                .padding(.horizontal, 14)
                
                // 3. 主星磁場碰撞
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(GhibliTheme.calciferOrange)
                        Text("主星磁場碰撞")
                            .font(GhibliTheme.titleFont(size: 16))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                    
                    Text(synastry.starChemistry)
                        .font(GhibliTheme.bodyFont(size: 13))
                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                        .lineSpacing(4)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .parchmentStyle()
                .padding(.horizontal, 14)
                
                // 4. 誰旺誰？四化互入福澤
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(GhibliTheme.magicBrass)
                        Text("誰旺誰？互補福澤")
                            .font(GhibliTheme.titleFont(size: 16))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                    
                    ForEach(synastry.mutualBlessings, id: \.self) { blessing in
                        Text(blessing)
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                            .lineSpacing(2)
                            .padding(.vertical, 2)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .parchmentStyle()
                .padding(.horizontal, 14)
                
                // 5. 磨擦盲點與避坑提醒
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(GhibliTheme.tabooRed)
                        Text("相處盲點與磨合考驗")
                            .font(GhibliTheme.titleFont(size: 16))
                            .foregroundColor(GhibliTheme.forestMoss)
                    }
                    
                    ForEach(synastry.frictionPoints, id: \.self) { point in
                        Text(point)
                            .font(GhibliTheme.bodyFont(size: 12))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                            .lineSpacing(2)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .parchmentStyle()
                .padding(.horizontal, 14)
                
                // 6. 小鹿兒合盤相處秘訣指南
                HStack(alignment: .top, spacing: 10) {
                    CuteDeerMascotView(size: 42)
                    
                    Text(synastry.fawnSynastryAdvice)
                        .font(GhibliTheme.bodyFont(size: 13))
                        .foregroundColor(GhibliTheme.forestMoss)
                        .lineSpacing(4)
                }
                .padding(14)
                .background(GhibliTheme.laputaSky.opacity(0.15))
                .cornerRadius(12)
                .padding(.horizontal, 14)
                .padding(.bottom, 24)
            }
            .padding(.top, 6)
        }
        .sheet(isPresented: $isEditingPartner) {
            partnerInputSheet
        }
    }
    
    // 維度進度條列
    @ViewBuilder
    private func scoreProgressRow(title: String, score: Int, color: Color) -> some View {
        HStack {
            Text(title)
                .font(GhibliTheme.bodyFont(size: 12))
                .foregroundColor(GhibliTheme.forestMoss)
                .frame(width: 110, alignment: .leading)
            
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.18))
                        .frame(height: 7)
                    Capsule()
                        .fill(color)
                        .frame(width: g.size.width * CGFloat(score) / 100.0, height: 7)
                }
            }
            .frame(height: 7)
            
            Text("\(score)%")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .frame(width: 38, alignment: .trailing)
        }
    }
    
    // 對象生辰修改彈窗
    private var partnerInputSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("對象基本資料")) {
                    TextField("對象稱謂/暱稱", text: $partnerName)
                    Picker("性別", selection: $partnerGender) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    DatePicker("出生日期", selection: $partnerDate, displayedComponents: [.date])
                    DatePicker("出生時刻", selection: $partnerDate, displayedComponents: [.hourAndMinute])
                    Picker("出生城市", selection: $partnerCity) {
                        ForEach(CityDatabase.presetCities) { city in
                            Text("\(city.region) - \(city.name)").tag(city)
                        }
                    }
                }
            }
            .navigationTitle("設定合盤對象")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        HapticManager.triggerSuccess()
                        isEditingPartner = false
                    }
                    .foregroundColor(GhibliTheme.calciferOrange)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
