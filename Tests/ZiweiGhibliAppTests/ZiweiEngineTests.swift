import XCTest
@testable import ZiweiGhibliApp

final class ZiweiEngineTests: XCTestCase {
    
    // 測試 1：真太陽時偏差校準
    func testSolarTimeCalculation() {
        let cal = Calendar(identifier: .gregorian)
        let testDate = cal.date(from: DateComponents(year: 2024, month: 10, day: 24, hour: 12, minute: 0))!
        let taipei = CityDatabase.defaultCity // 台北市 經度 121.5654
        
        let result = SolarTimeCalculator.calculateTrueSolarTime(for: testDate, city: taipei, adjustDST: false)
        
        // 台北偏東約 1.5654度 * 4分 = 約 +6.26分鐘
        XCTAssertGreaterThan(result.longitudeOffsetMinutes, 6.0)
        XCTAssertLessThan(result.longitudeOffsetMinutes, 6.5)
        
        // 10月下旬秋季 EOT 通常約為 +15 ~ +16 分鐘
        XCTAssertGreaterThan(result.equationOfTimeMinutes, 10.0)
        
        // 總偏差約 +21 ~ +22 分鐘
        XCTAssertGreaterThan(result.totalOffsetMinutes, 18.0)
    }
    
    // 測試 2：倪海廈《天紀》庚干四化
    func testGengStemTianjiTransformation() {
        let config = SchoolConfig(gengRule: .tianJi)
        let stars = config.gengRule.stars
        
        // 倪師主張：太陽化祿、武曲化權、太陰化科、天同化忌 (日武陰同)
        XCTAssertEqual(stars.lu, "太陽")
        XCTAssertEqual(stars.quan, "武曲")
        XCTAssertEqual(stars.ke, "太陰")
        XCTAssertEqual(stars.ji, "天同")
    }
    
    // 測試 3：完整排盤產生與宮位完整性
    func testChartGeneration() {
        let cal = Calendar(identifier: .gregorian)
        let birthDate = cal.date(from: DateComponents(year: 1990, month: 5, day: 10, hour: 8, minute: 30))!
        let chart = ZiweiEngine.generateChart(
            birthDate: birthDate,
            city: CityDatabase.defaultCity,
            gender: .male,
            config: .default
        )
        
        // 必須有且僅有 12 個宮位
        XCTAssertEqual(chart.palaces.count, 12)
        
        // 命宮與身宮必須有且僅有一個
        let lifePalaces = chart.palaces.filter { $0.isLifePalace }
        let bodyPalaces = chart.palaces.filter { $0.isBodyPalace }
        XCTAssertEqual(lifePalaces.count, 1)
        XCTAssertEqual(bodyPalaces.count, 1)
        
        // 命宮的大限起運歲數必須等於五行局局數
        XCTAssertEqual(lifePalaces.first?.decadeStartAge, chart.elementBureau.number)
    }
    
    // 測試 4：PDF 生成功能測試
    func testPDFGeneration() {
        let cal = Calendar(identifier: .gregorian)
        let birthDate = cal.date(from: DateComponents(year: 1992, month: 8, day: 8, hour: 14, minute: 20))!
        let chart = ZiweiEngine.generateChart(
            birthDate: birthDate,
            city: CityDatabase.defaultCity,
            gender: .female,
            config: .default
        )
        
        #if canImport(UIKit)
        let url = PDFReportGenerator.generatePDF(for: chart)
        XCTAssertNotNil(url)
        if let url = url {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            XCTAssertTrue(url.pathExtension == "pdf")
        }
        #endif
    }
}
