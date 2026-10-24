import UIKit
import PDFKit

public class PDFReportGenerator {
    
    // A4 尺寸 (點數: 72 點/英吋)
    private static let pageWidth: CGFloat = 595.2
    private static let pageHeight: CGFloat = 841.8
    private static let margin: CGFloat = 36.0
    
    /// 將命盤生成 PDF 文件並存於暫存區，回傳檔案 URL
    public static func generatePDF(for chart: AstrolabeChart) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "星之迴響紫微斗數 App",
            kCGPDFContextAuthor: "倪海廈《天紀》排盤系統",
            kCGPDFContextTitle: "\(chart.lunarInfo.yearStem.name)\(chart.lunarInfo.yearBranch.name)年・紫微斗數命盤報告"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("天紀紫微斗數命盤_\(chart.lunarInfo.yearStem.name)\(chart.lunarInfo.yearBranch.name)年.pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                // 第 1 頁：命盤總覽與天圓地方十二宮
                context.beginPage()
                drawPageOne(chart: chart, in: pageRect, context: context.cgContext)
                
                // 第 2 頁：倪海廈《天紀》格局深度解析與古賦
                context.beginPage()
                drawPageTwo(chart: chart, in: pageRect, context: context.cgContext)
            }
            return tempURL
        } catch {
            print("生成 PDF 失敗: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 第一頁繪製：封面抬頭、生辰八字、十二宮星圖
    private static func drawPageOne(chart: AstrolabeChart, in rect: CGRect, context: CGContext) {
        // 羊皮紙底色
        let bgPath = UIBezierPath(rect: rect)
        UIColor(red: 0.98, green: 0.965, blue: 0.933, alpha: 1.0).setFill()
        bgPath.fill()
        
        // 復古外框雙線
        let outerBorder = UIBezierPath(roundedRect: rect.insetBy(dx: 18, dy: 18), cornerRadius: 8)
        UIColor(red: 0.81, green: 0.73, blue: 0.61, alpha: 1.0).setStroke()
        outerBorder.lineWidth = 1.5
        outerBorder.stroke()
        
        let innerBorder = UIBezierPath(roundedRect: rect.insetBy(dx: 22, dy: 22), cornerRadius: 6)
        outerBorder.lineWidth = 0.6
        innerBorder.stroke()
        
        var currentY: CGFloat = 36.0
        
        // 1. 標題
        let title = "星 之 迴 響・天 紀 紫 微 斗 數 命 盤"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PingFangTC-Semibold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)
        ]
        let titleSize = title.size(withAttributes: titleAttrs)
        title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 6
        
        // 副標題
        let subTitle = "倪海廈先生《天紀》排盤體系・真太陽時精密校準"
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PingFangTC-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor(red: 0.769, green: 0.608, blue: 0.235, alpha: 1.0)
        ]
        let subSize = subTitle.size(withAttributes: subAttrs)
        subTitle.draw(at: CGPoint(x: (pageWidth - subSize.width) / 2, y: currentY), withAttributes: subAttrs)
        currentY += subSize.height + 12
        
        // 2. 生辰與真太陽時資訊卡
        let infoRect = CGRect(x: margin, y: currentY, width: pageWidth - (margin * 2), height: 72)
        let infoCard = UIBezierPath(roundedRect: infoRect, cornerRadius: 6)
        UIColor(red: 0.953, green: 0.922, blue: 0.867, alpha: 1.0).setFill()
        infoCard.fill()
        UIColor(red: 0.81, green: 0.73, blue: 0.61, alpha: 0.6).setStroke()
        infoCard.lineWidth = 1.0
        infoCard.stroke()
        
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月dd日 HH:mm"
        
        let col1X = infoRect.origin.x + 12
        let col2X = infoRect.origin.x + (infoRect.width / 2) + 6
        var infoY = infoRect.origin.y + 8
        
        let regularFont = UIFont(name: "PingFangTC-Regular", size: 9) ?? UIFont.systemFont(ofSize: 9)
        let boldFont = UIFont(name: "PingFangTC-Medium", size: 9.5) ?? UIFont.boldSystemFont(ofSize: 9.5)
        let textAttrs: [NSAttributedString.Key: Any] = [.font: regularFont, .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)]
        let boldAttrs: [NSAttributedString.Key: Any] = [.font: boldFont, .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)]
        let orangeAttrs: [NSAttributedString.Key: Any] = [.font: boldFont, .foregroundColor: UIColor(red: 0.851, green: 0.380, blue: 0.220, alpha: 1.0)]
        
        "造別：\(chart.gender.rawValue)".draw(at: CGPoint(x: col1X, y: infoY), withAttributes: boldAttrs)
        "局數：\(chart.elementBureau.name)".draw(at: CGPoint(x: col2X, y: infoY), withAttributes: orangeAttrs)
        infoY += 15
        
        "公曆生辰：\(df.string(from: chart.solarDate))".draw(at: CGPoint(x: col1X, y: infoY), withAttributes: textAttrs)
        "出生地點：\(chart.city.name) (經度 \(String(format: "%.1f°", chart.city.longitude)))".draw(at: CGPoint(x: col2X, y: infoY), withAttributes: textAttrs)
        infoY += 15
        
        "農曆八字：\(chart.lunarInfo.baZiString)".draw(at: CGPoint(x: col1X, y: infoY), withAttributes: boldAttrs)
        "真太陽時偏差：\(chart.solarCorrection.summaryText)".draw(at: CGPoint(x: col2X, y: infoY), withAttributes: textAttrs)
        infoY += 15
        
        "命主：\(chart.lifeMasterStar)    身主：\(chart.bodyMasterStar)".draw(at: CGPoint(x: col1X, y: infoY), withAttributes: textAttrs)
        "流派：倪師天紀 (子初換日・庚干日武陰同)".draw(at: CGPoint(x: col2X, y: infoY), withAttributes: textAttrs)
        
        currentY += infoRect.height + 14
        
        // 3. 十二宮 4x4 命盤網格繪製
        let gridWidth = pageWidth - (margin * 2)
        let cellSpacing: CGFloat = 3.0
        let cellSize = (gridWidth - (cellSpacing * 3)) / 4.0
        let gridHeight = (cellSize * 4) + (cellSpacing * 3)
        let gridOriginY = currentY
        
        // 佈局座標映射 (0..3 欄與列)
        // Row 0: 巳(5), 午(6), 未(7), 申(8)
        // Row 1: 辰(4), [中宮], 酉(9)
        // Row 2: 卯(3), [中宮], 戌(10)
        // Row 3: 寅(2), 丑(1), 子(0), 亥(11)
        let branchPositionMap: [EarthlyBranch: (row: Int, col: Int)] = [
            .si: (0, 0), .wu: (0, 1), .wei: (0, 2), .shen: (0, 3),
            .chen: (1, 0),                           .you: (1, 3),
            .mao: (2, 0),                            .xu: (2, 3),
            .yin: (3, 0), .chou: (3, 1), .zi: (3, 2), .hai: (3, 3)
        ]
        
        for (branch, pos) in branchPositionMap {
            let x = margin + (CGFloat(pos.col) * (cellSize + cellSpacing))
            let y = gridOriginY + (CGFloat(pos.row) * (cellSize + cellSpacing))
            let cellRect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
            let palace = chart.palace(at: branch)
            drawPDFPalaceCell(palace: palace, in: cellRect, context: context)
        }
        
        // 繪製中宮天心 (佔據 col 1,2 與 row 1,2)
        let centerX = margin + (1 * (cellSize + cellSpacing))
        let centerY = gridOriginY + (1 * (cellSize + cellSpacing))
        let centerWidth = (cellSize * 2) + cellSpacing
        let centerHeight = (cellSize * 2) + cellSpacing
        let centerRect = CGRect(x: centerX, y: centerY, width: centerWidth, height: centerHeight)
        drawPDFCenterPalace(chart: chart, in: centerRect, context: context)
        
        // 4. 底部頁腳
        let footerText = "星之迴響紫微斗數 App 自動產生・心態改則命運改・專屬個人命理報告"
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PingFangTC-Regular", size: 8) ?? UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        ]
        let footerSize = footerText.size(withAttributes: footerAttrs)
        footerText.draw(at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - 28), withAttributes: footerAttrs)
    }
    
    // MARK: - 繪製 PDF 單個宮位格
    private static func drawPDFPalaceCell(palace: PalaceData, in rect: CGRect, context: CGContext) {
        // 卡片底色與框
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        if palace.isLifePalace {
            UIColor(red: 0.96, green: 0.94, blue: 0.98, alpha: 1.0).setFill()
        } else {
            UIColor(red: 0.953, green: 0.922, blue: 0.867, alpha: 0.7).setFill()
        }
        path.fill()
        
        let strokeColor = palace.isLifePalace ?
            UIColor(red: 0.373, green: 0.294, blue: 0.471, alpha: 0.8) :
            UIColor(red: 0.81, green: 0.73, blue: 0.61, alpha: 0.8)
        strokeColor.setStroke()
        path.lineWidth = palace.isLifePalace ? 1.2 : 0.6
        path.stroke()
        
        var y = rect.origin.y + 3
        let x = rect.origin.x + 3
        let w = rect.width - 6
        
        // 1. 宮名與大限
        let palaceName = palace.type.name + (palace.isLifePalace ? "[命]" : "") + (palace.isBodyPalace ? "[身]" : "")
        let pNameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PingFangTC-Semibold", size: 9) ?? UIFont.boldSystemFont(ofSize: 9),
            .foregroundColor: palace.isLifePalace ? UIColor(red: 0.373, green: 0.294, blue: 0.471, alpha: 1.0) : UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)
        ]
        palaceName.draw(at: CGPoint(x: x, y: y), withAttributes: pNameAttrs)
        
        let decadeStr = "\(palace.decadeStartAge)-\(palace.decadeEndAge)"
        let decadeAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7.5),
            .foregroundColor: UIColor(red: 0.769, green: 0.608, blue: 0.235, alpha: 1.0)
        ]
        let dSize = decadeStr.size(withAttributes: decadeAttrs)
        decadeStr.draw(at: CGPoint(x: rect.maxX - dSize.width - 3, y: y), withAttributes: decadeAttrs)
        
        y += 13
        
        // 2. 主星與四化
        let starFont = UIFont(name: "PingFangTC-Medium", size: 8) ?? UIFont.systemFont(ofSize: 8)
        for star in palace.majorStars {
            var starText = star.name
            if let b = star.brightness { starText += "(\(b.rawValue))" }
            if let tf = star.natalTransformation { starText += "[\(tf.rawValue)]" }
            
            let color = (star.natalTransformation != nil) ?
                UIColor(red: 0.851, green: 0.380, blue: 0.220, alpha: 1.0) :
                UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)
            
            let starAttrs: [NSAttributedString.Key: Any] = [.font: starFont, .foregroundColor: color]
            starText.draw(at: CGPoint(x: x, y: y), withAttributes: starAttrs)
            y += 10
        }
        
        // 3. 吉星與煞星
        var auxList: [String] = []
        for s in palace.luckyStars.prefix(2) { auxList.append(s.name) }
        for s in palace.fierceStars.prefix(2) { auxList.append(s.name) }
        
        let auxText = auxList.joined(separator: " ")
        if !auxText.isEmpty {
            let auxAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 7),
                .foregroundColor: UIColor(red: 0.35, green: 0.45, blue: 0.35, alpha: 1.0)
            ]
            auxText.draw(at: CGPoint(x: x, y: rect.maxY - 19), withAttributes: auxAttrs)
        }
        
        // 4. 天干地支
        let stemBranch = "\(palace.heavenlyStem.name)\(palace.earthlyBranch.name)"
        let sbAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 7.5),
            .foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        ]
        let sbSize = stemBranch.size(withAttributes: sbAttrs)
        stemBranch.draw(at: CGPoint(x: rect.maxX - sbSize.width - 3, y: rect.maxY - 11), withAttributes: sbAttrs)
    }
    
    // MARK: - 繪製 PDF 中宮天心
    private static func drawPDFCenterPalace(chart: AstrolabeChart, in rect: CGRect, context: CGContext) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        UIColor(red: 0.94, green: 0.91, blue: 0.85, alpha: 1.0).setFill()
        path.fill()
        UIColor(red: 0.769, green: 0.608, blue: 0.235, alpha: 0.9).setStroke()
        path.lineWidth = 1.2
        path.stroke()
        
        var y = rect.origin.y + 14
        let centerX = rect.origin.x + (rect.width / 2)
        
        func drawCenteredText(_ text: String, font: UIFont, color: UIColor, spacing: CGFloat) {
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
            let size = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: centerX - (size.width / 2), y: y), withAttributes: attrs)
            y += size.height + spacing
        }
        
        drawCenteredText("紫 微 天 紀 星 盤", font: UIFont(name: "PingFangTC-Semibold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14), color: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0), spacing: 6)
        
        drawCenteredText("\(chart.lunarInfo.baZiString)", font: UIFont(name: "PingFangTC-Medium", size: 10) ?? UIFont.boldSystemFont(ofSize: 10), color: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0), spacing: 6)
        
        drawCenteredText("\(chart.gender.rawValue)・\(chart.elementBureau.name)", font: UIFont(name: "PingFangTC-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10), color: UIColor(red: 0.851, green: 0.380, blue: 0.220, alpha: 1.0), spacing: 6)
        
        drawCenteredText("命主：\(chart.lifeMasterStar)    身主：\(chart.bodyMasterStar)", font: UIFont.systemFont(ofSize: 9), color: UIColor(red: 0.373, green: 0.294, blue: 0.471, alpha: 1.0), spacing: 6)
        
        if !chart.patterns.isEmpty {
            drawCenteredText("★ 檢測到 \(chart.patterns.count) 個天紀格局 (詳見次頁)", font: UIFont.boldSystemFont(ofSize: 9), color: UIColor(red: 0.851, green: 0.380, blue: 0.220, alpha: 1.0), spacing: 4)
        }
    }
    
    // MARK: - 第二頁繪製：倪海廈《天紀》經典格局研判與修心指南
    private static func drawPageTwo(chart: AstrolabeChart, in rect: CGRect, context: CGContext) {
        // 羊皮紙底色與邊框
        let bgPath = UIBezierPath(rect: rect)
        UIColor(red: 0.98, green: 0.965, blue: 0.933, alpha: 1.0).setFill()
        bgPath.fill()
        
        let border = UIBezierPath(roundedRect: rect.insetBy(dx: 18, dy: 18), cornerRadius: 8)
        UIColor(red: 0.81, green: 0.73, blue: 0.61, alpha: 1.0).setStroke()
        border.lineWidth = 1.0
        border.stroke()
        
        var currentY: CGFloat = 36.0
        
        // 標題
        let title = "倪海廈《天紀》格局研判與修心指引"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "PingFangTC-Semibold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)
        ]
        let titleSize = title.size(withAttributes: titleAttrs)
        title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: currentY), withAttributes: titleAttrs)
        currentY += titleSize.height + 16
        
        let contentWidth = pageWidth - (margin * 2)
        
        if chart.patterns.isEmpty {
            let note = "本命格局平正溫和，無極端偏煞，行運以穩健中求進展為上。"
            note.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: 40), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)
            ])
            currentY += 40
        } else {
            for pattern in chart.patterns.prefix(4) {
                // 格局卡片
                let cardRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 110)
                let card = UIBezierPath(roundedRect: cardRect, cornerRadius: 6)
                UIColor(red: 0.953, green: 0.922, blue: 0.867, alpha: 0.8).setFill()
                card.fill()
                UIColor(red: 0.81, green: 0.73, blue: 0.61, alpha: 0.8).setStroke()
                card.lineWidth = 0.8
                card.stroke()
                
                var cardY = cardRect.origin.y + 8
                let cardX = cardRect.origin.x + 10
                let textW = cardRect.width - 20
                
                // 格局名稱與吉凶標籤
                let nameStr = "【\(pattern.name)】 (\(pattern.isAuspicious ? "吉格" : "變局"))"
                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "PingFangTC-Semibold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: pattern.isAuspicious ? UIColor(red: 0.851, green: 0.380, blue: 0.220, alpha: 1.0) : UIColor(red: 0.373, green: 0.294, blue: 0.471, alpha: 1.0)
                ]
                nameStr.draw(at: CGPoint(x: cardX, y: cardY), withAttributes: nameAttrs)
                cardY += 18
                
                pattern.description.draw(in: CGRect(x: cardX, y: cardY, width: textW, height: 28), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 9.5),
                    .foregroundColor: UIColor(red: 0.25, green: 0.35, blue: 0.25, alpha: 1.0)
                ])
                cardY += 28
                
                let comment = "倪師點評：\(pattern.tianjiComment)"
                comment.draw(in: CGRect(x: cardX, y: cardY, width: textW, height: 44), withAttributes: [
                    .font: UIFont(name: "PingFangTC-Regular", size: 9) ?? UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor(red: 0.15, green: 0.3, blue: 0.2, alpha: 1.0)
                ])
                
                currentY += cardRect.height + 12
            }
        }
        
        // 倪師《天紀》核心寄語
        let quoteRect = CGRect(x: margin, y: currentY + 10, width: contentWidth, height: 110)
        let quoteCard = UIBezierPath(roundedRect: quoteRect, cornerRadius: 6)
        UIColor(red: 0.94, green: 0.91, blue: 0.85, alpha: 0.6).setFill()
        quoteCard.fill()
        
        var qY = quoteRect.origin.y + 10
        let qX = quoteRect.origin.x + 12
        let qW = quoteRect.width - 24
        
        "倪海廈先生《天紀》修心法門：".draw(at: CGPoint(x: qX, y: qY), withAttributes: [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 1.0)
        ])
        qY += 18
        
        let quoteText = "「算命之目的，絕非消極認命，而在於『知己知彼，順應天時』。人人皆有先天命盤之強弱，然心念一轉，言行即變；言行一變，命運自開。遇逆境如舟逢大浪，穩住舵柄自能渡過；逢順流當廣結善緣、戒驕戒躁，方能永保吉慶。」"
        quoteText.draw(in: CGRect(x: qX, y: qY, width: qW, height: 75), withAttributes: [
            .font: UIFont(name: "PingFangTC-Regular", size: 9.5) ?? UIFont.systemFont(ofSize: 9.5),
            .foregroundColor: UIColor(red: 0.204, green: 0.322, blue: 0.247, alpha: 0.9)
        ])
    }
}
