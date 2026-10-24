import SwiftUI

public enum AstrolabeDisplayMode: String, CaseIterable, Identifiable {
    case vertical = "直列卷軸"
    case grid = "傳統九宮"
    
    public var id: String { rawValue }
}

public struct ContentView: View {
    @State private var chart: AstrolabeChart? = nil
    @State private var schoolConfig: SchoolConfig = .default
    
    // 命盤顯示模式 (預設為直列滑動卡片模式，方便單手閱讀)
    @State private var displayMode: AstrolabeDisplayMode = .vertical
    
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
                VStack(spacing: 4) {
                    // 頂部導航欄 (小鹿兒標題與模式切換)
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
                        
                        HStack(spacing: 8) {
                            // 視圖切換按鈕 (直列滑動 vs 傳統九宮盤)
                            Button(action: {
                                HapticManager.triggerImpact(style: .light)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    displayMode = (displayMode == .vertical ? .grid : .vertical)
                                }
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: displayMode == .vertical ? "square.grid.3x3" : "list.bullet.rectangle.portrait")
                                        .font(.system(size: 12))
                                    Text(displayMode == .vertical ? "九宮格" : "直列")
                                        .font(GhibliTheme.noteFont(size: 11))
                                }
                                .foregroundColor(GhibliTheme.forestMoss)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(GhibliTheme.parchmentCard)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.6), lineWidth: 1)
                                )
                            }
                            
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
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                    
                    // 核心排盤展示區域
                    if displayMode == .vertical {
                        // 1. 直列滑動呈現 (預設模式，填滿螢幕空間，單手流暢滑動)
                        VerticalPalaceListView(chart: activeChart) { palace in
                            selectedBranch = palace.earthlyBranch
                        }
                    } else {
                        // 2. 傳統 4x4 天圓地方九宮格星盤模式
                        VStack(spacing: 6) {
                            ChartGridView(
                                chart: activeChart,
                                selectedBranch: $selectedBranch,
                                onOpenPatterns: { isShowingPatterns = true },
                                onOpenSettings: { isShowingSettings = true }
                            )
                            .padding(.horizontal, 8)
                            
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
