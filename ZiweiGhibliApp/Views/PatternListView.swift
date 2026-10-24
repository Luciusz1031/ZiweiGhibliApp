import SwiftUI

public struct PatternListView: View {
    public let patterns: [TianjiPattern]
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ZStack {
                GhibliTheme.parchmentBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("倪海廈《天紀》命盤格局研判")
                            .font(GhibliTheme.titleFont(size: 20))
                            .foregroundColor(GhibliTheme.forestMoss)
                            .padding(.top, 6)
                        
                        Text("共檢測到 \(patterns.count) 個格局。倪師指出：格局乃前人歸納之星曜匯聚象徵，得吉格不可驕矜，遇險格尤當修身克己。")
                            .font(GhibliTheme.bodyFont(size: 13))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.8))
                            .lineSpacing(3)
                        
                        if patterns.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32))
                                    .foregroundColor(GhibliTheme.magicBrass)
                                Text("本命星辰佈局平正和潤，未顯極端特殊格局，一生平順自如。")
                                    .font(GhibliTheme.bodyFont(size: 14))
                                    .foregroundColor(GhibliTheme.forestMoss)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .parchmentStyle()
                        } else {
                            ForEach(patterns) { pattern in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(pattern.name)
                                            .font(GhibliTheme.titleFont(size: 17))
                                            .foregroundColor(GhibliTheme.forestMoss)
                                        
                                        Spacer()
                                        
                                        Text(pattern.isAuspicious ? "吉格" : "變局")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(pattern.isAuspicious ? GhibliTheme.calciferOrange : GhibliTheme.spiritPurple)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text(pattern.description)
                                        .font(GhibliTheme.bodyFont(size: 13))
                                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.9))
                                    
                                    if !pattern.classicalPoem.isEmpty {
                                        Text("📜 古賦云：「\(pattern.classicalPoem)」")
                                            .font(.system(size: 12, design: .serif))
                                            .foregroundColor(GhibliTheme.magicBrass)
                                            .padding(.vertical, 2)
                                    }
                                    
                                    Text(pattern.tianjiComment)
                                        .font(GhibliTheme.bodyFont(size: 13))
                                        .foregroundColor(Color(red: 0.18, green: 0.35, blue: 0.22))
                                        .lineSpacing(3)
                                        .padding(8)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(8)
                                }
                                .padding()
                                .parchmentStyle(isHighlighted: pattern.isAuspicious)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(GhibliTheme.forestMoss)
                }
            }
        }
    }
}
