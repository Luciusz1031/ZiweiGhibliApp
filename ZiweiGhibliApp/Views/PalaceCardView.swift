import SwiftUI

public struct PalaceCardView: View {
    public let palace: PalaceData
    public var isSelected: Bool = false
    public var onTap: () -> Void = {}
    
    public var body: some View {
        Button(action: {
            HapticManager.triggerImpact(style: .light)
            onTap()
        }) {
            VStack(spacing: 3) {
                // 1. 宮位頂部欄：宮名 + 大限年齡區間
                HStack(alignment: .center, spacing: 2) {
                    Text(palace.type.name)
                        .font(GhibliTheme.titleFont(size: 13))
                        .foregroundColor(palace.isLifePalace ? GhibliTheme.spiritPurple : GhibliTheme.forestMoss)
                    
                    if palace.isLifePalace {
                        Text("命")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(GhibliTheme.spiritPurple)
                            .clipShape(Capsule())
                    }
                    if palace.isBodyPalace {
                        Text("身")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(GhibliTheme.forestMoss)
                            .clipShape(Capsule())
                    }
                    
                    Spacer(minLength: 0)
                    
                    Text("\(palace.decadeStartAge)-\(palace.decadeEndAge)")
                        .font(GhibliTheme.noteFont(size: 9))
                        .foregroundColor(GhibliTheme.magicBrass)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                
                Divider()
                    .background(GhibliTheme.borderBrass.opacity(0.4))
                    .padding(.horizontal, 2)
                
                // 2. 主星與四化展示區域
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(palace.majorStars) { star in
                        HStack(spacing: 2) {
                            Text(star.name)
                                .font(GhibliTheme.bodyFont(size: 11))
                                .foregroundColor(GhibliTheme.forestMoss)
                                .fontWeight(.bold)
                            
                            if let b = star.brightness {
                                Text(b.rawValue)
                                    .font(GhibliTheme.noteFont(size: 8))
                                    .foregroundColor(GhibliTheme.magicBrass)
                            }
                            
                            // 生年四化
                            if let tf = star.natalTransformation {
                                TransformationBadge(type: tf)
                            }
                            
                            // 大限四化 (若有)
                            if let dtf = star.decadeTransformation {
                                TransformationBadge(type: dtf)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                
                // 3. 吉星與煞星 (小字並列)
                HStack(alignment: .top, spacing: 2) {
                    // 吉曜
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(palace.luckyStars.prefix(3)) { star in
                            Text(star.name)
                                .font(.system(size: 9, design: .serif))
                                .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.25))
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    // 煞曜與雜星
                    VStack(alignment: .trailing, spacing: 1) {
                        ForEach(palace.fierceStars.prefix(3)) { star in
                            Text(star.name)
                                .font(.system(size: 9, design: .serif))
                                .foregroundColor(GhibliTheme.tabooRed.opacity(0.85))
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                Spacer(minLength: 0)
                
                // 4. 底部天干地支
                HStack {
                    if let dynamicName = palace.dynamicAnnualName {
                        Text(dynamicName)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(GhibliTheme.laputaSky)
                    }
                    
                    Spacer()
                    
                    Text("\(palace.heavenlyStem.name)\(palace.earthlyBranch.name)")
                        .font(GhibliTheme.noteFont(size: 10))
                        .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .parchmentStyle(isHighlighted: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
