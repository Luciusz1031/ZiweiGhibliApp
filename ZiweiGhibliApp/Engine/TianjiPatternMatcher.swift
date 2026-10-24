import Foundation

public class TianjiPatternMatcher {
    
    /// 根據命盤 12 宮與命宮地支，進行倪海廈《天紀》經典格局匹配
    public static func matchPatterns(palaces: [PalaceData], lifeBranch: EarthlyBranch) -> [TianjiPattern] {
        var matched: [TianjiPattern] = []
        
        let lifePalace = palaces[lifeBranch.rawValue]
        let lifeStarNames = Set(lifePalace.stars.map { $0.name })
        
        // 三方四正宮位 (命宮、事業/官祿、財帛、遷移/對宮)
        let careerBranch = EarthlyBranch(rawValue: (lifeBranch.rawValue + 4) % 12)!
        let wealthBranch = EarthlyBranch(rawValue: (lifeBranch.rawValue + 8) % 12)!
        let travelBranch = EarthlyBranch(rawValue: (lifeBranch.rawValue + 6) % 12)!
        
        let sanFangSiZhengBranches = [lifeBranch, careerBranch, wealthBranch, travelBranch]
        var sanFangStars: Set<String> = []
        for b in sanFangSiZhengBranches {
            for s in palaces[b.rawValue].stars {
                sanFangStars.insert(s.name)
            }
        }
        
        // 1. 紫府同宮格
        if (lifeBranch == .yin || lifeBranch == .shen) &&
            lifeStarNames.contains("紫微") && lifeStarNames.contains("天府") {
            matched.append(TianjiPattern(
                name: "紫府同宮格",
                isAuspicious: true,
                description: "命宮在寅或申，紫微星與天府星同宮坐命，三方吉星相會。",
                tianjiComment: "倪海廈《天紀》曰：紫微為北極帝星，天府為南斗令星，二星同宮於寅申，性格忠厚圓融、福祿雙全。若加會左右昌曲，必為政界樞紐或商界領袖。",
                classicalPoem: "同宮紫府貴生人，天乙加臨福祿臻。甲己生人皆大吉，一生富貴秉朝綸。"
            ))
        }
        
        // 2. 日月並明格 (丹墀墀桂格)
        let siPalace = palaces[EarthlyBranch.si.rawValue]
        let youPalace = palaces[EarthlyBranch.you.rawValue]
        let sunInSi = siPalace.stars.contains { $0.name == "太陽" }
        let moonInYou = youPalace.stars.contains { $0.name == "太陰" }
        if (lifeBranch == .chou || lifeBranch == .wei) && sunInSi && moonInYou {
            matched.append(TianjiPattern(
                name: "日月並明格",
                isAuspicious: true,
                description: "命宮在丑未，巳宮太陽旺、酉宮太陰旺，雙雙照入命宮。",
                tianjiComment: "倪海廈《天紀》曰：日出巳時光輝普照，月出酉時冰清玉潔。此格之人心地光明磊落，少年得志，早歲即展露鋒芒，一生順遂亨通。",
                classicalPoem: "日月並明金馬步，榮華富貴步蟾宮。天生聰明智慧廣，少年平步上雲霄。"
            ))
        }
        
        // 3. 日照雷門格
        if lifeBranch == .mao && lifeStarNames.contains("太陽") && lifeStarNames.contains("天梁") {
            matched.append(TianjiPattern(
                name: "日照雷門格 (日出扶桑)",
                isAuspicious: true,
                description: "太陽與天梁在卯宮坐命，卯為東方震雷之位，日光萬丈。",
                tianjiComment: "倪師《天紀》論命：太陽居卯位為朝陽初昇，名日照雷門。此人胸襟開闊，一生正氣浩然，宜從公職、法政或大企業領導，名震八方。",
                classicalPoem: "太陽卯位貴堪誇，必主平生富貴家。若得化祿昌曲會，威名赫赫播天涯。"
            ))
        }
        
        // 4. 月朗天門格
        if lifeBranch == .hai && lifeStarNames.contains("太陰") {
            matched.append(TianjiPattern(
                name: "月朗天門格",
                isAuspicious: true,
                description: "太陰星在亥宮獨坐入命，亥為乾坤天門，太陰入廟最為清瑩。",
                tianjiComment: "倪師《天紀》云：月朗天門乃極貴之格，夜生人尤美。主為人文質彬彬、博學多才，多有跨國發展機遇，晚景財官雙美。",
                classicalPoem: "月朗天門富且榮，發財必定自青年。科權若在三方照，玉殿傳臚姓名宣。"
            ))
        }
        
        // 5. 巨日同宮格
        if (lifeBranch == .yin || lifeBranch == .shen) &&
            lifeStarNames.contains("太陽") && lifeStarNames.contains("巨門") {
            matched.append(TianjiPattern(
                name: "巨日同宮格",
                isAuspicious: true,
                description: "太陽巨門同在寅宮或申宮守命，化解巨門暗曜之氣。",
                tianjiComment: "《天紀》要旨：巨門為暗星主口舌是非，逢太陽烈火則暗霾盡驅。主口才便給、辯才無礙，極利法官、外交、教學或以口為業之人，白手起家創大業。",
                classicalPoem: "巨日同宮在寅申，白手成家最精神。若逢吉曜多富貴，威權赫奕拜皇仁。"
            ))
        }
        
        // 6. 機月同梁格
        let jiYueTongLiang = ["天機", "太陰", "天同", "天梁"]
        if jiYueTongLiang.allSatisfy({ sanFangStars.contains($0) }) {
            matched.append(TianjiPattern(
                name: "機月同梁格",
                isAuspicious: true,
                description: "三方四正會齊天機、太陰、天同、天梁四顆吉星。",
                tianjiComment: "倪海廈《天紀》云：機月同梁做吏人。最擅長策劃、幕僚、公務員及專業技術研發。心思細膩有條理，不喜涉足風浪之險，一生平穩有爵祿。",
                classicalPoem: "寅申四位天機是，同梁月合主多才。文章卓犖稱雄手，必在公門作宰臺。"
            ))
        }
        
        // 7. 殺破狼格
        let shaPoLang = ["七殺", "破軍", "貪狼"]
        if shaPoLang.allSatisfy({ sanFangStars.contains($0) }) {
            matched.append(TianjiPattern(
                name: "殺破狼格 (動態開創格)",
                isAuspicious: true,
                description: "命宮、財帛、事業三方由七殺、破軍、貪狼鎮守。",
                tianjiComment: "倪海廈《天紀》精闢斷語：殺破狼為人生巨大轉變之樞紐。此性格局開拓力極強，敢為天下先，遇困境能絕地逢生。動盪愈大，成就愈宏偉，為商戰名將或創業先鋒。",
                classicalPoem: "七殺破軍與貪狼，入命三方動盪長。英雄開闢乾坤手，千錘百鍊現鋒芒。"
            ))
        }
        
        // 8. 陽梁昌祿格
        let yangLiangChangLu = ["太陽", "天梁", "文昌", "祿存"]
        if yangLiangChangLu.allSatisfy({ sanFangStars.contains($0) }) {
            matched.append(TianjiPattern(
                name: "陽梁昌祿格",
                isAuspicious: true,
                description: "三方四正會齊太陽、天梁、文昌與祿存四星。",
                tianjiComment: "倪海廈《天紀》極讚之考運與貴格：凡逢此格，科考無往不利，名列前茅，在專業認證、學術發表、公家考試上一鳴驚人，仕途青雲直上。",
                classicalPoem: "陽梁昌祿位居高，臚唱金鑾第一鰲。學富五車身顯達，平生榮貴佐王朝。"
            ))
        }
        
        // 9. 馬頭帶劍格 (午宮擎羊)
        if lifeBranch == .wu && lifeStarNames.contains("擎羊") {
            matched.append(TianjiPattern(
                name: "馬頭帶劍格",
                isAuspicious: false,
                description: "擎羊在午宮坐命，午為馬，擎羊如刀劍懸於馬首。",
                tianjiComment: "倪師《天紀》警示與吉凶相參：此格主軍旅武職或開拓異鄉可立功，但一生歷經險阻刀光劍影。天紀提醒：宜以技術專長立命，忌任性冒進。",
                classicalPoem: "擎羊在午馬頭帶，威震邊疆立大勳。若見吉星終可貴，不然橫逆受艱辛。"
            ))
        }
        
        return matched
    }
}
