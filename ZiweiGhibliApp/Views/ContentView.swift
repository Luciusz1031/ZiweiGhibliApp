import SwiftUI

public struct ContentView: View {
    @State private var chart: AstrolabeChart? = nil
    @State private var schoolConfig: SchoolConfig = .default
    
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
                VStack(spacing: 6) {
                    // 頂部導航欄
                    HStack {
                        Button(action: {
                            HapticManager.triggerImpact(style: .medium)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                chart = nil
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("重設")
                            }
                            .font(GhibliTheme.bodyFont(size: 14))
                            .foregroundColor(GhibliTheme.forestMoss)
                        }
                        
                        Spacer()
                        
                        Text("天 紀 星 盤")
                            .font(GhibliTheme.titleFont(size: 18))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .tracking(2)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // PDF 匯出與分享按鈕
                            Button(action: exportPDF) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(GhibliTheme.forestMoss)
                            }
                            
                            // 格局一覽
                            Button(action: { isShowingPatterns = true }) {
                                Image(systemName: "scroll.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(GhibliTheme.calciferOrange)
                            }
                            
                            // 流派設定
                            Button(action: { isShowingSettings = true }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 16))
                                    .foregroundColor(GhibliTheme.magicBrass)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
                    
                    // 十二宮 4x4 宮格
                    ChartGridView(
                        chart: activeChart,
                        selectedBranch: $selectedBranch,
                        onOpenPatterns: { isShowingPatterns = true },
                        onOpenSettings: { isShowingSettings = true }
                    )
                    .padding(.horizontal, 8)
                    
                    Spacer(minLength: 2)
                    
                    // 底部大限/流年時光輪盤
                    TimeSliderView(
                        currentMode: $luckMode,
                        selectedDecadeIndex: $selectedDecadeIndex,
                        selectedYear: $selectedYear,
                        chart: activeChart
                    )
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
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
