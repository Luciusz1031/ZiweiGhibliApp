package com.bourns.ziweighibliapp.engine

import com.bourns.ziweighibliapp.models.*
import java.util.Calendar
import java.util.Date

object ZiweiEngine {

    fun generateChart(
        birthDate: Date,
        gender: Gender,
        userName: String = "命主",
        isUnknownHour: Boolean = false
    ): AstrolabeChart {
        val cal = Calendar.getInstance().apply { time = birthDate }
        val effectiveDate = if (isUnknownHour) {
            cal.set(Calendar.HOUR_OF_DAY, 0)
            cal.set(Calendar.MINUTE, 30)
            cal.set(Calendar.SECOND, 0)
            cal.time
        } else {
            birthDate
        }

        val hourBranch = if (isUnknownHour) {
            EarthlyBranch.ZI
        } else {
            val hour = cal.get(Calendar.HOUR_OF_DAY)
            when (hour) {
                23, 0 -> EarthlyBranch.ZI
                1, 2 -> EarthlyBranch.CHOU
                3, 4 -> EarthlyBranch.YIN
                5, 6 -> EarthlyBranch.MAO
                7, 8 -> EarthlyBranch.CHEN
                9, 10 -> EarthlyBranch.SI
                11, 12 -> EarthlyBranch.WU
                13, 14 -> EarthlyBranch.WEI
                15, 16 -> EarthlyBranch.SHEN
                17, 18 -> EarthlyBranch.YOU
                19, 20 -> EarthlyBranch.XU
                else -> EarthlyBranch.HAI
            }
        }

        val lunarInfo = ChineseCalendarHelper.getLunarDateInfo(effectiveDate, hourBranch)
        val effectiveMonth = lunarInfo.lunarMonth

        // 4. 定命宮與身宮 (寅宮(2)起正月順數至生月，再逆數至生時為命宮；順數至生時為身宮)
        val monthBranchIndex = (EarthlyBranch.YIN.index + effectiveMonth - 1) % 12
        val lifeBranchIndex = (monthBranchIndex - hourBranch.index + 12) % 12
        val bodyBranchIndex = (monthBranchIndex + hourBranch.index) % 12

        val lifePalaceBranch = EarthlyBranch.fromIndex(lifeBranchIndex)
        val bodyPalaceBranch = EarthlyBranch.fromIndex(bodyBranchIndex)

        // 5. 安十二宮天干 (五虎遁月法)
        val branchStems = calculatePalaceStems(lunarInfo.yearStem)
        val lifePalaceStem = branchStems[lifeBranchIndex]

        // 6. 定五行局
        val elementBureau = calculateElementBureau(lifePalaceStem, lifePalaceBranch)

        // 7. 安十二宮宮名
        val palaces = mutableListOf<PalaceData>()
        for (branch in EarthlyBranch.values()) {
            val offset = (lifeBranchIndex - branch.index + 12) % 12
            val palaceType = PalaceType.fromIndex(offset)
            val stem = branchStems[branch.index]

            palaces.add(
                PalaceData(
                    earthlyBranch = branch,
                    heavenlyStem = stem,
                    type = palaceType,
                    isLifePalace = (branch == lifePalaceBranch),
                    isBodyPalace = (branch == bodyPalaceBranch)
                )
            )
        }

        // 8. 起大限歲數 (陽男陰女順行，陰男陽女逆行)
        val isYangYear = lunarInfo.yearStem.isYang
        val isClockwise = (isYangYear && gender.isMale) || (!isYangYear && !gender.isMale)
        val bureauNum = elementBureau.number

        for (i in 0 until 12) {
            val step = if (isClockwise) i else (12 - i) % 12
            val targetBranchIndex = (lifeBranchIndex + step) % 12
            val startAge = bureauNum + (i * 10)
            val endAge = startAge + 9

            palaces[targetBranchIndex].decadeStartAge = startAge
            palaces[targetBranchIndex].decadeEndAge = endAge
        }

        // 9. 安十四主星
        val ziweiBranch = calculateZiweiBranch(lunarInfo.lunarDay, elementBureau)
        val tianfuBranch = calculateTianfuBranch(ziweiBranch)

        val starsMap = mutableMapOf<Int, MutableList<StarItem>>()
        for (i in 0 until 12) { starsMap[i] = mutableListOf() }

        val ziweiStars = listOf(
            Triple("紫微", 0, "土"),
            Triple("天機", -1, "木"),
            Triple("太陽", -3, "火"),
            Triple("武曲", -4, "金"),
            Triple("天同", -5, "水"),
            Triple("廉貞", -8, "火")
        )
        for (star in ziweiStars) {
            val bIndex = (ziweiBranch.index + star.second + 24) % 12
            val b = getStarBrightness(star.first, EarthlyBranch.fromIndex(bIndex))
            starsMap[bIndex]?.add(StarItem(star.first, StarCategory.MAJOR, b, element = star.third))
        }

        val tianfuStars = listOf(
            Triple("天府", 0, "土"),
            Triple("太陰", 1, "水"),
            Triple("貪狼", 2, "木"),
            Triple("巨門", 3, "水"),
            Triple("天相", 4, "水"),
            Triple("天梁", 5, "土"),
            Triple("七殺", 6, "金"),
            Triple("破軍", 10, "水")
        )
        for (star in tianfuStars) {
            val bIndex = (tianfuBranch.index + star.second) % 12
            val b = getStarBrightness(star.first, EarthlyBranch.fromIndex(bIndex))
            starsMap[bIndex]?.add(StarItem(star.first, StarCategory.MAJOR, b, element = star.third))
        }

        // 10. 安六吉六煞與輔曜
        val zuoFuIndex = (EarthlyBranch.CHEN.index + (effectiveMonth - 1)) % 12
        val youBiIndex = (EarthlyBranch.XU.index - (effectiveMonth - 1) + 12) % 12
        starsMap[zuoFuIndex]?.add(StarItem("左輔", StarCategory.LUCKY, element = "土"))
        starsMap[youBiIndex]?.add(StarItem("右弼", StarCategory.LUCKY, element = "水"))

        val wenChangIndex = (EarthlyBranch.SI.index - hourBranch.index + 12) % 12
        val wenQuIndex = (EarthlyBranch.CHEN.index + hourBranch.index) % 12
        starsMap[wenChangIndex]?.add(StarItem("文昌", StarCategory.LUCKY, element = "金"))
        starsMap[wenQuIndex]?.add(StarItem("文曲", StarCategory.LUCKY, element = "水"))

        val (kuiIndex, yueIndex) = calculateKuiYue(lunarInfo.yearStem)
        starsMap[kuiIndex]?.add(StarItem("天魁", StarCategory.LUCKY, element = "火"))
        starsMap[yueIndex]?.add(StarItem("天鉞", StarCategory.LUCKY, element = "火"))

        val luCunIndex = calculateLuCun(lunarInfo.yearStem)
        val qingYangIndex = (luCunIndex + 1) % 12
        val tuoLuoIndex = (luCunIndex - 1 + 12) % 12
        starsMap[luCunIndex]?.add(StarItem("祿存", StarCategory.AUXILIARY, element = "土"))
        starsMap[qingYangIndex]?.add(StarItem("擎羊", StarCategory.FIERCE, element = "金"))
        starsMap[tuoLuoIndex]?.add(StarItem("陀羅", StarCategory.FIERCE, element = "金"))

        val diJieIndex = (EarthlyBranch.HAI.index + hourBranch.index) % 12
        val diKongIndex = (EarthlyBranch.HAI.index - hourBranch.index + 12) % 12
        starsMap[diKongIndex]?.add(StarItem("地空", StarCategory.FIERCE, element = "火"))
        starsMap[diJieIndex]?.add(StarItem("地劫", StarCategory.FIERCE, element = "火"))

        val tianMaIndex = calculateTianMa(lunarInfo.yearBranch)
        starsMap[tianMaIndex]?.add(StarItem("天馬", StarCategory.AUXILIARY, element = "火"))

        // 11. 生年四化 (倪海廈天紀庚干日武陰同)
        val (luStar, quanStar, keStar, jiStar) = calculateFourTransformations(lunarInfo.yearStem)
        for (bIndex in 0 until 12) {
            val list = starsMap[bIndex] ?: continue
            for (star in list) {
                when (star.name) {
                    luStar -> star.natalTransformation = TransformationType.LU
                    quanStar -> star.natalTransformation = TransformationType.QUAN
                    keStar -> star.natalTransformation = TransformationType.KE
                    jiStar -> star.natalTransformation = TransformationType.JI
                }
            }
        }

        for (i in 0 until 12) {
            palaces[i].stars = starsMap[i] ?: emptyList()
        }

        val lifeMaster = calculateLifeMaster(lifePalaceBranch)
        val bodyMaster = calculateBodyMaster(lunarInfo.yearBranch)
        val patterns = TianjiPatternMatcher.matchPatterns(palaces, lifePalaceBranch)

        return AstrolabeChart(
            userName = userName,
            isUnknownHour = isUnknownHour,
            birthDate = birthDate,
            gender = gender,
            lunarInfo = lunarInfo,
            elementBureau = elementBureau,
            lifePalaceBranch = lifePalaceBranch,
            bodyPalaceBranch = bodyPalaceBranch,
            lifeMasterStar = lifeMaster,
            bodyMasterStar = bodyMaster,
            palaces = palaces,
            patterns = patterns
        )
    }

    private fun calculatePalaceStems(yearStem: HeavenlyStem): List<HeavenlyStem> {
        val startStem = when (yearStem) {
            HeavenlyStem.JIA, HeavenlyStem.JI -> HeavenlyStem.BING
            HeavenlyStem.YI, HeavenlyStem.GENG -> HeavenlyStem.WU
            HeavenlyStem.BING, HeavenlyStem.XIN -> HeavenlyStem.GENG
            HeavenlyStem.DING, HeavenlyStem.REN -> HeavenlyStem.REN
            HeavenlyStem.WU, HeavenlyStem.GUI -> HeavenlyStem.JIA
        }
        val stems = MutableList(12) { HeavenlyStem.JIA }
        for (i in 0 until 12) {
            val branchIndex = (EarthlyBranch.YIN.index + i) % 12
            val stemIndex = (startStem.index + i) % 10
            stems[branchIndex] = HeavenlyStem.fromIndex(stemIndex)
        }
        return stems
    }

    private fun calculateElementBureau(lifeStem: HeavenlyStem, lifeBranch: EarthlyBranch): ElementBureau {
        val stemNum = (lifeStem.index / 2) + 1
        val branchNum = when (lifeBranch) {
            EarthlyBranch.ZI, EarthlyBranch.CHOU, EarthlyBranch.WU, EarthlyBranch.WEI -> 1
            EarthlyBranch.YIN, EarthlyBranch.MAO, EarthlyBranch.SHEN, EarthlyBranch.YOU -> 2
            EarthlyBranch.CHEN, EarthlyBranch.SI, EarthlyBranch.XU, EarthlyBranch.HAI -> 3
        }
        var sum = stemNum + branchNum
        if (sum > 5) sum -= 5
        return when (sum) {
            1 -> ElementBureau.WOOD_3
            2 -> ElementBureau.METAL_4
            3 -> ElementBureau.WATER_2
            4 -> ElementBureau.FIRE_6
            else -> ElementBureau.EARTH_5
        }
    }

    private fun calculateZiweiBranch(lunarDay: Int, bureau: ElementBureau): EarthlyBranch {
        val x = bureau.number
        val remainder = lunarDay % x
        var q = lunarDay / x
        var k = 0
        if (remainder != 0) {
            k = x - remainder
            q = (lunarDay + k) / x
        }
        var targetIndex = (EarthlyBranch.YIN.index + q - 1) % 12
        targetIndex = if (k % 2 == 1) {
            (targetIndex - k + 12) % 12
        } else {
            (targetIndex + k) % 12
        }
        return EarthlyBranch.fromIndex(targetIndex)
    }

    private fun calculateTianfuBranch(ziweiBranch: EarthlyBranch): EarthlyBranch {
        val tianfuIndex = (EarthlyBranch.CHEN.index - ziweiBranch.index + 12) % 12
        return EarthlyBranch.fromIndex(tianfuIndex)
    }

    private fun calculateFourTransformations(yearStem: HeavenlyStem): List<String> {
        return when (yearStem) {
            HeavenlyStem.JIA -> listOf("廉貞", "破軍", "武曲", "太陽")
            HeavenlyStem.YI -> listOf("天機", "天梁", "紫微", "太陰")
            HeavenlyStem.BING -> listOf("天同", "天機", "文昌", "廉貞")
            HeavenlyStem.DING -> listOf("太陰", "天同", "天機", "巨門")
            HeavenlyStem.WU -> listOf("貪狼", "太陰", "右弼", "天機")
            HeavenlyStem.JI -> listOf("武曲", "貪狼", "天梁", "文曲")
            HeavenlyStem.GENG -> listOf("太陽", "武曲", "太陰", "天同") // 倪海廈天紀日武陰同
            HeavenlyStem.XIN -> listOf("巨門", "太陽", "文曲", "文昌")
            HeavenlyStem.REN -> listOf("天梁", "紫微", "左輔", "武曲")
            HeavenlyStem.GUI -> listOf("破軍", "巨門", "太陰", "貪狼")
        }
    }

    private fun calculateLuCun(yearStem: HeavenlyStem): Int = when (yearStem) {
        HeavenlyStem.JIA -> EarthlyBranch.YIN.index
        HeavenlyStem.YI -> EarthlyBranch.MAO.index
        HeavenlyStem.BING, HeavenlyStem.WU -> EarthlyBranch.SI.index
        HeavenlyStem.DING, HeavenlyStem.JI -> EarthlyBranch.WU.index
        HeavenlyStem.GENG -> EarthlyBranch.SHEN.index
        HeavenlyStem.XIN -> EarthlyBranch.YOU.index
        HeavenlyStem.REN -> EarthlyBranch.HAI.index
        HeavenlyStem.GUI -> EarthlyBranch.ZI.index
    }

    private fun calculateKuiYue(yearStem: HeavenlyStem): Pair<Int, Int> = when (yearStem) {
        HeavenlyStem.JIA, HeavenlyStem.WU, HeavenlyStem.GENG -> Pair(EarthlyBranch.CHOU.index, EarthlyBranch.WEI.index)
        HeavenlyStem.YI, HeavenlyStem.JI -> Pair(EarthlyBranch.ZI.index, EarthlyBranch.SHEN.index)
        HeavenlyStem.BING, HeavenlyStem.DING -> Pair(EarthlyBranch.HAI.index, EarthlyBranch.YOU.index)
        HeavenlyStem.XIN -> Pair(EarthlyBranch.WU.index, EarthlyBranch.YIN.index)
        HeavenlyStem.REN, HeavenlyStem.GUI -> Pair(EarthlyBranch.MAO.index, EarthlyBranch.SI.index)
    }

    private fun calculateTianMa(yearBranch: EarthlyBranch): Int = when (yearBranch) {
        EarthlyBranch.SHEN, EarthlyBranch.ZI, EarthlyBranch.CHEN -> EarthlyBranch.YIN.index
        EarthlyBranch.YIN, EarthlyBranch.WU, EarthlyBranch.XU -> EarthlyBranch.SHEN.index
        EarthlyBranch.SI, EarthlyBranch.YOU, EarthlyBranch.CHOU -> EarthlyBranch.HAI.index
        EarthlyBranch.HAI, EarthlyBranch.MAO, EarthlyBranch.WEI -> EarthlyBranch.SI.index
    }

    private fun calculateLifeMaster(lifeBranch: EarthlyBranch): String = when (lifeBranch) {
        EarthlyBranch.ZI -> "貪狼"
        EarthlyBranch.CHOU, EarthlyBranch.HAI -> "巨門"
        EarthlyBranch.YIN, EarthlyBranch.XU -> "祿存"
        EarthlyBranch.MAO, EarthlyBranch.YOU -> "文曲"
        EarthlyBranch.CHEN, EarthlyBranch.SHEN -> "廉貞"
        EarthlyBranch.SI, EarthlyBranch.WEI -> "武曲"
        EarthlyBranch.WU -> "破軍"
    }

    private fun calculateBodyMaster(yearBranch: EarthlyBranch): String = when (yearBranch) {
        EarthlyBranch.ZI, EarthlyBranch.WU -> "火星"
        EarthlyBranch.CHOU, EarthlyBranch.WEI -> "天相"
        EarthlyBranch.YIN, EarthlyBranch.SHEN -> "天梁"
        EarthlyBranch.MAO, EarthlyBranch.YOU -> "天同"
        EarthlyBranch.CHEN, EarthlyBranch.XU -> "文昌"
        EarthlyBranch.SI, EarthlyBranch.HAI -> "天機"
    }

    private fun getStarBrightness(starName: String, branch: EarthlyBranch): StarBrightness {
        val b = branch.index
        return when (starName) {
            "紫微" -> if (b == 6) StarBrightness.MIAO else if (b in listOf(3, 4, 5, 7, 8, 9)) StarBrightness.WANG else StarBrightness.LI
            "天機" -> if (b in listOf(4, 5)) StarBrightness.MIAO else if (b in listOf(0, 1, 2)) StarBrightness.WANG else StarBrightness.PING
            "太陽" -> if (b in 3..7) StarBrightness.MIAO else StarBrightness.TRAPPED
            "武曲" -> if (b in listOf(4, 10)) StarBrightness.MIAO else StarBrightness.WANG
            "天同" -> if (b in listOf(2, 3)) StarBrightness.MIAO else StarBrightness.PING
            "廉貞" -> if (b in listOf(2, 8)) StarBrightness.MIAO else StarBrightness.LI
            "天府" -> if (b in listOf(0, 6, 2, 8)) StarBrightness.MIAO else StarBrightness.WANG
            "太陰" -> if (b in listOf(9, 10, 11, 0)) StarBrightness.MIAO else StarBrightness.TRAPPED
            "貪狼" -> if (b in listOf(1, 7)) StarBrightness.MIAO else StarBrightness.WANG
            "巨門" -> if (b in listOf(3, 9)) StarBrightness.MIAO else StarBrightness.WANG
            "天相" -> if (b in listOf(2, 8)) StarBrightness.MIAO else StarBrightness.WANG
            "天梁" -> if (b in listOf(6, 2)) StarBrightness.MIAO else StarBrightness.WANG
            "七殺" -> if (b in listOf(2, 8, 0, 6)) StarBrightness.MIAO else StarBrightness.WANG
            "破軍" -> if (b in listOf(0, 6)) StarBrightness.MIAO else StarBrightness.WANG
            else -> StarBrightness.PING
        }
    }
}
