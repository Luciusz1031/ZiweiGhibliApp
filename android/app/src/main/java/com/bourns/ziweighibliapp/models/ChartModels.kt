package com.bourns.ziweighibliapp.models

import java.util.Date

data class StarItem(
    val name: String,
    val category: StarCategory,
    val brightness: StarBrightness? = null,
    var natalTransformation: TransformationType? = null,
    val element: String = ""
)

data class PalaceData(
    val earthlyBranch: EarthlyBranch,
    val heavenlyStem: HeavenlyStem,
    val type: PalaceType,
    val isLifePalace: Boolean = false,
    val isBodyPalace: Boolean = false,
    var stars: List<StarItem> = emptyList(),
    var decadeStartAge: Int = 0,
    var decadeEndAge: Int = 0
) {
    val majorStars: List<StarItem> get() = stars.filter { it.category == StarCategory.MAJOR }
    val luckyStars: List<StarItem> get() = stars.filter { it.category == StarCategory.LUCKY }
    val fierceStars: List<StarItem> get() = stars.filter { it.category == StarCategory.FIERCE }
}

data class TianjiPattern(
    val name: String,
    val isAuspicious: Boolean,
    val description: String,
    val tianjiComment: String
)

data class LunarDateInfo(
    val lunarYear: Int,
    val lunarMonth: Int,
    val lunarDay: Int,
    val isLeapMonth: Boolean,
    val yearStem: HeavenlyStem,
    val yearBranch: EarthlyBranch,
    val monthStem: HeavenlyStem,
    val monthBranch: EarthlyBranch,
    val dayStem: HeavenlyStem,
    val dayBranch: EarthlyBranch,
    val hourStem: HeavenlyStem,
    val hourBranch: EarthlyBranch
) {
    val lunarDateString: String
        get() {
            val leapStr = if (isLeapMonth) "閏" else ""
            val monthNames = arrayOf("", "正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "臘")
            val dayNames = arrayOf(
                "", "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
            )
            val m = if (lunarMonth in 1..12) monthNames[lunarMonth] else "$lunarMonth"
            val d = if (lunarDay in 1..30) dayNames[lunarDay] else "$lunarDay"
            return "農曆 ${yearStem.stemName}${yearBranch.branchName}年 $leapStr${m}月${d}日 ${hourStem.stemName}${hourBranch.branchName}時"
        }

    val baZiString: String
        get() = "${yearStem.stemName}${yearBranch.branchName}年  ${monthStem.stemName}${monthBranch.branchName}月  ${dayStem.stemName}${dayBranch.branchName}日  ${hourStem.stemName}${hourBranch.branchName}時"
}

data class AstrolabeChart(
    val userName: String = "命主",
    val isUnknownHour: Boolean = false,
    val birthDate: Date,
    val gender: Gender,
    val lunarInfo: LunarDateInfo,
    val elementBureau: ElementBureau,
    val lifePalaceBranch: EarthlyBranch,
    val bodyPalaceBranch: EarthlyBranch,
    val lifeMasterStar: String,
    val bodyMasterStar: String,
    val palaces: List<PalaceData>,
    val patterns: List<TianjiPattern>
)
