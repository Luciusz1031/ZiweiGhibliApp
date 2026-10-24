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
                val p = chart.palace(lifeBranch)
                return synthesizeReading(
                    scope = TimelineScope.NATAL,
                    palace = p,
                    chart = chart,
                    focusText = "本命元辰（終身核心人格與潛能基石）",
                    timeLabel = "終身元辰"
                )
            }

            TimelineScope.DECADE -> {
                val safeIdx = decadeIndex.coerceIn(0, chart.palaces.size - 1)
                val p = chart.palaces[safeIdx]
                return synthesizeReading(
                    scope = TimelineScope.DECADE,
                    palace = p,
                    chart = chart,
                    focusText = "${p.decadeStartAge} - ${p.decadeEndAge} 歲 大限十年運勢主場",
                    timeLabel = "${p.decadeStartAge}-${p.decadeEndAge}歲大限"
                )
            }

            TimelineScope.ANNUAL -> {
                val yearBranchIdx = ((selectedYear - 4) % 12 + 12) % 12
                val annualBranch = EarthlyBranch.fromIndex(yearBranchIdx)
                val yearStemIdx = ((selectedYear - 4) % 10 + 10) % 10
                val annualStem = HeavenlyStem.fromIndex(yearStemIdx)
                val p = chart.palace(annualBranch)

                return synthesizeReading(
                    scope = TimelineScope.ANNUAL,
                    palace = p,
                    chart = chart,
                    focusText = "$selectedYear 歲次【${annualStem.stemName}${annualBranch.branchName}年】流年氣場",
                    timeLabel = "${selectedYear}年（${annualStem.stemName}${annualBranch.branchName}）"
                )
            }

            TimelineScope.MINOR -> {
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
                val cal = Calendar.getInstance()
                val currentYear = cal.get(Calendar.YEAR)
                cal.time = chart.birthDate
                val birthYear = cal.get(Calendar.YEAR)
                val nominalAge = maxOf(currentYear - birthYear + 1, 1)

                val minorIdx = (startBranch.index + (nominalAge - 1)) % 12
                val minorBranch = EarthlyBranch.fromIndex(minorIdx)
                val p = chart.palace(minorBranch)

                return synthesizeReading(
                    scope = TimelineScope.MINOR,
                    palace = p,
                    chart = chart,
                    focusText = "實歲 $nominalAge 歲 小限心境微氣候",
                    timeLabel = "${nominalAge}歲小限"
                )
            }

            TimelineScope.MONTHLY -> {
                val safeMonth = selectedMonth.coerceIn(1, 12)
                val currentYear = Calendar.getInstance().get(Calendar.YEAR)
                val yearBranchIdx = ((currentYear - 4) % 12 + 12) % 12
                val monthBranchIdx = (yearBranchIdx + (safeMonth - 1)) % 12
                val monthBranch = EarthlyBranch.fromIndex(monthBranchIdx)
                val p = chart.palace(monthBranch)
                val monthNames = arrayOf("", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月")
                val mName = monthNames[safeMonth]

                return synthesizeReading(
                    scope = TimelineScope.MONTHLY,
                    palace = p,
                    chart = chart,
                    focusText = "農曆 $mName 流月吉凶氣候",
                    timeLabel = "農曆$mName"
                )
            }

            TimelineScope.DAILY -> {
                val safeDay = selectedDay.coerceIn(1, 30)
                val dayBranchIdx = (safeDay - 1) % 12
                val dayBranch = EarthlyBranch.fromIndex(dayBranchIdx)
                val p = chart.palace(dayBranch)

                return synthesizeReading(
                    scope = TimelineScope.DAILY,
                    palace = p,
                    chart = chart,
                    focusText = "農曆 $safeDay 日 流日值日氣候",
                    timeLabel = "農曆${safeDay}日"
                )
            }
        }
    }

    private fun synthesizeReading(
        scope: TimelineScope,
        palace: PalaceData,
        chart: AstrolabeChart,
        focusText: String,
        timeLabel: String
    ): TimelineFortuneReading {

        val branch = palace.earthlyBranch
        val palaceType = palace.type
        val majorStars = palace.majorStars
        val luckyStars = palace.luckyStars
        val fierceStars = palace.fierceStars

        val majorNames = majorStars.map { it.name }
        val starsStr = majorStars.joinToString("、") {
            val b = it.brightness?.let { br -> "[${br.label}]" } ?: ""
            val tf = it.natalTransformation?.let { t -> " 化${t.label}" } ?: ""
            "${it.name}$b$tf"
        }

        val displayStars = if (starsStr.isEmpty()) "命無正曜 (借對宮星曜吉光照耀)" else starsStr

        val hasJi = palace.stars.any { it.natalTransformation == TransformationType.JI }
        val hasLu = palace.stars.any { it.natalTransformation == TransformationType.LU }
        val hasQuan = palace.stars.any { it.natalTransformation == TransformationType.QUAN }
        val hasKe = palace.stars.any { it.natalTransformation == TransformationType.KE }

        // 1. 動態主標題
        val headline = buildHeadline(scope, timeLabel, palaceType, majorNames, hasLu, hasJi, hasQuan)

        // 2. 動態白話深度詳解
        val overview = buildOverview(scope, timeLabel, palace, displayStars, majorNames, hasLu, hasJi, hasQuan, hasKe)

        // 3. 機遇與利好
        val opportunities = buildOpportunities(palaceType, majorNames, luckyStars, hasLu, hasQuan)

        // 4. 暗礁與避坑
        val precautions = buildPrecautions(palaceType, majorNames, fierceStars, hasJi)

        // 5. 小鹿兒專屬溫馨指引
        val fawnAdvice = buildFawnAdvice(scope, palaceType, hasJi)

        val palaceTitle = "${scope.label}焦點：${palaceType.palaceName} (${branch.branchName}宮)"

        return TimelineFortuneReading(
            scope = scope,
            currentFocusText = focusText,
            targetPalace = palace,
            palaceName = palaceTitle,
            starsDisplay = displayStars,
            headline = headline,
            plainOverview = overview,
            opportunities = opportunities,
            precautions = precautions,
            fawnAdvice = fawnAdvice,
            highlightedBranch = branch
        )
    }

    private fun buildHeadline(
        scope: TimelineScope,
        timeLabel: String,
        palaceType: PalaceType,
        majorNames: List<String>,
        hasLu: Boolean,
        hasJi: Boolean,
        hasQuan: Boolean
    ): String {
        val starsKeyword = majorNames.take(2).joinToString("")
        val starTag = if (starsKeyword.isEmpty()) "星曜借照" else "【$starsKeyword】"

        if (hasLu) return "$starTag $timeLabel 逢化祿吉慶，${palaceType.palaceName}生機勃發收穫豐碩"
        if (hasQuan) return "$starTag $timeLabel 權柄在握，${palaceType.palaceName}雷厲風行拓局先鋒"
        if (hasJi) return "$starTag $timeLabel 修心蓄力期，${palaceType.palaceName}以穩為上防暗礁波折"

        return when (palaceType) {
            PalaceType.CAREER -> "$starTag $timeLabel 行至官祿主場：事業突破在即，才幹展露贏得信任"
            PalaceType.WEALTH -> "$starTag $timeLabel 聚焦財帛運轉：求財管道明朗，穩紮穩打積累基石"
            PalaceType.MARRIAGE -> "$starTag $timeLabel 緣牽夫妻情誼：以心印心相惜，共築溫暖情感港灣"
            PalaceType.TRAVEL -> "$starTag $timeLabel 出門吉星相照：異地開拓順遂，動態交流打開格局"
            PalaceType.PROPERTY -> "$starTag $timeLabel 安固田宅基業：聚財安家之時，居家溫馨福澤庇蔭"
            PalaceType.HEALTH -> "$starTag $timeLabel 調和身心元氣：順應四季節奏，養精蓄銳厚積薄發"
            PalaceType.FRIENDS -> "$starTag $timeLabel 人脈圈層流轉：良師益友相攜，貴人提攜共贏契機"
            PalaceType.HAPPINESS -> "$starTag $timeLabel 心靈福澤充盈：放寬心胸自洽，精神富足樂得自在"
            PalaceType.LIFE -> "$starTag $timeLabel 本命元辰閃耀：立足核心原則，開拓個人獨特天地"
            else -> "$starTag $timeLabel 臨${palaceType.palaceName}：順應星勢節奏，步步落實漸入佳境"
        }
    }

    private fun buildOverview(
        scope: TimelineScope,
        timeLabel: String,
        palace: PalaceData,
        displayStars: String,
        majorNames: List<String>,
        hasLu: Boolean,
        hasJi: Boolean,
        hasQuan: Boolean,
        hasKe: Boolean
    ): String {
        val pName = palace.type.palaceName
        val starsDesc = when {
            majorNames.contains("紫微") || majorNames.contains("天府") ->
                "貴星坐鎮，自帶沉穩格局與開拓擔當，易獲貴人賞識與同儕信賴。"
            majorNames.contains("武曲") || majorNames.contains("太陰") ->
                "財星照耀，注重實質成果與資源沉澱，善於在變局中捕捉務實商機。"
            majorNames.contains("天機") || majorNames.contains("巨門") ->
                "智慧與策劃星曜活躍，思維敏捷清晰，能靠優異的談判與方案規劃出奇制勝。"
            majorNames.contains("太陽") || majorNames.contains("天梁") ->
                "浩然正氣與庇蔭星臨門，樂於助人累積深厚福德，出外逢凶化吉。"
            majorNames.contains("七殺") || majorNames.contains("破軍") || majorNames.contains("貪狼") ->
                "殺破狼生機躍動，破除陳規舊習、主動求新求變，具有驚人的開拓爆發力。"
            else ->
                "星曜氣場平和，借對宮吉曜照拂，處事順遂圓融、彈性極大。"
        }

        var transDesc = ""
        if (hasLu) transDesc += " 本宮逢生年化祿，財祿與人緣如虎添翼，是全力推進目標的最佳時機！"
        if (hasQuan) transDesc += " 宮內坐鎮化權，主導權與執行力極強，宜把握競爭先機。"
        if (hasKe) transDesc += " 遇化科吉曜，文思泉湧、考運考績順遂，美名廣傳。"
        if (hasJi) transDesc += " 逢化忌干擾，提示此階段切勿心浮氣躁，重大決定宜三思而後行，穩健是第一要務。"

        return when (scope) {
            TimelineScope.NATAL ->
                "你的本命元辰由 $displayStars 鎮守，為一生的性格內核與天賦底層代碼。$starsDesc$transDesc 任何大限流年的起伏皆以本命格局為根基，只要認清自我長處並持續深耕，自能成就不凡人生！"
            TimelineScope.DECADE ->
                "在 $timeLabel 這關鍵十年中，時空核心聚焦於【$pName】所管轄的生命領域。此十年由 $displayStars 牽動，$starsDesc$transDesc 適合鎖定長期核心賽道，建立不可替代的專業護城河。"
            TimelineScope.ANNUAL ->
                "西曆 $timeLabel，你的流年命宮行至 ${palace.earthlyBranch.branchName} 宮，正好對應本命【$pName】。受 $displayStars 氣場所引領，$starsDesc$transDesc 整體年度節奏鮮明，務必抓住核心矛盾集中發力！"
            TimelineScope.MINOR ->
                "小限反映 $timeLabel 的個人內心心境、情緒起伏與健康微氣候。小限行至【$pName】，宮內見 $displayStars。$starsDesc$transDesc 宜多傾聽內在真實聲音，注重身心放鬆與情緒平衡。"
            TimelineScope.MONTHLY ->
                "農曆 $timeLabel 運勢行至 ${palace.earthlyBranch.branchName} 宮【$pName】。受 $displayStars 值月主導，$starsDesc$transDesc 本月節奏緊湊明快，適合把積累的待辦要務逐一落地執行。"
            TimelineScope.DAILY ->
                "今日流日氣場專注於【$pName】，由 $displayStars 值日守護。$starsDesc$transDesc 直覺與行動力在線，適合做出關鍵決策與落實今日核心任務！"
        }
    }

    private fun buildOpportunities(
        palaceType: PalaceType,
        majorNames: List<String>,
        luckyStars: List<StarItem>,
        hasLu: Boolean,
        hasQuan: Boolean
    ): List<String> {
        val list = mutableListOf<String>()

        when (palaceType) {
            PalaceType.CAREER -> {
                list.add("職場上有望承接核心業務或獲得晉升拔擢，發揮關鍵影響力。")
                list.add("專業技能備受同行或長官認可，能建立起無可替代的個人信譽。")
            }
            PalaceType.WEALTH -> {
                list.add("求財管道多元通達，適合推進穩健理財計畫或開啟副業獲利。")
                list.add("對市場價值具備敏銳嗅覺，能做出精準務實的財務決策。")
            }
            PalaceType.MARRIAGE -> {
                list.add("親密關係迎來深度溝通契機，能增進彼此默契與長遠安全感。")
                list.add("單身者容易在志趣相投的圈層中結識成熟且具包容力的優質良緣。")
            }
            PalaceType.TRAVEL -> {
                list.add("出外公差、遠行求學或跨領域探索運氣極佳，能拓寬眼界與格局。")
                list.add("異地貴人主動釋放善意，跨界合作容易談成重大共識。")
            }
            PalaceType.FRIENDS -> {
                list.add("能結識視野開闊的同頻夥伴，同儕互助協同效應顯著。")
                list.add("適合組織團隊或參與優質社群，人脈資源將轉化為實質助力。")
            }
            else -> {
                list.add("行事果決有條理，能迅速排除日常障礙並贏得身邊人的支持。")
                list.add("心態積極樂觀，面對突發狀況能隨機應變、化被動為主動。")
            }
        }

        if (hasLu || hasQuan) {
            list.add("自帶旺氣光環，關鍵時刻總有長輩或關鍵資源主動到位扶持。")
        }
        if (luckyStars.isNotEmpty()) {
            list.add("吉曜拱照，文書簽約、考試合格或重要認證皆能順利過關。")
        }

        return list.take(3)
    }

    private fun buildPrecautions(
        palaceType: PalaceType,
        majorNames: List<String>,
        fierceStars: List<StarItem>,
        hasJi: Boolean
    ): List<String> {
        val list = mutableListOf<String>()

        if (hasJi) {
            list.add("此階段切忌急躁冒進或跟風投資，重要條款與金錢往來務必白紙黑字。")
            list.add("溝通時保持心平氣和，切莫因口直心快而引發不必要的口舌誤會。")
        }

        if (fierceStars.isNotEmpty()) {
            val fierceNames = fierceStars.joinToString("、") { it.name }
            list.add("宮逢煞曜（$fierceNames），需防範突發急躁、情緒緊繃或交通行車安全。")
        }

        when (palaceType) {
            PalaceType.CAREER -> list.add("切莫事必躬親導致體力透支，適時授權更能維持高效領導力。")
            PalaceType.WEALTH -> list.add("嚴拒高槓桿賭徒心態與熟人借貸代墊，守住流動資金才是真正贏家。")
            PalaceType.MARRIAGE -> list.add("遇爭執多給彼此緩衝空間，切莫在盛怒之下做出過激承諾或決斷。")
            PalaceType.HEALTH -> list.add("注意規律作息與飲食均衡，及時抒解肩頸疲勞與精神壓力。")
            else -> if (list.isEmpty()) list.add("行事切忌三分鐘熱度，維持專注度方能收穫最甜美果實。")
        }

        return list.take(2)
    }

    private fun buildFawnAdvice(
        scope: TimelineScope,
        palaceType: PalaceType,
        hasJi: Boolean
    ): String {
        if (hasJi) {
            return "小鹿兒特別叮嚀：化忌是老天爺給予的沉澱修煉禮物！放慢腳步、深呼吸，不爭一時長短，熬過風雨便是繁花似錦！"
        }
        return when (scope) {
            TimelineScope.ANNUAL ->
                "小鹿兒流年錦囊：今年是開拓視野的幸運年份！多穿搭大地色與墨綠系，常帶微笑，身邊處處皆是你的開運貴人！"
            TimelineScope.MONTHLY ->
                "小鹿兒流月叮嚀：這個月行動力滿分！給自己泡一杯清香溫茶，踏實走好每一步，幸運就在前方等著你！"
            TimelineScope.DAILY ->
                "小鹿兒每日一句：今天是你創造美好記憶的一天，順心而行、善待自己，美好自會如約而至！"
            TimelineScope.DECADE ->
                "小鹿兒大限錦囊：人生十年一大變！選對方向、專注深耕，時間會給出最驚喜的答案！"
            else ->
                "小鹿兒心靈寄語：認同自己的獨特步伐，順應天時、知命造命，你永遠是自己生命中最棒的舵手！"
        }
    }
}
