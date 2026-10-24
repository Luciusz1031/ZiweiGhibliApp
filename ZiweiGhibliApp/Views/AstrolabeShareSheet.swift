import SwiftUI
import UIKit

public struct AstrolabeShareSheet: View {
    public let chart: AstrolabeChart
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCopied: Bool = false
    @State private var isGeneratingPDF: Bool = false
    @State private var isPresentingSystemShare: Bool = false
    @State private var shareItems: [Any] = []
    
    public init(chart: AstrolabeChart) {
        self.chart = chart
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                GhibliTheme.parchmentBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 1. 頂部小鹿導覽卡
                        HStack(alignment: .top, spacing: 12) {
                            CuteDeerMascotView(size: 46)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("小鹿兒命盤分享中心")
                                    .font(GhibliTheme.titleFont(size: 17))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Text("將您的專屬天命解析、白話大綱、各大維度指引與《天紀》原著格局，完整分享至 LINE、微信或儲存備忘錄！")
                                    .font(GhibliTheme.noteFont(size: 12))
                                    .foregroundColor(GhibliTheme.forestMoss.opacity(0.85))
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .background(GhibliTheme.parchmentCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                        )
                        
                        // 2. 命盤精華預覽摘要卡
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("📜 命盤報告精華預覽")
                                    .font(GhibliTheme.titleFont(size: 14))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Spacer()
                                Text(chart.userName)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(GhibliTheme.spiritPurple)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• 農曆生辰：\(chart.lunarInfo.lunarDateString)")
                                    .font(GhibliTheme.noteFont(size: 11.5))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Text("• 四柱八字：\(chart.lunarInfo.baZiString)")
                                    .font(GhibliTheme.noteFont(size: 11.5))
                                    .foregroundColor(GhibliTheme.forestMoss)
                                Text("• 局數主星：\(chart.elementBureau.name)・命主 \(chart.lifeMasterStar)・身主 \(chart.bodyMasterStar)")
                                    .font(GhibliTheme.noteFont(size: 11.5))
                                    .foregroundColor(GhibliTheme.magicBrass)
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(10)
                        
                        // 3. 分享選項列表
                        VStack(spacing: 12) {
                            // 選項 A: 分享完整文字深度報告 (最推薦、速度最快、支援 LINE/訊息)
                            Button(action: shareTextReport) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(GhibliTheme.forestMoss)
                                        .cornerRadius(10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("分享完整白話解析報告 (LINE / 訊息)")
                                            .font(GhibliTheme.titleFont(size: 15))
                                            .foregroundColor(GhibliTheme.forestMoss)
                                        Text("包含基本資料、白話總綱、三大指引、各大維度與天紀格局")
                                            .font(GhibliTheme.noteFont(size: 11))
                                            .foregroundColor(Color.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(GhibliTheme.magicBrass)
                                }
                                .padding(12)
                                .background(GhibliTheme.parchmentCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                )
                            }
                            
                            // 選項 B: 一鍵複製完整文字報告
                            Button(action: copyToClipboard) {
                                HStack(spacing: 12) {
                                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(isCopied ? Color(red: 0.18, green: 0.52, blue: 0.25) : GhibliTheme.magicBrass)
                                        .cornerRadius(10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(isCopied ? "已成功複製到剪貼簿！" : "一鍵複製完整命盤解析文字")
                                            .font(GhibliTheme.titleFont(size: 15))
                                            .foregroundColor(GhibliTheme.forestMoss)
                                        Text("可直接貼到備忘錄、記事本、Notion 或聊天視窗中")
                                            .font(GhibliTheme.noteFont(size: 11))
                                            .foregroundColor(Color.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    if isCopied {
                                        Text("已複製")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color(red: 0.18, green: 0.52, blue: 0.25))
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(GhibliTheme.magicBrass)
                                    }
                                }
                                .padding(12)
                                .background(GhibliTheme.parchmentCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                )
                            }
                            
                            // 選項 C: 匯出專業排版 PDF 報告 (非同步背景生成，杜絕黑屏卡頓)
                            Button(action: exportPDFReport) {
                                HStack(spacing: 12) {
                                    Group {
                                        if isGeneratingPDF {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Image(systemName: "doc.richtext.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                    .background(GhibliTheme.calciferOrange)
                                    .cornerRadius(10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(isGeneratingPDF ? "正在繪製專屬 PDF 報告..." : "匯出/儲存 豪華版 PDF 檔案")
                                            .font(GhibliTheme.titleFont(size: 15))
                                            .foregroundColor(GhibliTheme.forestMoss)
                                        Text("完整 A4 排版：天圓地方星圖 + 白話深度解析 + 天紀格局古賦")
                                            .font(GhibliTheme.noteFont(size: 11))
                                            .foregroundColor(Color.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(GhibliTheme.magicBrass)
                                }
                                .padding(12)
                                .background(GhibliTheme.parchmentCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(GhibliTheme.borderBrass.opacity(0.4), lineWidth: 1)
                                )
                            }
                            .disabled(isGeneratingPDF)
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("分享與匯出命盤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(GhibliTheme.forestMoss)
                }
            }
            .sheet(isPresented: $isPresentingSystemShare) {
                ShareSheetView(items: shareItems)
            }
        }
    }
    
    // MARK: - 分享純文字報告
    private func shareTextReport() {
        HapticManager.triggerImpact(style: .medium)
        let text = AstrolabeTextReportGenerator.generateFullReport(for: chart)
        shareItems = [text]
        isPresentingSystemShare = true
    }
    
    // MARK: - 複製文字到剪貼簿
    private func copyToClipboard() {
        HapticManager.triggerSuccess()
        let text = AstrolabeTextReportGenerator.generateFullReport(for: chart)
        UIPasteboard.general.string = text
        isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isCopied = false
        }
    }
    
    // MARK: - 背景非同步生成 PDF 報告
    private func exportPDFReport() {
        HapticManager.triggerImpact(style: .medium)
        isGeneratingPDF = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfURL = PDFReportGenerator.generatePDF(for: chart)
            
            DispatchQueue.main.async {
                isGeneratingPDF = false
                if let url = pdfURL {
                    shareItems = [url]
                    isPresentingSystemShare = true
                }
            }
        }
    }
}
