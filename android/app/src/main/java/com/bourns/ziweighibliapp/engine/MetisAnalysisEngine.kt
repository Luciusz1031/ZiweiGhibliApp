package com.bourns.ziweighibliapp.engine

import com.bourns.ziweighibliapp.models.*

data class MetisCoreCard(
    val title: String,
    val tag: String,
    val description: String
)

data class MetisDimensionReading(
    val dimensionName: String,
    val score: Int,
    val rating: String,
    val interpretation: String
)

data class MetisReading(
    val dimensionScores: Map<String, Double>,
    val oneSentenceHeadline: String,
    val threeCoreCards: List<MetisCoreCard>,
    val tenDimensions: List<MetisDimensionReading>
)

object MetisAnalysisEngine {

    fun analyze(chart: AstrolabeChart): MetisReading {
        val lifePalace = chart.palaces.firstOrNull { it.isLifePalace } ?: chart.palaces[0]
        val careerPalace = chart.palaces.firstOrNull { it.type == PalaceType.CAREER } ?: chart.palaces[0]
        val wealthPalace = chart.palaces.firstOrNull { it.type == PalaceType.WEALTH } ?: chart.palaces[0]
        val marriagePalace = chart.palaces.firstOrNull { it.type == PalaceType.MARRIAGE } ?: chart.palaces[0]
        val happinessPalace = chart.palaces.firstOrNull { it.type == PalaceType.HAPPINESS } ?: chart.palaces[0]

        val majorNames = lifePalace.majorStars.map { it.name }
        val starsStr = if (majorNames.isEmpty()) "借對宮星宿" else majorNames.joinToString("・")

        // 6 維度雷達圖分數 (0.0 ~ 1.0)
        val scores = mutableMapOf<String, Double>()
        scores["事業爆發力"] = 0.85
        scores["財富積累力"] = 0.80
        scores["感情穩定度"] = 0.75
        scores["貴人助力"] = 0.90
        scores["精神幸福感"] = 0.88
        scores["危機應變力"] = 0.82

        // 四化微調
        for (p in chart.palaces) {
            for (s in p.stars) {
                when (s.natalTransformation) {
                    TransformationType.LU -> {
                        scores["財富積累力"] = (scores["財富積累力"] ?: 0.8) + 0.05
                        scores["貴人助力"] = (scores["貴人助力"] ?: 0.8) + 0.05
                    }
                    TransformationType.QUAN -> {
                        scores["事業爆發力"] = (scores["事業爆發力"] ?: 0.8) + 0.08
                        scores["危機應變力"] = (scores["危機應變力"] ?: 0.8) + 0.05
                    }
                    TransformationType.KE -> {
                        scores["貴人助力"] = (scores["貴人助力"] ?: 0.8) + 0.08
                        scores["精神幸福感"] = (scores["精神幸福感"] ?: 0.8) + 0.05
                    }
                    TransformationType.JI -> {
                        scores["危機應變力"] = (scores["危機應變力"] ?: 0.8) + 0.06
                    }
                    null -> {}
                }
            }
        }

        // 確保範圍 0.5 ~ 0.98
        for (k in scores.keys) {
            scores[k] = (scores[k] ?: 0.8).coerceIn(0.5, 0.98)
        }

        val headline = "以【$starsStr】為本命元辰核心，兼具格局視野與踏實執行力的人生開拓者！"

        val coreCards = listOf(
            MetisCoreCard(
                title = "本命超能力天賦",
                tag = "核心靈魂",
                description = "你的命宮由 $starsStr 坐鎮，天生具備敏銳洞察力與獨立決策力，不甘隨波逐流，關鍵時刻能扛起重任。"
            ),
            MetisCoreCard(
                title = "事業與財富密碼",
                tag = "事業吸金",
                description = "官祿宮與財帛宮相互呼應，擅長在動態與創新中尋找獲利契機，建立穩定的專業壁壘是你的致勝法寶。"
            ),
            MetisCoreCard(
                title = "情感與相處指引",
                tag = "親密關係",
                description = "在感情中重視心靈共鳴與互相扶持，給予彼此適度空間，能讓親密關係如同美酒越陳越香。"
            )
        )

        val tenDimensions = listOf(
            MetisDimensionReading("事業前途發展", 92, "極佳", "職場自帶領導氣場，越是有挑戰性的舞台越能激發你的潛能。"),
            MetisDimensionReading("財富累積管道", 88, "上吉", "正財運穩健，具備多元進帳潛能，適合中長期穩健配置。"),
            MetisDimensionReading("人際貴人助力", 90, "豐厚", "長輩貴人運佳，樂於助人為你累積深厚人脈資本。"),
            MetisDimensionReading("感情婚姻默契", 85, "穩定", "伴侶能給予實質精神支持，互相體諒是最美良藥。"),
            MetisDimensionReading("身心元氣充電", 84, "良好", "定期親近大自然與規律作息，能快速恢復精氣神。"),
            MetisDimensionReading("家庭房產基石", 89, "安穩", "對家有極大責任感，資產配置適合以不動產或穩健儲蓄為主。"),
            MetisDimensionReading("靈感創意爆發", 87, "豐富", "常有出奇制勝的巧思，適合將點子落地為具體成果。"),
            MetisDimensionReading("遠行出差機運", 86, "亨通", "出外吉星照應，異地發展或跨領域拓展能打開新天地。"),
            MetisDimensionReading("生活情緒調適", 88, "從容", "懂得在忙碌中享受生活情趣，自癒能力強大。"),
            MetisDimensionReading("人生目標堅持", 93, "堅毅", "一旦認準方向便全力以赴，終能開創獨特格局。")
        )

        return MetisReading(
            dimensionScores = scores,
            oneSentenceHeadline = headline,
            threeCoreCards = coreCards,
            tenDimensions = tenDimensions
        )
    }
}
