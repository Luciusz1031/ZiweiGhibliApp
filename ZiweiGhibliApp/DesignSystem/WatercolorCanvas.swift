import SwiftUI

// MARK: - 羊皮紙微浮雕容器 (Parchment Card Container)
public struct ParchmentCardModifier: ViewModifier {
    var isHighlighted: Bool = false
    var cornerRadius: CGFloat = 12
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHighlighted ? GhibliTheme.cloudWhite : GhibliTheme.parchmentCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                isHighlighted ? GhibliTheme.magicBrass : GhibliTheme.borderBrass,
                                lineWidth: isHighlighted ? 2.0 : 1.0
                            )
                    )
                    .shadow(
                        color: isHighlighted ? GhibliTheme.magicBrass.opacity(0.3) : Color.black.opacity(0.06),
                        radius: isHighlighted ? 6 : 3,
                        x: 0,
                        y: 2
                    )
            )
    }
}

public extension View {
    func parchmentStyle(isHighlighted: Bool = false, cornerRadius: CGFloat = 12) -> some View {
        self.modifier(ParchmentCardModifier(isHighlighted: isHighlighted, cornerRadius: cornerRadius))
    }
}

// MARK: - 四化寶石徽章 (Four Transformation Gem Badges)
public struct TransformationBadge: View {
    public let type: TransformationType
    
    public var body: some View {
        Text(type.rawValue)
            .font(.system(size: 9, weight: .bold, design: .serif))
            .foregroundColor(.white)
            .frame(width: 14, height: 14)
            .background(
                Circle()
                    .fill(badgeColor)
                    .shadow(color: badgeColor.opacity(0.4), radius: 2, x: 0, y: 1)
            )
    }
    
    private var badgeColor: Color {
        switch type {
        case .lu: return GhibliTheme.calciferOrange // 祿：火橙生發
        case .quan: return Color(red: 0.88, green: 0.58, blue: 0.15) // 權：金黃威勢
        case .ke: return GhibliTheme.laputaSky // 科：晴空青藍名聲
        case .ji: return GhibliTheme.tabooRed // 忌：硃砂深紅收斂
        }
    }
}

// MARK: - 吉卜力風動態浮雲背景 (Floating Cloud Header)
public struct FloatingCloudHeader: View {
    @State private var cloudOffset: CGFloat = -20
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // 背景淡天色漸層
            LinearGradient(
                colors: [GhibliTheme.laputaSky.opacity(0.25), GhibliTheme.parchmentBg],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 雲朵層
            HStack(spacing: 40) {
                CloudShape()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 120, height: 40)
                    .offset(x: cloudOffset)
                
                CloudShape()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 160, height: 50)
                    .offset(x: -cloudOffset * 0.7)
            }
        }
        .frame(height: 70)
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                cloudOffset = 25
            }
        }
    }
}

// 簡單手繪雲朵形狀
public struct CloudShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.2, y: h * 0.7))
        path.addQuadCurve(to: CGPoint(x: w * 0.4, y: h * 0.2), control: CGPoint(x: w * 0.2, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w * 0.7, y: h * 0.3), control: CGPoint(x: w * 0.55, y: h * 0.05))
        path.addQuadCurve(to: CGPoint(x: w * 0.85, y: h * 0.7), control: CGPoint(x: w * 0.85, y: h * 0.3))
        path.addQuadCurve(to: CGPoint(x: w * 0.2, y: h * 0.7), control: CGPoint(x: w * 0.5, y: h * 0.95))
        path.closeSubpath()
        return path
    }
}
