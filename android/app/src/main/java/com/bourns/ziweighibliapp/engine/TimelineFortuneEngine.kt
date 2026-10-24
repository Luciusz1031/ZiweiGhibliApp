package com.bourns.ziweighibliapp.engine

import com.bourns.ziweighibliapp.models.*
import java.util.Calendar
import java.util.Date

enum class TimelineScope(val label: String) {
    NATAL("本命"),
    DECADE("大限"),
    ANNUAL("流年"),
    MINOR("小限"),
    MONTHLY("流月"),
    DAILY("流日")
}

data class TimelineFortuneReading(
    val scope: TimelineScope,
    val currentFocusText: String,
    val targetPalace: PalaceData,
    val palaceName: String,
    val starsDisplay: String,
    val headline: String,
    val plainOverview: String,
    val opportunities: List<String>,
    val precautions: List<String>,
    val fawnAdvice: String,
    val highlightedBranch: EarthlyBranch
)

object TimelineFortuneEngine {

    fun calculateReading(
        chart: AstrolabeChart,
        scope: TimelineScope,
        decadeIndex: Int = 0,
        selectedYear: Int = 2026,
        selectedMonth: Int = 1,
        selectedDay: Int = 1
    ): TimelineFortuneReading {

        when (scope) {
            TimelineScope.NATAL -> {
                val lifeBranch = chart.lifePalaceBranch
                val p = chart.palaces.firstOrNull { it.earthlyBranch == lifeBranch } ?: chart.palaces[0]
                val starsStr = p.majorStars.joinToString("、") {
                    val b = it.brightness?.label?.let { "[$it]" } ?: ""
                    "${it.name}$b"
                }
                val displayStars = if (starsStr.isEmpty()) "命無正曜 (借對宮吉星照耀)" else starsStr

                return TimelineFortuneReading(
                    scope = TimelineScope.NATAL,
                    currentFocusText = "本命元辰（終身核心能量軸）",
                    targetPalace = p,
                    palaceName = "本命宮 (${p.earthlyBranch.branchName}宮)",
                    starsDisplay = displayStars,
                    headline = "立足本心，終身格局之定海神針",
                    plainOverview = "本命盤是你一生的性格基石、天賦超能力與格局上限。你的本命由 $displayStars 鎮守，代表你天生具備獨立審視與開拓進取的勇氣。在人生長河中，無論外在運勢如何起伏，你的核心原則與處世格局都是你最厚實的底牌。只要發揮本質優勢，定能開創出屬於自己的天地！",
                    opportunities = listOf(
                        "天生自帶敏銳判斷力與獨立思維，不隨波逐流。",
                        "能將專業知識轉化為實質成就，中年後福澤深厚。",
                        "貴人運長久相隨，關鍵時刻總有長輩與朋友相助。"
                    ),
                    precautions = listOf(
                        "求好心切時容易給自己過大壓力，需保持身心平衡。",
                        "面對不同意見多點傾聽與包容，溝通更能事半功倍。"
                    ),
                    fawnAdvice = "小鹿兒溫馨提醒：認同自己的獨特節奏，不急不躁、順心而行，你比想像中更有力量！",
                    highlightedBranch = lifeBranch
                )
            }

            TimelineScope.DECADE -> {
                val safeIdx = decadeIndex.coerceIn(0, 11)
                val p = chart.palaces[safeIdx]
                val starsStr = p.majorStars.joinToString("、") {
                    val b = it.brightness?.label?.let { "[$it]" } ?: ""
                    "${it.name}$b"
                }
                val displayStars = if (starsStr.isEmpty()) "借對宮星曜吉光照臨" else starsStr

                return TimelineFortuneReading(
                    scope = TimelineScope.DECADE,
                    currentFocusText = "${p.decadeStartAge} - ${p.decadeEndAge} 歲 大限十年運勢走向",
                    targetPalace = p,
                    palaceName = "大限宮位：${p.type.palaceName} (${p.earthlyBranch.branchName}宮)",
                    starsDisplay = displayStars,
                    headline = "步入【${p.type.palaceName}】十年主場，關鍵成長與厚積薄發期",
                    plainOverview = "在 ${p.decadeStartAge} 至 ${p.decadeEndAge} 歲這黃金十年中，你的運勢焦點全神貫注於【${p.type.palaceName}】所管轄的人生領域。宮內由 $displayStars 主導，氣場生機蓬勃。這十年是深耕專業、建立不可替代地位的重要轉折點，適合鎖定長期目標紮實前行。",
                    opportunities = listOf(
                        "此大限內事業與人脈資源聚集，能迎來發光發熱的重要舞台。",
                        "個人決策力大幅提升，能獨立承擔重任並贏得信任。",
                        "財庫基石逐漸穩固，適合進行長線穩健的資產規劃。"
                    ),
                    precautions = listOf(
                        "避免頻繁更換賽道，專注於核心優勢方能結出豐碩果實。",
                        "合約文書與重要合作需字斟句酌，切忌口頭承諾。"
                    ),
                    fawnAdvice = "小鹿兒大限錦囊：十年磨一劍！只要認準正確方向並持之以恆，時間會給出最美好的回報！",
                    highlightedBranch = p.earthlyBranch
                )
            }

            TimelineScope.ANNUAL -> {
                val yearBranchIdx = ((selectedYear - 4) % 12 + 12) % 12
                val annualBranch = EarthlyBranch.fromIndex(yearBranchIdx)
                val yearStemIdx = ((selectedYear - 4) % 10 + 10) % 10
                val annualStem = HeavenlyStem.fromIndex(yearStemIdx)

                val p = chart.palaces.firstOrNull { it.earthlyBranch == annualBranch } ?: chart.palaces[0]
                val starsStr = p.majorStars.joinToString("、") {
                    val b = it.brightness?.label?.let { "[$it]" } ?: ""
                    "${it.name}$b"
                }
                val displayStars = if (starsStr.isEmpty()) "星曜和順 (對宮星曜借照)" else starsStr

                return TimelineFortuneReading(
                    scope = TimelineScope.ANNUAL,
                    currentFocusText = "${selectedYear} 歲次【${annualStem.stemName}${annualBranch.branchName}年】流年氣場",
                    targetPalace = p,
                    palaceName = "流年命宮臨【${annualBranch.branchName}宮】(本命${p.type.palaceName})",
                    starsDisplay = displayStars,
                    headline = "${selectedYear} 流年迎來創新變局，乘風破浪展宏圖",
                    plainOverview = "西曆 $selectedYear 年（歲次${annualStem.stemName}${annualBranch.branchName}），你的流年命宮行至 ${annualBranch.branchName} 宮，受 $displayStars 的牽引。今年外在機會頻繁浮現，動態交流與跨界合作明顯增多，是走出舒適圈、開拓新格局的關鍵一年！",
                    opportunities = listOf(
                        "職場上有望接手新專案或被賦予更多主導權限，才華得以展現。",
                        "出外遠行或跨領域交流能結識志同道合的新朋友與貴人。",
                        "進財管道呈現多元化趨勢，利於發展個人第二專長。"
                    ),
                    precautions = listOf(
                        "行事切忌急功近利，重大投資決策前宜多方驗證數據。",
                        "注意調節作息與放鬆神經，避免熬夜勞累影響元氣。"
                    ),
                    fawnAdvice = "小鹿兒流年叮嚀：今年出門在外貴人特別多，多微笑、多主動打招呼，好運自然常伴左右！",
                    highlightedBranch = annualBranch
                )
            }

            TimelineScope.MINOR -> {
                val cal = Calendar.getInstance()
                val currentYear = cal.get(Calendar.YEAR)
                cal.time = chart.birthDate
                val birthYear = cal.get(Calendar.YEAR)
                val nominalAge = maxOf(currentYear - birthYear + 1, 1)

                val startBranchMap = mapOf(
                    EarthlyBranch.YIN to EarthlyBranch.CHEN,
                    EarthlyBranch.WU to EarthlyBranch.CHEN,
                    EarthlyBranch.XU to EarthlyBranch.CHEN,
                    EarthlyBranch.SHEN to EarthlyBranch.XU,
                    EarthlyBranch.ZI to EarthlyBranch.XU,
                    EarthlyBranch.CHEN to EarthlyBranch.XU,
                    EarthlyBranch.SI to EarthlyBranch.WEI,
                    EarthlyBranch.YOU to EarthlyBranch.WEI,
                    EarthlyBranch.CHOU to EarthlyBranch.WEI,
                    EarthlyBranch.HAI to EarthlyBranch.CHOU,
                    EarthlyBranch.MAO to EarthlyBranch.CHOU,
                    EarthlyBranch.WEI to EarthlyBranch.CHOU
                )
                val startBranch = startBranchMap[chart.lunarInfo.yearBranch] ?: EarthlyBranch.CHEN
                val minorIdx = (startBranch.index + (nominalAge - 1)) % 12
                val minorBranch = EarthlyBranch.fromIndex(minorIdx)
                val p = chart.palaces.firstOrNull { it.earthlyBranch == minorBranch } ?: chart.palaces[0]

                return TimelineFortuneReading(
                    scope = TimelineScope.MINOR,
                    currentFocusText = "實歲 $nominalAge 歲 小限心境微氣候",
                    targetPalace = p,
                    palaceName = "小限宮位：${minorBranch.branchName}宮 (本命${p.type.palaceName})",
                    starsDisplay = p.majorStars.joinToString("、") { it.name }.ifEmpty { "借宮和順" },
                    headline = "當前年歲聚焦內心調適與步調梳理",
                    plainOverview = "小限反映你當前歲數的主觀心境感受、健康元氣與日常情緒。小限入【${minorBranch.branchName}宮】，提示你這一年在追求目標的同時，更要關注內心的安寧與真實需求，找到生活與奮鬥的甜蜜平衡點。",
                    opportunities = listOf(
                        "靈感豐富，適合閱讀、進修或培養一門療癒身心的興趣。",
                        "家庭親友關係溫馨和睦，能為你提供堅實的情感避風港。"
                    ),
                    precautions = listOf(
                        "偶有胡思亂想或精神疲勞，及時運動放空能迅速排解。",
                        "瑣碎雜事勿往心裡去，放寬心胸自得其樂。"
                    ),
                    fawnAdvice = "小鹿兒小限錦囊：每天給自己喝一杯溫熱花草茶的時光，溫暖自己，生活便處處美好！",
                    highlightedBranch = minorBranch
                )
            }

            TimelineScope.MONTHLY -> {
                val safeMonth = selectedMonth.coerceIn(1, 12)
                val currentYear = Calendar.getInstance().get(Calendar.YEAR)
                val yearBranchIdx = ((currentYear - 4) % 12 + 12) % 12
                val monthBranchIdx = (yearBranchIdx + (safeMonth - 1)) % 12
                val monthBranch = EarthlyBranch.fromIndex(monthBranchIdx)
                val p = chart.palaces.firstOrNull { it.earthlyBranch == monthBranch } ?: chart.palaces[0]
                val monthNames = arrayOf("", "正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二")
                val mName = monthNames[safeMonth]

                return TimelineFortuneReading(
                    scope = TimelineScope.MONTHLY,
                    currentFocusText = "農曆 $mName 月 流月吉凶氣候",
                    targetPalace = p,
                    palaceName = "流月宮位：${monthBranch.branchName}宮 (本命${p.type.palaceName})",
                    starsDisplay = p.majorStars.joinToString("、") { it.name }.ifEmpty { "吉星拱照" },
                    headline = "農曆 $mName 月：節奏明快，步步落實",
                    plainOverview = "農曆 $mName 月運勢行至 ${monthBranch.branchName} 宮。本月你的生活與工作節奏相對俐落，適合將積壓已久的待辦清單一件件踏實清理，執行效率非常高！",
                    opportunities = listOf(
                        "本月談判溝通順利，能促成共識與關鍵合作方案落地。",
                        "生活中有小確幸偏財進帳或收到親友贈送的暖心禮物。"
                    ),
                    precautions = listOf(
                        "忙碌中別忘了按時吃飯，保持充足水分與規律休息。"
                    ),
                    fawnAdvice = "小鹿兒流月叮嚀：這個月是耕耘收穫期，保持開朗心情，幸運女神就在身邊！",
                    highlightedBranch = monthBranch
                )
            }

            TimelineScope.DAILY -> {
                val safeDay = selectedDay.coerceIn(1, 30)
                val dayBranchIdx = (safeDay - 1) % 12
                val dayBranch = EarthlyBranch.fromIndex(dayBranchIdx)
                val p = chart.palaces.firstOrNull { it.earthlyBranch == dayBranch } ?: chart.palaces[0]

                return TimelineFortuneReading(
                    scope = TimelineScope.DAILY,
                    currentFocusText = "當日流日吉凶氣象（農曆 $safeDay 日）",
                    targetPalace = p,
                    palaceName = "流日值日：${dayBranch.branchName}宮 (本命${p.type.palaceName})",
                    starsDisplay = p.majorStars.joinToString("、") { it.name }.ifEmpty { "祥和順暢" },
                    headline = "今日氣象和潤，宜決斷關鍵要務",
                    plainOverview = "今日流日氣場專注於【${p.type.palaceName}】，直覺靈感與執行力處於極佳狀態。適合安排重要會議、簽署合約或與關鍵夥伴交流，容易取得令人欣喜的進展！",
                    opportunities = listOf(
                        "思維敏銳，能迅速找到複雜難題的突破捷徑。",
                        "與人為善收穫滿滿正面回饋，人氣指數持續上升。"
                    ),
                    precautions = listOf(
                        "今日切忌拖延，想到就做能避免錯過良機。"
                    ),
                    fawnAdvice = "小鹿兒每日一句：今天是你創造美好記憶的一天，帶著微笑出發吧！",
                    highlightedBranch = dayBranch
                )
            }
        }
    }
}
