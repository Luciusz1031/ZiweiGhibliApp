import SwiftUI
import PDFKit

public struct PDFExportPreviewSheet: View {
    public let pdfURL: URL
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentingShareSheet: Bool = false
    
    public init(pdfURL: URL) {
        self.pdfURL = pdfURL
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                GhibliTheme.parchmentBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. PDF 預覽視圖
                    PDFKitView(url: pdfURL)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    
                    // 2. 底部操作動作列 (分享到 LINE / 郵件 / 儲存)
                    VStack(spacing: 8) {
                        Button(action: {
                            HapticManager.triggerImpact(style: .medium)
                            isPresentingShareSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                Text("分享 PDF (LINE / 郵件 / 儲存到檔案)")
                                    .font(GhibliTheme.titleFont(size: 16))
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
                            .cornerRadius(12)
                            .shadow(color: GhibliTheme.calciferOrange.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        
                        Text("💡 點選上方分享按鈕，可直接透過 LINE 傳送給親友、發送 E-mail 附件，或儲存至「檔案」App 與 iCloud 雲端。")
                            .font(GhibliTheme.noteFont(size: 11))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(GhibliTheme.parchmentCard)
                }
            }
            .navigationTitle("命盤 PDF 匯出預覽")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(GhibliTheme.forestMoss)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.triggerImpact(style: .light)
                        isPresentingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(GhibliTheme.calciferOrange)
                    }
                }
            }
            .sheet(isPresented: $isPresentingShareSheet) {
                ShareSheetView(items: [pdfURL])
            }
        }
    }
}

// MARK: - PDFKit 封裝視圖
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor.clear
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url {
            uiView.document = PDFDocument(url: url)
        }
    }
}
