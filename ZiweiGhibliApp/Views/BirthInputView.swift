import SwiftUI

public struct BirthInputView: View {
    @Binding public var chart: AstrolabeChart?
    @Binding public var schoolConfig: SchoolConfig
    
    // 預設日期為 1982年10月31日 中午 12:00 (午時)
    @State private var birthDate: Date = Calendar.current.date(from: DateComponents(year: 1982, month: 10, day: 31, hour: 12, minute: 0)) ?? Date()
    @State private var userName: String = ""
    @State private var isUnknownHour: Bool = false
    
    @State private var gender: Gender = .male
    @State private var selectedCity: CityLocation = CityDatabase.defaultCity
    @State private var isCustomCity: Bool = false
    @State private var customLongitude: Double = 121.5
    @State private var isShowingSettings: Bool = false
    
    // 中文日期格式化器
    private var chineseDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hant_TW")
        df.dateFormat = "yyyy年MM月dd日"
        return df
    }
    
    private var chineseTimeFormatter: DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hant_TW")
        df.dateFormat = "HH:mm"
        return df
    }
    
    // 即時真太陽時計算
    private var solarCorrection: SolarCorrectionResult {
        let city = isCustomCity ?
            CityLocation(name: "自訂地點", region: "自訂", longitude: customLongitude, latitude: 25.0) :
            selectedCity
        let targetDate = isUnknownHour ?
            (Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: birthDate) ?? birthDate) :
            birthDate
        return SolarTimeCalculator.calculateTrueSolarTime(for: targetDate, city: city, adjustDST: schoolConfig.autoAdjustDST)
    }
    
    public var body: some View {
        ZStack {
            GhibliTheme.parchmentBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 吉卜力浮雲頂部
                FloatingCloudHeader()
                
                ScrollView {
                    VStack(spacing: 14) {
                        // 標題與可愛小鹿吉祥物
                        VStack(spacing: 8) {
                            CuteDeerMascotView(size: 68, showGreeting: true, greetingText: "輸入你的生辰，讓小鹿兒為你揭開星星的禮物～")
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 2) {
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
                        
                        // 1. 姓名輸入卡片
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "person.text.rectangle.fill")
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Text("命主姓名 / 稱謂")
                                    .font(GhibliTheme.titleFont(size: 15))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Spacer()
                                Text("選填")
                                    .font(GhibliTheme.noteFont(size: 11))
                                    .foregroundColor(Color.gray)
                            }
                            
                            TextField("請輸入您的姓名或暱稱（預設：命主）", text: $userName)
                                .font(GhibliTheme.bodyFont(size: 14))
                                .padding(10)
                                .background(GhibliTheme.parchmentCard)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
                                )
                        }
                        .padding(12)
                        .parchmentStyle()
                        .padding(.horizontal)
                        
                        // 2. 性別選擇
                        HStack(spacing: 14) {
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
                        
                        // 3. 出生西曆日期與時間 (支援中文格式與不知道時辰選項)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("出生時間（西曆標準時間）")
                                    .font(GhibliTheme.titleFont(size: 16))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Spacer()
                                Text("目前：\(chineseDateFormatter.string(from: birthDate))")
                                    .font(.system(size: 11, weight: .semibold, design: .serif))
                                    .foregroundColor(GhibliTheme.calciferOrange)
                            }
                            
                            // 出生日期選擇 (中文化介面)
                            DatePicker("出生日期", selection: $birthDate, displayedComponents: [.date])
                                .font(GhibliTheme.bodyFont(size: 14))
                                .foregroundColor(GhibliTheme.forestMoss)
                                .environment(\.locale, Locale(identifier: "zh_Hant_TW"))
                            
                            Divider()
                            
                            // 不知道出生時刻開關
                            Toggle(isOn: $isUnknownHour) {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.badge.questionmark")
                                        .foregroundColor(GhibliTheme.calciferOrange)
                                    Text("不知道出生時刻")
                                        .font(GhibliTheme.bodyFont(size: 14))
                                        .foregroundColor(GhibliTheme.forestMoss)
                                }
                            }
                            .tint(GhibliTheme.calciferOrange)
                            
                            if isUnknownHour {
                                // 溫馨提示
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(GhibliTheme.magicBrass)
                                        .font(.system(size: 13))
                                        .padding(.top, 2)
                                    Text("🌟 已開啟「不知道出生時刻」：紫微斗數需時辰定命身宮與部分輔星。小鹿兒將採用傳統正午（午時 12:00，陽氣最旺）為您基準排盤，生年四化、五行局、命格骨架完整呈現。排盤後亦可於時光輪盤切換時辰校準！")
                                        .font(GhibliTheme.noteFont(size: 11.5))
                                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                                        .lineSpacing(2)
                                }
                                .padding(8)
                                .background(GhibliTheme.magicBrass.opacity(0.1))
                                .cornerRadius(8)
                            } else {
                                // 出生時刻選擇
                                DatePicker("出生時刻", selection: $birthDate, displayedComponents: [.hourAndMinute])
                                    .font(GhibliTheme.bodyFont(size: 14))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                    .environment(\.locale, Locale(identifier: "zh_Hant_TW"))
                            }
                        }
                        .padding(12)
                        .parchmentStyle()
                        .padding(.horizontal)
                        
                        // 4. 出生地點選擇
                        VStack(alignment: .leading, spacing: 10) {
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
                            .padding(.vertical, 2)
                        }
                        .padding(12)
                        .parchmentStyle()
                        .padding(.horizontal)
                        
                        // 5. 即時真太陽時核對儀表卡 (中文日期時間呈現)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sun.haze.fill")
                                    .foregroundColor(GhibliTheme.calciferOrange)
                                Text("天文真太陽時換算")
                                    .font(GhibliTheme.titleFont(size: 15))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Spacer()
                                Text(isUnknownHour ? "午時 (基準)" : (solarCorrection.hourBranch.name + "時"))
                                    .font(GhibliTheme.titleFont(size: 15))
                                    .foregroundColor(GhibliTheme.calciferOrange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(GhibliTheme.calciferOrange.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            
                            let df = DateFormatter()
                            let _ = {
                                df.locale = Locale(identifier: "zh_Hant_TW")
                                df.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                            }()
                            
                            Text("校正後真太陽時：\(df.string(from: solarCorrection.trueSolarDate))")
                                .font(.system(size: 12.5, weight: .semibold, design: .serif))
                                .foregroundColor(GhibliTheme.forestMoss)
                            
                            Text(solarCorrection.summaryText)
                                .font(GhibliTheme.noteFont(size: 11))
                                .foregroundColor(GhibliTheme.magicBrass)
                            
                            if !isUnknownHour && solarCorrection.isLateZi {
                                Text("💡 提示：目前處於夜子時(23:00-00:00)，依天紀規則自動換入次日排盤。")
                                    .font(GhibliTheme.noteFont(size: 11))
                                    .foregroundColor(GhibliTheme.tabooRed)
                            }
                        }
                        .padding(12)
                        .parchmentStyle(isHighlighted: true)
                        .padding(.horizontal)
                        
                        // 6. 排盤按鈕
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
                        .padding(.top, 6)
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
        let finalBirthDate: Date
        if isUnknownHour {
            finalBirthDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: birthDate) ?? birthDate
        } else {
            finalBirthDate = birthDate
        }
        
        let finalName = userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "命主" : userName
        
        let c = ZiweiEngine.generateChart(
            birthDate: finalBirthDate,
            city: selectedCity,
            gender: gender,
            userName: finalName,
            isUnknownHour: isUnknownHour,
            config: schoolConfig
        )
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            chart = c
        }
    }
}
