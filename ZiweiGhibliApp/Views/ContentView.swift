import SwiftUI

public enum AstrolabeDisplayMode: String, CaseIterable, Identifiable {
    case analysis = "命盤分析"
    case synastry = "合盤分析"
    case grid = "星盤總覽"
    case vertical = "直列卷軸"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .analysis: return "chart.xyaxis.line"
        case .synastry: return "heart.circle"
        case .grid: return "square.grid.3x3"
        case .vertical: return "list.bullet.rectangle.portrait"
        }
    }
}

public struct ContentView: View {
    @State private var chart: AstrolabeChart? = nil
    @State private var schoolConfig: SchoolConfig = .default
    
    // 命盤顯示模式 (預設為 Metis 風格的命盤分析，包含六維雷達圖與命格剖析)
    @State private var displayMode: AstrolabeDisplayMode = .analysis
    
    // 互動狀態
    @State private var selectedBranch: EarthlyBranch? = nil
    @State private var isShowingPatterns: Bool = false
    @State private var isShowingSettings: Bool = false
    
    // PDF 匯出與分享狀態
    @State private var isShowingPDFPreview: Bool = false
    @State private var generatedPDFURL: URL? = nil
    
    // 大限與流年時光輪盤狀態
    @State private var luckMode: LuckMode = .natal
    @State private var selectedDecadeIndex: Int? = 0
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    public init() {}
    
    public var body: some View {
        ZStack {
            GhibliTheme.parchmentBg.ignoresSafeArea()
            
            if let activeChart = chart {
                // 已排盤視圖
                VStack(spacing: 2) {
                    // 頂部導航欄 (重設、APP標題、PDF匯出、格局一覽、流派設定)
                    HStack(spacing: 8) {
                        Button(action: {
                            HapticManager.triggerImpact(style: .medium)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                chart = nil
                            }
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left")
                                Text("重設")
                            }
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss)
                        }
                        
                        Spacer()
                        
                        // APP 標題與可愛鹿兒微圖標
                        HStack(spacing: 5) {
                            Text("🦌")
                                .font(.system(size: 16))
                            Text("小 鹿 兒 算 命")
                                .font(GhibliTheme.titleFont(size: 17))
                                .foregroundColor(GhibliTheme.forestMoss)
                                .tracking(1)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // PDF 匯出與社群分享按鈕
                            Button(action: exportPDF) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(GhibliTheme.forestMoss)
                            }
                            
                            // 格局一覽
                            Button(action: { isShowingPatterns = true }) {
                                Image(systemName: "scroll.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(GhibliTheme.calciferOrange)
                            }
                            
                            // 流派設定
                            Button(action: { isShowingSettings = true }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 15))
                                    .foregroundColor(GhibliTheme.magicBrass)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
                    .padding(.bottom, 2)
                    
                    // 頂部四大功能模式切換膠囊列 (模仿 Metis Ziwei 現代風格導航)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AstrolabeDisplayMode.allCases) { mode in
                                let isSelected = (displayMode == mode)
                                Button(action: {
                                    HapticManager.triggerImpact(style: .light)
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        displayMode = mode
                                    }
                                }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: mode.icon)
                                            .font(.system(size: 11))
                                        Text(mode.rawValue)
                                            .font(GhibliTheme.bodyFont(size: 12))
                                    }
                                    .foregroundColor(isSelected ? .white : GhibliTheme.forestMoss)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(isSelected ? GhibliTheme.forestMoss : GhibliTheme.parchmentCard)
                                            .overlay(
                                                Capsule()
                                                    .stroke(isSelected ? GhibliTheme.forestMoss : GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear, radius: 2, y: 1)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                    }
                    
                    // 核心排盤展示區域
                    switch displayMode {
                    case .analysis:
                        // 1. 現代 Metis 命格分析 (六維雷達圖、核心優勢卡片、十維度切換)
                        MetisAnalysisView(chart: activeChart)
                        
                    case .synastry:
                        // 2. 雙人斗數合盤 (相容性指數、四化互旺福澤、磨合建議)
                        SynastryView(personA: activeChart)
                        
                    case .grid:
                        // 3. 傳統 4x4 天圓地方星盤總覽 (中宮 METIS 天心儀表 + 時光輪盤)
                        VStack(spacing: 4) {
                            MetisChartGridView(
                                chart: activeChart,
                                selectedBranch: $selectedBranch
                            )
                            .padding(.horizontal, 6)
                            
                            Spacer(minLength: 2)
                            
                            TimeSliderView(
                                currentMode: $luckMode,
                                selectedDecadeIndex: $selectedDecadeIndex,
                                selectedYear: $selectedYear,
                                chart: activeChart
                            )
                            .padding(.horizontal, 8)
                            .padding(.bottom, 6)
                        }
                        
                    case .vertical:
                        // 4. 直列滑動卷軸 (單手流暢滑動、直覺清晰)
                        VerticalPalaceListView(chart: activeChart) { palace in
                            selectedBranch = palace.earthlyBranch
                        }
                    }
                }
                .sheet(item: Binding<PalaceItemWrapper?>(
                    get: {
                        if let b = selectedBranch {
                            return PalaceItemWrapper(palace: activeChart.palace(at: b))
                        }
                        return nil
                    },
                    set: { _ in selectedBranch = nil }
                )) { wrapper in
                    PalaceDetailSheet(palace: wrapper.palace, chart: activeChart)
                }
                .sheet(isPresented: $isShowingPatterns) {
                    PatternListView(patterns: activeChart.patterns)
                }
                .sheet(isPresented: $isShowingSettings) {
                    SchoolSettingsView(config: $schoolConfig, onSave: {
                        // 重新依新設定排盤
                        chart = ZiweiEngine.generateChart(
                            birthDate: activeChart.solarDate,
                            city: activeChart.city,
                            gender: activeChart.gender,
                            userName: activeChart.userName,
                            isUnknownHour: activeChart.isUnknownHour,
                            config: schoolConfig
                        )
                    })
                }
                .sheet(isPresented: $isShowingPDFPreview) {
                    if let url = generatedPDFURL {
                        PDFExportPreviewSheet(pdfURL: url)
                    }
                }
            } else {
                // 輸入出生資料畫面
                BirthInputView(chart: $chart, schoolConfig: $schoolConfig)
            }
        }
    }
    
    private func exportPDF() {
        guard let activeChart = chart else { return }
        HapticManager.triggerImpact(style: .medium)
        if let url = PDFReportGenerator.generatePDF(for: activeChart) {
            generatedPDFURL = url
            isShowingPDFPreview = true
        }
    }
}

// 輔助 Sheet 彈出的 Identifiable 包裝體
struct PalaceItemWrapper: Identifiable {
    var id: Int { palace.id }
    let palace: PalaceData
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
