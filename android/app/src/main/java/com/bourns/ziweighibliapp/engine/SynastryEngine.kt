package com.bourns.ziweighibliapp.engine

import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.models.PalaceType

data class SynastryReport(
    val personAName: String,
    val personBName: String,
    val overallScore: Int,
    val chemistryHeadline: String,
    val deerAdvice: String,
    val radarScores: Map<String, Double>,
    val strengths: List<String>,
    val challenges: List<String>
)

object SynastryEngine {

    fun analyze(chartA: AstrolabeChart, chartB: AstrolabeChart): SynastryReport {
        val nameA = if (chartA.userName.isBlank()) "命主" else chartA.userName
        val nameB = if (chartB.userName.isBlank()) "伴侶" else chartB.userName

        val lifePalaceA = chartA.palaces.firstOrNull { it.isLifePalace } ?: chartA.palaces[0]
        val lifePalaceB = chartB.palaces.firstOrNull { it.isLifePalace } ?: chartB.palaces[0]

        val starsA = lifePalaceA.majorStars.map { it.name }.joinToString("・").ifEmpty { "命星入座" }
        val starsB = lifePalaceB.majorStars.map { it.name }.joinToString("・").ifEmpty { "星宿守照" }

        val scores = mapOf(
            "性格契合" to 0.88,
            "價值觀念" to 0.85,
            "溝通共鳴" to 0.90,
            "生活默契" to 0.82,
            "互相成長" to 0.92
        )

        val overallScore = 88
        val headline = "【$nameA ($starsA)】與【$nameB ($starsB)】：彼此互補扶持、同心開創的溫馨吉配！"
        val deerAdvice = "小鹿兒合盤建議：你們一個重行動、一個善思考，相處時多分享每日生活趣事、共同制定旅行計畫，感情生活會充滿如吉卜力森林般的純粹與美好！"

        val strengths = listOf(
            "雙方命宮星宿相互呼應，遇事能共同商量，不易產生偏執衝突。",
            "金錢理財觀念契合，懂得互相尊重對方的開銷與儲蓄習慣。",
            "在事業上能成為彼此最堅強的精神後盾，給予彼此滿滿的安全感。"
        )

        val challenges = listOf(
            "工作繁忙時容易各自埋頭苦幹，記得每週安排一次專屬約會時光。",
            "遇到不同意見時，先聽完對方的感受再表達觀點，能化解許多不必要的誤會。"
        )

        return SynastryReport(
            personAName = nameA,
            personBName = nameB,
            overallScore = overallScore,
            chemistryHeadline = headline,
            deerAdvice = deerAdvice,
            radarScores = scores,
            strengths = strengths,
            challenges = challenges
        )
    }
}
