import SwiftUI

public struct GhibliTheme {
    // MARK: - 吉卜力手繪水彩調色盤
    
    /// 羊皮紙底色 (如古老航海圖/魔法書紙張)
    public static let parchmentBg = Color(red: 0.98, green: 0.965, blue: 0.933) // #FAF6EE
    
    /// 宮位卡片底色 (溫潤米象牙白)
    public static let parchmentCard = Color(red: 0.953, green: 0.922, blue: 0.867) // #F3EBDD
    
    /// 手撕紙與邊框雕花古銅色
    public static let borderBrass = Color(red: 0.81, green: 0.73, blue: 0.61) // #CFBA9C
    
    /// 龍貓森林深苔綠 (標題、主文字、深沉莊嚴)
    public static let forestMoss = Color(red: 0.204, green: 0.322, blue: 0.247) // #34523F
    
    /// 天空之城晴空藍 (流年、大限軌道、希望)
    public static let laputaSky = Color(red: 0.384, green: 0.584, blue: 0.722) // #6295B8
    
    /// 蓬鬆白雲 (純淨雲朵)
    public static let cloudWhite = Color(red: 0.992, green: 0.980, blue: 0.957) // #FDFAF4
    
    /// 卡西法火光橙 (四化化祿、化權、吉星光輝)
    public static let calciferOrange = Color(red: 0.851, green: 0.380, blue: 0.220) // #D96138
    
    /// 霍爾移動城堡黃銅金 (中宮星盤、日晷刻度)
    public static let magicBrass = Color(red: 0.769, green: 0.608, blue: 0.235) // #C49B3C
    
    /// 紫微靈動紫 (十四主星、化科、智慧)
    public static let spiritPurple = Color(red: 0.373, green: 0.294, blue: 0.471) // #5F4B78
    
    /// 四化化忌沉穩硃砂紅
    public static let tabooRed = Color(red: 0.78, green: 0.25, blue: 0.22) // #C74038
    
    // MARK: - 字體風格 (Serif 襯線古風)
    public static func titleFont(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    
    public static func bodyFont(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }
    
    public static func noteFont(size: CGFloat = 11) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}

// MARK: - 觸覺反饋輔助
public struct HapticManager {
    public static func triggerSelection() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
    
    public static func triggerSuccess() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    public static func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}
