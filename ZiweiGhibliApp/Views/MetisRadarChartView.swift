import SwiftUI

public struct MetisRadarChartView: View {
    public let scores: DimensionalScores
    public var size: CGFloat = 220
    
    @State private var animatedScale: CGFloat = 0.1
    
    public init(scores: DimensionalScores, size: CGFloat = 220) {
        self.scores = scores
        self.size = size
    }
    
    // 6 個維度定義 (角度從頂部 12 點鐘順時針排列)
    // 0: 綜合, 1: 財運, 2: 感情, 3: 性格, 4: 健康, 5: 事業
    private var dimensions: [(name: String, score: Double)] {
        [
            ("綜合", scores.overall),
            ("財運", scores.wealth),
            ("感情", scores.relationship),
            ("性格", scores.personality),
            ("健康", scores.health),
            ("事業", scores.career)
        ]
    }
    
    public var body: some View {
        ZStack {
            let radius = size / 2.0
            let center = CGPoint(x: radius, y: radius)
            
            // 1. 同心正六邊形網格底層 (4 層)
            ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                HexagonPath(center: center, radius: radius * level)
                    .stroke(Color.gray.opacity(0.25), lineWidth: level == 1.0 ? 1.0 : 0.6)
            }
            
            // 2. 六條主軸線 (從中心向六個頂點發散)
            ForEach(0..<6, id: \.self) { i in
                let angle = angleForIndex(i)
                let pt = pointOnCircle(center: center, radius: radius, angle: angle)
                Path { path in
                    path.move(to: center)
                    path.addLine(to: pt)
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.8)
            }
            
            // 3. 數據多邊形區域 (藍色透明漸層填充 + 邊框)
            RadarPolygon(center: center, maxRadius: radius, dimensions: dimensions, scale: animatedScale)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.35), Color.blue.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            RadarPolygon(center: center, maxRadius: radius, dimensions: dimensions, scale: animatedScale)
                .stroke(Color(red: 0.2, green: 0.45, blue: 0.85), lineWidth: 2.0)
            
            // 4. 數據頂點圓點 (小藍點)
            ForEach(0..<6, id: \.self) { i in
                let d = dimensions[i]
                let valRatio = (d.score / 100.0) * animatedScale
                let pt = pointOnCircle(center: center, radius: radius * valRatio, angle: angleForIndex(i))
                Circle()
                    .fill(Color(red: 0.2, green: 0.45, blue: 0.85))
                    .frame(width: 5, height: 5)
                    .position(pt)
            }
            
            // 5. 外圍六角文字標籤
            ForEach(0..<6, id: \.self) { i in
                let d = dimensions[i]
                let angle = angleForIndex(i)
                let labelDistance = radius + 22
                let pt = pointOnCircle(center: center, radius: labelDistance, angle: angle)
                
                VStack(spacing: 1) {
                    Text(d.name)
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .foregroundColor(GhibliTheme.forestMoss)
                    Text("\(Int(d.score))")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color.blue)
                }
                .position(pt)
            }
        }
        .frame(width: size + 65, height: size + 65)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                animatedScale = 1.0
            }
        }
    }
    
    private func angleForIndex(_ index: Int) -> Double {
        // 頂部從 -90度 (12點鐘) 開始，每格 60 度
        return (-90.0 + Double(index) * 60.0) * .pi / 180.0
    }
    
    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }
}

// 六邊形網格路徑
struct HexagonPath: Shape {
    let center: CGPoint
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for i in 0..<6 {
            let angle = (-90.0 + Double(i) * 60.0) * .pi / 180.0
            let pt = CGPoint(
                x: center.x + radius * CGFloat(cos(angle)),
                y: center.y + radius * CGFloat(sin(angle))
            )
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

// 數據覆蓋多邊形路徑
struct RadarPolygon: Shape {
    let center: CGPoint
    let maxRadius: CGFloat
    let dimensions: [(name: String, score: Double)]
    let scale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard dimensions.count == 6 else { return path }
        
        for i in 0..<6 {
            let scoreRatio = (dimensions[i].score / 100.0) * Double(scale)
            let radius = maxRadius * CGFloat(scoreRatio)
            let angle = (-90.0 + Double(i) * 60.0) * .pi / 180.0
            let pt = CGPoint(
                x: center.x + radius * CGFloat(cos(angle)),
                y: center.y + radius * CGFloat(sin(angle))
            )
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}
