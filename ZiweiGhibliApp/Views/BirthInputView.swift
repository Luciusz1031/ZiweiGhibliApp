import SwiftUI

public struct BirthInputView: View {
    @Binding public var chart: AstrolabeChart?
    @Binding public var schoolConfig: SchoolConfig
    
    @State private var birthDate: Date = Calendar.current.date(from: DateComponents(year: 1995, month: 8, day: 15, hour: 11, minute: 30)) ?? Date()
    @State private var gender: Gender = .male
    @State private var selectedCity: CityLocation = CityDatabase.defaultCity
    @State private var isCustomCity: Bool = false
    @State private var customLongitude: Double = 121.5
    @State private var isShowingSettings: Bool = false
    
    // 即時真太陽時計算
    private var solarCorrection: SolarCorrectionResult {
        let city = isCustomCity ?
            CityLocation(name: "自訂地點", region: "自訂", longitude: customLongitude, latitude: 25.0) :
            selectedCity
        return SolarTimeCalculator.calculateTrueSolarTime(for: birthDate, city: city, adjustDST: schoolConfig.autoAdjustDST)
    }
    
    public var body: some View {
        ZStack {
            GhibliTheme.parchmentBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 吉卜力浮雲頂部
                FloatingCloudHeader()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 標題與可愛小鹿吉祥物
                        VStack(spacing: 10) {
                            CuteDeerMascotView(size: 72, showGreeting: true, greetingText: "輸入你的生辰，讓小鹿兒為你揭開星星的禮物～")
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 3) {
                                Text("小 鹿 兒 算 命")
                                    .font(GhibliTheme.titleFont(size: 24))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                    .tracking(3)
                                
                                Text("吉卜力療癒手繪 × 倪海廈《天紀》紫微斗數")
                                    .font(GhibliTheme.bodyFont(size: 13))
                                    .foregroundColor(GhibliTheme.magicBrass)
                            }
                        }
                        .padding(.top, 4)
                        
                        // 1. 性別選擇
                        HStack(spacing: 16) {
                            ForEach(Gender.allCases, id: \.self) { g in
                                Button(action: {
                                    HapticManager.triggerImpact(style: .light)
                                    gender = g
                                }) {
                                    HStack {
                                        Image(systemName: g == .male ? "person.fill" : "person.crop.circle.fill")
                                        Text(g.rawValue)
                                    }
                                    .font(GhibliTheme.bodyFont(size: 15))
                                    .foregroundColor(gender == g ? .white : GhibliTheme.forestMoss)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(gender == g ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 2. 出生西曆日期與時間
                        VStack(alignment: .leading, spacing: 12) {
                            Text("出生時間（鐘錶時間）")
                                .font(GhibliTheme.titleFont(size: 16))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            DatePicker("出生日期", selection: $birthDate, displayedComponents: [.date])
                                .font(GhibliTheme.bodyFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            DatePicker("出生時刻", selection: $birthDate, displayedComponents: [.hourAndMinute])
                                .font(GhibliTheme.bodyFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss)
                        }
                        .padding()
                        .parchmentStyle()
                        .padding(.horizontal)
                        
                        // 3. 出生地點選擇
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("出生地點（真太陽時核對）")
                                    .font(GhibliTheme.titleFont(size: 16))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Spacer()
                                Button(action: { isShowingSettings = true }) {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(GhibliTheme.magicBrass)
                                }
                            }
                            
                            Picker("選擇城市", selection: $selectedCity) {
                                ForEach(CityDatabase.presetCities) { city in
                                    Text("\(city.region) - \(city.name) (經度 \(String(format: "%.1f°", city.longitude)))").tag(city)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.vertical, 4)
                        }
                        .padding()
                        .parchmentStyle()
                        .padding(.horizontal)
                        
                        // 4. 即時真太陽時核對儀表卡
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sun.haze.fill")
                                    .foregroundColor(GhibliTheme.calciferOrange)
                                Text("天文真太陽時換算")
                                    .font(GhibliTheme.titleFont(size: 15))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Spacer()
                                Text(solarCorrection.hourBranch.name + "時")
                                    .font(GhibliTheme.titleFont(size: 16))
                                    .foregroundColor(GhibliTheme.calciferOrange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(GhibliTheme.calciferOrange.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            
                            let df = DateFormatter()
                            let _ = { df.dateFormat = "yyyy-MM-dd HH:mm:ss" }()
                            
                            Text("校正後真太陽時：\(df.string(from: solarCorrection.trueSolarDate))")
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            Text(solarCorrection.summaryText)
                                .font(GhibliTheme.noteFont(size: 11))
                                .foregroundColor(GhibliTheme.magicBrass)
                            
                            if solarCorrection.isLateZi {
                                Text("💡 提示：目前處於夜子時(23:00-00:00)，依天紀規則自動換入次日排盤。")
                                    .font(GhibliTheme.noteFont(size: 11))
                                    .foregroundColor(GhibliTheme.tabooRed)
                            }
                        }
                        .padding()
                        .parchmentStyle(isHighlighted: true)
                        .padding(.horizontal)
                        
                        // 5. 排盤按鈕
                        Button(action: generateChart) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("讓 小 鹿 兒 為 我 排 盤")
                                    .font(GhibliTheme.titleFont(size: 18))
                                    .tracking(2)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [GhibliTheme.magicBrass, GhibliTheme.calciferOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: GhibliTheme.calciferOrange.opacity(0.35), radius: 6, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SchoolSettingsView(config: $schoolConfig)
        }
    }
    
    private func generateChart() {
        HapticManager.triggerSuccess()
        let c = ZiweiEngine.generateChart(
            birthDate: birthDate,
            city: selectedCity,
            gender: gender,
            config: schoolConfig
        )
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            chart = c
        }
    }
}
