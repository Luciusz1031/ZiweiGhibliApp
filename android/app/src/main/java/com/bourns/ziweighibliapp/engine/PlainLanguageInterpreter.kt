package com.bourns.ziweighibliapp.engine

import com.bourns.ziweighibliapp.models.*

data class PlainPalaceInterpretation(
    val lifeTheme: String,
    val summary: String,
    val starHighlights: List<String>,
    val transformationAdvice: String?,
    val fawnAdvice: String,
    val strengthTag: String
)

object PlainLanguageInterpreter {

    fun interpret(palace: PalaceData, chart: AstrolabeChart): PlainPalaceInterpretation {
        val majorNames = palace.majorStars.map { it.name }
        val theme = getPalacePlainTheme(palace.type)
        val highlights = majorNames.map { getStarPlainPersona(it) }
        val summary = generatePlainSummary(palace.type, majorNames)
        val transformationAdvice = generateTransformationPlainNote(palace.stars)
        val hasJi = palace.stars.any { it.natalTransformation == TransformationType.JI }
        val fawnAdvice = generateFawnAdvice(palace.type, majorNames, hasJi)
        val strengthTag = getPalaceStrengthTag(palace.type, majorNames)

        return PlainPalaceInterpretation(
            lifeTheme = theme,
            summary = summary,
            starHighlights = highlights,
            transformationAdvice = transformationAdvice,
            fawnAdvice = fawnAdvice,
            strengthTag = strengthTag
        )
    }

    fun getPalacePlainTheme(type: PalaceType): String = when (type) {
        PalaceType.LIFE -> "我的天賦個性與本質超能力"
        PalaceType.SIBLINGS -> "我的手足相處與閨蜜好友圈"
        PalaceType.MARRIAGE -> "我的理想伴侶特徵與戀愛相處心法"
        PalaceType.CHILDREN -> "我的晚輩緣分與生活創意靈感"
        PalaceType.WEALTH -> "我的財富雷達與吸金賺錢管道"
        PalaceType.HEALTH -> "我的身體元氣與生活減壓指南"
        PalaceType.TRAVEL -> "我出門在外、遠行出差的機運氣場"
        PalaceType.FRIENDS -> "我的職場人脈與同儕社交圈"
        PalaceType.CAREER -> "最能讓我發光發熱的事業發展舞台"
        PalaceType.PROPERTY -> "我的家庭安全感與資產理財根基"
        PalaceType.HAPPINESS -> "讓我內心真正感到放鬆與幸福的充電方式"
        PalaceType.PARENTS -> "我的長輩貴人運與父母家庭緣分"
    }

    fun getStarPlainPersona(starName: String): String = when (starName) {
        "紫微" -> "【紫微星】自帶氣場的領袖風範，自尊心強、格局開闊，天生適合引領團隊。"
        "天機" -> "【天機星】靈活敏銳的智多星軍師，思路清晰、學習力強，點子總是比別人快一步。"
        "太陽" -> "【太陽星】熱情溫暖的光芒發射體，為人慷慨大方、富正義感，樂於照耀身邊所有人。"
        "武曲" -> "【武曲星】雷厲風行的實幹派掌門，說話耿直、行動力極強，對金錢與效率有敏銳嗅覺。"
        "天同" -> "【天同星】福氣滿滿的生活美學家，親和力強、愛好和平，懂得在日常細節中享受美好。"
        "廉貞" -> "【廉貞星】公關手腕高超的策略家，目標明確、敢愛敢恨，自帶強烈自信與個人風格。"
        "天府" -> "【天府星】穩健大度的大掌櫃，擅長守財理財、處事圓融包容，生活講究品質與品味。"
        "太陰" -> "【太陰星】細膩溫柔的療癒系精靈，感知力強、富同理心，有出色的美感與耐心。"
        "貪狼" -> "【貪狼星】多才多藝的人氣社交王，好奇心旺盛、幽默風趣，對新鮮事物永遠充滿熱情。"
        "巨門" -> "【巨門星】觀察力犀利的說服大師，思慮縝密、直覺準確，能靠邏輯與語言贏得眾人信服。"
        "天相" -> "【天相星】優雅得體的金牌秘書長，富有正義感、品味極高，是身邊親友最信任的智囊。"
        "天梁" -> "【天梁星】沉穩罩得住的靠山老大哥，自帶長輩風範、樂於助人，常能在關鍵時刻化險為夷。"
        "七殺" -> "【七殺星】敢拼敢衝的開拓先鋒，獨立果決、不怕困難，在競爭挑戰中往往越挫越勇。"
        "破軍" -> "【破軍星】敢破敢立的創意改革者，不喜墨守成規、敢於冒險創新，擁有驚人的爆發力。"
        else -> "【${starName}】輔助星曜，能為宮位增添獨特個人魅力與機會。"
    }

    private fun generatePlainSummary(type: PalaceType, majorNames: List<String>): String {
        if (majorNames.isEmpty()) {
            return "此宮位借對宮星曜照耀，代表這方面發展彈性極大，適應力強，懂得借力使力！"
        }
        val starsStr = majorNames.joinToString("與")
        return when (type) {
            PalaceType.LIFE -> "你的本命是由 $starsStr 掌舵，展現出獨具一格的個人魅力與處世格局！"
            PalaceType.MARRIAGE -> "你的感情世界由 $starsStr 守護，理想伴侶多具備這類特質，相處講求互相尊重與心靈共鳴。"
            PalaceType.WEALTH -> "你的求財管道受 $starsStr 影響，適合發揮自身優勢獲取正財與持續累積。"
            PalaceType.CAREER -> "你在工作事業上展現 $starsStr 的風采，越能發揮這份特質，越容易被重用與看見！"
            else -> "在 ${type.palaceName} 方面呈現 $starsStr 的鮮明特質，順著特質發展就能游刃有餘。"
        }
    }

    private fun generateTransformationPlainNote(stars: List<StarItem>): String? {
        val notes = mutableListOf<String>()
        for (s in stars) {
            when (s.natalTransformation) {
                TransformationType.LU -> notes.add("✨【${s.name}化祿】：自帶福運與豐饒能量，這方面容易順風順水、心想事成！")
                TransformationType.QUAN -> notes.add("⚡【${s.name}化權】：具備主導權與強烈企圖心，展現能力時能擔當大局！")
                TransformationType.KE -> notes.add("🌸【${s.name}化科】：名聲口碑極佳，自帶文雅氣質與貴人庇佑。")
                TransformationType.JI -> notes.add("🌱【${s.name}化忌】：此處是你今生的修煉場，放慢腳步、多點耐心就能轉化為深厚智慧！")
                null -> {}
            }
        }
        return if (notes.isNotEmpty()) notes.joinToString("\n") else null
    }

    private fun generateFawnAdvice(type: PalaceType, majorNames: List<String>, hasJi: Boolean): String {
        if (hasJi) {
            return "小鹿兒抱抱：這宮位帶有「化忌」，代表你對這方面特別在意～請記得放寬心，凡事七分力、留三分給自己喘息，轉念即是福氣！"
        }
        return when (type) {
            PalaceType.LIFE -> "小鹿兒提醒：每天留給自己 15 分鐘放空沉澱，你的直覺靈感就是最強的人生導航儀！"
            PalaceType.WEALTH -> "小鹿兒點子：建立長期被動儲蓄或投資習慣，讓錢寶寶慢慢長大，不急躁才是真智慧！"
            PalaceType.CAREER -> "小鹿兒鼓勵：找一件自己由衷熱愛的事情鑽研到底，你天生的專注力會吸引賞識你的伯樂！"
            PalaceType.MARRIAGE -> "小鹿兒叮嚀：好的感情不是找完美的人，而是一起把生活過得有趣溫馨，多擁抱少爭執～"
            else -> "小鹿兒祝福：順其自然、依心而行，你比自己想像的更有力量！"
        }
    }

    private fun getPalaceStrengthTag(type: PalaceType, majorNames: List<String>): String {
        return when (type) {
            PalaceType.LIFE -> "核心天賦"
            PalaceType.WEALTH -> "吸金體質"
            PalaceType.CAREER -> "舞台焦點"
            PalaceType.MARRIAGE -> "良緣密碼"
            else -> "幸運能量"
        }
    }
}
