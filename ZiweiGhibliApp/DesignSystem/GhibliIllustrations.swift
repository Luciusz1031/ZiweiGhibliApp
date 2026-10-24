import SwiftUI

// MARK: - 吉卜力超可愛「小鹿兒」手繪吉祥物
public struct CuteDeerMascotView: View {
    public var size: CGFloat = 80
    public var showGreeting: Bool = false
    public var greetingText: String = "你好呀！我是小鹿兒～"
    
    @State private var isBreathing: Bool = false
    @State private var starBlink: Bool = false
    
    public init(size: CGFloat = 80, showGreeting: Bool = false, greetingText: String = "你好呀！我是小鹿兒～") {
        self.size = size
        self.showGreeting = showGreeting
        self.greetingText = greetingText
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                // 1. 溫暖柔和的森林綠光暈底圈
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [GhibliTheme.laputaSky.opacity(0.35), GhibliTheme.parchmentBg.opacity(0.1)],
                            center: .center,
                            startRadius: size * 0.2,
                            endRadius: size * 0.6
                        )
                    )
                    .frame(width: size * 1.25, height: size * 1.25)
                
                // 2. 小鹿兒耳朵 (帶輕微動態呼吸)
                HStack(spacing: size * 0.45) {
                    // 左耳
                    Capsule()
                        .fill(Color(red: 0.88, green: 0.68, blue: 0.48))
                        .frame(width: size * 0.18, height: size * 0.35)
                        .rotationEffect(.degrees(isBreathing ? -28 : -22))
                        .overlay(
                            Capsule()
                                .fill(Color(red: 0.98, green: 0.82, blue: 0.78))
                                .frame(width: size * 0.1, height: size * 0.22)
                        )
                    
                    // 右耳
                    Capsule()
                        .fill(Color(red: 0.88, green: 0.68, blue: 0.48))
                        .frame(width: size * 0.18, height: size * 0.35)
                        .rotationEffect(.degrees(isBreathing ? 28 : 22))
                        .overlay(
                            Capsule()
                                .fill(Color(red: 0.98, green: 0.82, blue: 0.78))
                                .frame(width: size * 0.1, height: size * 0.22)
                        )
                }
                .offset(y: -size * 0.26)
                
                // 3. 小鹿萌角與頭頂星塵 (萌萌小樹枝與金星)
                HStack(spacing: size * 0.3) {
                    // 左角
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.62, green: 0.44, blue: 0.32))
                            .frame(width: size * 0.08, height: size * 0.28)
                            .rotationEffect(.degrees(-15))
                        // 小綠葉芽
                        Circle()
                            .fill(Color(red: 0.45, green: 0.72, blue: 0.38))
                            .frame(width: size * 0.09, height: size * 0.09)
                            .offset(x: -size * 0.06, y: -size * 0.1)
                    }
                    
                    // 右角帶金星
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.62, green: 0.44, blue: 0.32))
                            .frame(width: size * 0.08, height: size * 0.28)
                            .rotationEffect(.degrees(15))
                        // 閃爍小金星
                        Image(systemName: "sparkle")
                            .font(.system(size: size * 0.16))
                            .foregroundColor(GhibliTheme.magicBrass)
                            .scaleEffect(starBlink ? 1.25 : 0.85)
                            .offset(x: size * 0.08, y: -size * 0.12)
                    }
                }
                .offset(y: -size * 0.38)
                
                // 4. 小鹿兒頭部 (圓潤暖焦糖色)
                Circle()
                    .fill(Color(red: 0.92, green: 0.74, blue: 0.54))
                    .frame(width: size * 0.75, height: size * 0.75)
                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
                
                // 5. 額頭白斑點 (小鹿斑比紋)
                VStack(spacing: size * 0.03) {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: size * 0.07, height: size * 0.07)
                    HStack(spacing: size * 0.06) {
                        Circle()
                            .fill(Color.white.opacity(0.85))
                            .frame(width: size * 0.05, height: size * 0.05)
                        Circle()
                            .fill(Color.white.opacity(0.85))
                            .frame(width: size * 0.05, height: size * 0.05)
                    }
                }
                .offset(y: -size * 0.16)
                
                // 6. 大眼睛與腮紅
                VStack(spacing: size * 0.02) {
                    // 大眼
                    HStack(spacing: size * 0.28) {
                        // 左眼 (水汪汪吉卜力萌眼)
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.18, green: 0.14, blue: 0.12))
                                .frame(width: size * 0.14, height: size * 0.14)
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.05, height: size * 0.05)
                                .offset(x: -size * 0.025, y: -size * 0.025)
                        }
                        
                        // 右眼
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.18, green: 0.14, blue: 0.12))
                                .frame(width: size * 0.14, height: size * 0.14)
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.05, height: size * 0.05)
                                .offset(x: -size * 0.025, y: -size * 0.025)
                        }
                    }
                    
                    // 粉嫩腮紅
                    HStack(spacing: size * 0.38) {
                        Circle()
                            .fill(Color(red: 0.98, green: 0.58, blue: 0.55).opacity(0.65))
                            .frame(width: size * 0.13, height: size * 0.08)
                        Circle()
                            .fill(Color(red: 0.98, green: 0.58, blue: 0.55).opacity(0.65))
                            .frame(width: size * 0.13, height: size * 0.08)
                    }
                    .offset(y: -size * 0.01)
                }
                .offset(y: -size * 0.04)
                
                // 7. 白色嘴鼻區域
                Ellipse()
                    .fill(Color(red: 0.99, green: 0.96, blue: 0.92))
                    .frame(width: size * 0.36, height: size * 0.26)
                    .overlay(
                        VStack(spacing: 1) {
                            // 黑色小鼻子
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 0.25, green: 0.18, blue: 0.15))
                                .frame(width: size * 0.09, height: size * 0.06)
                            // 溫暖微笑
                            Image(systemName: "chevron.down")
                                .font(.system(size: size * 0.07, weight: .bold))
                                .foregroundColor(Color(red: 0.35, green: 0.25, blue: 0.2))
                        }
                    )
                    .offset(y: size * 0.13)
            }
            .frame(width: size, height: size)
            .scaleEffect(isBreathing ? 1.03 : 0.97)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    isBreathing = true
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    starBlink = true
                }
            }
            
            // 對話框提示 (若啟用)
            if showGreeting {
                VStack(alignment: .leading, spacing: 3) {
                    Text("小鹿兒")
                        .font(GhibliTheme.titleFont(size: 13))
                        .foregroundColor(GhibliTheme.magicBrass)
                    Text(greetingText)
                        .font(GhibliTheme.bodyFont(size: 13))
                        .foregroundColor(GhibliTheme.forestMoss)
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(GhibliTheme.borderBrass, lineWidth: 1)
                        )
                )
            }
        }
    }
}

// MARK: - 吉卜力小煤炭精靈 (Soot Sprite with Star)
public struct SootSpriteView: View {
    public var size: CGFloat = 36
    @State private var wobble: Bool = false
    
    public init(size: CGFloat = 36) {
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // 毛茸茸黑球身體
            Circle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.16))
                .frame(width: size, height: size)
                .overlay(
                    // 毛邊感
                    Circle()
                        .stroke(Color(red: 0.22, green: 0.22, blue: 0.24), style: StrokeStyle(lineWidth: 2, dash: [2, 3]))
                )
            
            // 兩顆大白眼與小眼珠
            HStack(spacing: size * 0.12) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.36, height: size * 0.36)
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.15, height: size * 0.15)
                        .offset(x: size * 0.04, y: -size * 0.03)
                }
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: size * 0.36, height: size * 0.36)
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.15, height: size * 0.15)
                        .offset(x: size * 0.04, y: -size * 0.03)
                }
            }
            .offset(y: -size * 0.06)
            
            // 手中抱著的星星金幣
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.32))
                .foregroundColor(GhibliTheme.magicBrass)
                .offset(x: size * 0.25, y: size * 0.2)
        }
        .frame(width: size * 1.3, height: size * 1.3)
        .rotationEffect(.degrees(wobble ? 6 : -6))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                wobble = true
            }
        }
    }
}

// MARK: - 十二宮位專屬可愛圖示輔助
public struct PalaceIconHelper {
    public static func icon(for type: PalaceType) -> String {
        switch type {
        case .life: return "🌱"      // 命宮: 萌芽生命
        case .siblings: return "🌰"  // 兄弟: 結伴松鼠與橡果
        case .marriage: return "🌸"  // 夫妻: 浪漫櫻花
        case .children: return "🐣"  // 子女: 破殼小雀
        case .wealth: return "🪙"    // 財帛: 黃金小寶袋
        case .health: return "🍵"    // 疾厄: 元氣溫暖茶
        case .travel: return "⛵"    // 遷移: 雲海小帆船
        case .friends: return "🎈"   // 交友: 熱氣球好友
        case .career: return "🏆"    // 官祿: 榮耀金桂冠
        case .property: return "🏡"  // 田宅: 森林小樹屋
        case .happiness: return "🌙" // 福德: 靜謐月光枕
        case .parents: return "🦉"   // 父母: 守護老貓頭鷹
        }
    }
    
    public static func badgeColor(for type: PalaceType) -> Color {
        switch type {
        case .life: return GhibliTheme.spiritPurple
        case .wealth, .career: return GhibliTheme.magicBrass
        case .marriage, .children: return GhibliTheme.calciferOrange
        default: return GhibliTheme.forestMoss
        }
    }
}
