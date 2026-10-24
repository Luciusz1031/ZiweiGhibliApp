import SwiftUI

public struct SchoolSettingsView: View {
    @Binding public var config: SchoolConfig
    public var onSave: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ZStack {
                GhibliTheme.parchmentBg.ignoresSafeArea()
                
                Form {
                    Section(header: Text("倪海廈《天紀》與排盤流派").font(GhibliTheme.bodyFont(size: 13))) {
                        Picker("庚干四化規則", selection: $config.gengRule) {
                            ForEach(GengTransformationRule.allCases) { rule in
                                Text(rule.rawValue).tag(rule)
                            }
                        }
                        
                        Picker("換日與子時規則", selection: $config.dayChangeRule) {
                            ForEach(DayChangeRule.allCases) { rule in
                                Text(rule.rawValue).tag(rule)
                            }
                        }
                        
                        Text(config.dayChangeRule.description)
                            .font(GhibliTheme.noteFont(size: 11))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                        
                        Picker("閏月處理方式", selection: $config.leapMonthRule) {
                            ForEach(LeapMonthRule.allCases) { rule in
                                Text(rule.rawValue).tag(rule)
                            }
                        }
                    }
                    
                    Section(header: Text("天文真太陽時核對").font(GhibliTheme.bodyFont(size: 13))) {
                        Toggle("啟用經度與均時差校正", isOn: $config.useTrueSolarTime)
                        Toggle("自動扣除歷史夏令時 (DST)", isOn: $config.autoAdjustDST)
                        
                        Text("紫微斗數以日影正午過中天為午時。開啟後將依據出生地精確經度與地球公轉均時差自動換算為真太陽時。")
                            .font(GhibliTheme.noteFont(size: 11))
                            .foregroundColor(GhibliTheme.forestMoss.opacity(0.7))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("流派與天文設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        HapticManager.triggerSuccess()
                        onSave()
                        dismiss()
                    }
                    .foregroundColor(GhibliTheme.calciferOrange)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
