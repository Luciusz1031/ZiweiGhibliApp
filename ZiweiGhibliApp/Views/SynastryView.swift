import SwiftUI

public struct SynastryView: View {
    public let personA: AstrolabeChart
    
    // 對象 B 的資料狀態 (預設日期為 1982年10月31日)
    @State private var partnerDate: Date = Calendar.current.date(from: DateComponents(year: 1982, month: 10, day: 31, hour: 12, minute: 0)) ?? Date()
    @State private var partnerGender: Gender = .female
    @State private var partnerCity: CityLocation = CityDatabase.defaultCity
    @State private var partnerName: String = "對象"
    @State private var partnerUnknownHour: Bool = false
    
    @State private var isEditingPartner: Bool = false
    @State private var calculationVersion: Int = 0 // 每次重算觸發動畫
    
    // 中文日期格式化
    private var chineseDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hant_TW")
        df.dateFormat = "yyyy年MM月dd日"
        return df
    }
    
    public var body: some View {
        // 依據當前輸入即時排盤 Person B (若不知道時辰則以子時 23:00-01:00 基準排盤)
        let bDate = partnerUnknownHour ?
            (Calendar.current.date(bySettingHour: 0, minute: 30, second: 0, of: partnerDate) ?? partnerDate) :
            partnerDate
        
        let personB = ZiweiEngine.generateChart(
            birthDate: bDate,
            city: partnerCity,
            gender: partnerGender,
            userName: partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "對象" : partnerName,
            isUnknownHour: partnerUnknownHour,
            config: personA.config
        )
        
        let synastry = SynastryEngine.analyze(personA: personA, personB: personB)
        
        ScrollView {
            VStack(spacing: 14) {
                // 1. 雙人檔案卡片 (我 vs 對象)
                HStack(spacing: 10) {
                    // 盤主 A
                    VStack(spacing: 4) {
                        Text(personA.userName.isEmpty ? "我 (盤主)" : personA.userName)
                            .font(GhibliTheme.titleFont(size: 13))
                            .foregroundColor(GhibliTheme.magicBrass)
                            .lineLimit(1)
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
                            HStack(spacing: 3) {
                                Text(partnerName.isEmpty ? "對象" : partnerName)
                                    .font(GhibliTheme.titleFont(size: 13))
                                    .foregroundColor(GhibliTheme.magicBrass)
                                    .lineLimit(1)
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
                
                // 快速編輯與重新合盤按鈕欄
                HStack(spacing: 10) {
                    Button(action: {
                        HapticManager.triggerImpact(style: .light)
                        isEditingPartner = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                            Text("修改對象資料 (\(chineseDateFormatter.string(from: partnerDate)))")
                                .font(GhibliTheme.bodyFont(size: 12))
                        }
                        .foregroundColor(GhibliTheme.forestMoss)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(GhibliTheme.parchmentCard)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        HapticManager.triggerSuccess()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            calculationVersion += 1
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("重新分析")
                                .font(GhibliTheme.bodyFont(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(GhibliTheme.calciferOrange)
                        .cornerRadius(8)
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
                .id("synastry-dashboard-\(calculationVersion)")
                
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
    
    // 對象生辰修改彈窗 (完整支援姓名、中文日期與不知道出生時刻)
    private var partnerInputSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("對象基本資料")) {
                    TextField("對象姓名 / 稱謂", text: $partnerName)
                    Picker("性別", selection: $partnerGender) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("對象出生時間（中文格式）")) {
                    DatePicker("出生日期", selection: $partnerDate, displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "zh_Hant_TW"))
                    
                    Toggle("不知道出生時間，以子時（23:00-01:00）起盤", isOn: $partnerUnknownHour)
                        .tint(GhibliTheme.calciferOrange)
                    
                    if !partnerUnknownHour {
                        DatePicker("出生時刻", selection: $partnerDate, displayedComponents: [.hourAndMinute])
                            .environment(\.locale, Locale(identifier: "zh_Hant_TW"))
                    } else {
                        Text("🌟 以子時（23:00-01:00）為基準排盤")
                            .font(.system(size: 12))
                            .foregroundColor(GhibliTheme.magicBrass)
                    }
                    
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
                    Button("完成並分析") {
                        HapticManager.triggerSuccess()
                        isEditingPartner = false
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            calculationVersion += 1
                        }
                    }
                    .foregroundColor(GhibliTheme.calciferOrange)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
