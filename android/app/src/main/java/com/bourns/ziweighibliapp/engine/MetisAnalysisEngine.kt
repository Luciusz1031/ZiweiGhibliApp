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

data class MetisDimensionDetail(
    val dimensionName: String,
    val iconName: String,
    val score: Int,
    val ratingText: String,
    val palaceName: String,
    val palaceBranchName: String,
    val majorStarsDisplay: String,
    val transformations: List<String>,
    val coreEssence: String,
    val advantages: List<String>,
    val blindSpots: List<String>,
    val actionStrategies: List<String>,
    val luckyFawnTips: String
)

data class MetisReading(
    val dimensionScores: Map<String, Double>,
    val oneSentenceHeadline: String,
    val threeCoreCards: List<MetisCoreCard>,
    val tenDimensions: List<MetisDimensionReading>,
    val dimensionDetails: Map<String, MetisDimensionDetail>
)

object MetisAnalysisEngine {

    fun analyze(chart: AstrolabeChart): MetisReading {
        val lifePalace = chart.palaces.firstOrNull { it.isLifePalace } ?: chart.palaces[0]
        val careerPalace = chart.palaces.firstOrNull { it.type == PalaceType.CAREER } ?: chart.palaces[0]
        val wealthPalace = chart.palaces.firstOrNull { it.type == PalaceType.WEALTH } ?: chart.palaces[0]
        val marriagePalace = chart.palaces.firstOrNull { it.type == PalaceType.MARRIAGE } ?: chart.palaces[0]
        val healthPalace = chart.palaces.firstOrNull { it.type == PalaceType.HEALTH } ?: chart.palaces[0]
        val friendsPalace = chart.palaces.firstOrNull { it.type == PalaceType.FRIENDS } ?: chart.palaces[0]
        val propertyPalace = chart.palaces.firstOrNull { it.type == PalaceType.PROPERTY } ?: chart.palaces[0]
        val parentsPalace = chart.palaces.firstOrNull { it.type == PalaceType.PARENTS } ?: chart.palaces[0]

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

        fun formatStars(p: PalaceData): String {
            val list = p.majorStars.map {
                val b = it.brightness?.label?.let { b -> "[$b]" } ?: ""
                "${it.name}$b"
            }
            return if (list.isEmpty()) "借對宮吉星拱照" else list.joinToString("、")
        }

        fun formatTransformations(p: PalaceData): List<String> {
            return p.stars.mapNotNull {
                it.natalTransformation?.let { tf -> "${it.name}化${tf.label}" }
            }
        }

        val details = mutableMapOf<String, MetisDimensionDetail>()

        // 1. 財富
        val wealthStars = wealthPalace.majorStars.map { it.name }
        val wealthAdv = mutableListOf<String>()
        val wealthBlind = mutableListOf<String>()
        val wealthAct = mutableListOf<String>()

        if (wealthStars.contains("武曲") || wealthStars.contains("天府") || wealthStars.contains("太陰")) {
            wealthAdv.add("正財正庫星坐鎮，善於靠無可替代的專業技術與穩健資產配置累積厚實財富。")
            wealthAdv.add("抗風險與守財能力卓越，在大環境動盪時懂得提前守住充足的流動性資金。")
            wealthBlind.add("有時過於謹慎保守，面對新興獲利模式易瞻前顧後錯失紅利期。")
            wealthAct.add("將每月結餘固定分配至指數型抗通膨資產或不動產，享受穩健複利。")
        } else if (wealthStars.contains("貪狼") || wealthStars.contains("廉貞") || wealthStars.contains("七殺") || wealthStars.contains("破軍")) {
            wealthAdv.add("商業直覺敏銳，具備跨界整合資源與開拓多元進帳管道的強大吸金體質。")
            wealthAdv.add("敢在風口來臨時搶佔先機，具備極佳的市場開拓與商業變現爆發力。")
            wealthBlind.add("切忌追求高槓桿短期暴利，防範因投機短炒而造成資產大幅波動。")
            wealthAct.add("嚴格執行停利與止損紀律，將冒險獲利即時轉入穩健資產鎖定勝局。")
        } else if (wealthStars.contains("天機") || wealthStars.contains("巨門")) {
            wealthAdv.add("靠腦力、智慧方案與溝通說服力生財，知識即財富，點子變現速度極快。")
            wealthBlind.add("思慮過多易猶豫不決，且需防人際溝通中的財務細節誤解。")
            wealthAct.add("深耕個人核心專業IP，將個人智慧成果標準化、產品化以擴大獲利規模。")
        } else {
            wealthAdv.add("以誠信與好人緣求財，善於借力使力，正財根基伴隨年歲穩步提升。")
            wealthBlind.add("面子開銷大或抹不開情面代墊款項，易產生隱形財務損耗。")
            wealthAct.add("親兄弟明算帳，重要商業合作務必白紙黑字，釐清權責。")
        }
        if (wealthPalace.stars.any { it.natalTransformation == TransformationType.LU }) {
            wealthAdv.add("財帛宮逢生年化祿，財源滾滾而來，求財路上總有貴人與良機相隨。")
        }
        if (wealthPalace.stars.any { it.natalTransformation == TransformationType.JI }) {
            wealthBlind.add("財帛宮逢化忌，資金周轉易有暗流，嚴禁幫人代墊或作保借貸。")
        }

        details["財富"] = MetisDimensionDetail(
            dimensionName = "財富",
            iconName = "AttachMoney",
            score = 92,
            ratingText = "財源亨通・多元吸金體質",
            palaceName = "財帛宮",
            palaceBranchName = "${wealthPalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(wealthPalace),
            transformations = formatTransformations(wealthPalace),
            coreEssence = "以 ${formatStars(wealthPalace)} 為求財根基。你的賺錢邏輯不靠道聽途說的盲目投機，而是靠個人無可替代的專業技術、獨特商業嗅覺與穩步累積，方能水到渠成。",
            advantages = wealthAdv,
            blindSpots = wealthBlind,
            actionStrategies = wealthAct,
            luckyFawnTips = "小鹿兒招財錦囊：在皮夾常備一張嶄新開運金鈔，日常多穿搭深綠、駝色系衣飾，財氣最聚！"
        )

        // 2. 事業
        val careerStars = careerPalace.majorStars.map { it.name }
        val careerAdv = mutableListOf<String>()
        val careerBlind = mutableListOf<String>()
        val careerAct = mutableListOf<String>()

        if (careerStars.contains("紫微") || careerStars.contains("天府") || careerStars.contains("太陽")) {
            careerAdv.add("職場自帶領袖威儀與大將之風，善於統籌全局並激發團隊潛能。")
            careerAdv.add("對效率與成果高度負責，容易贏得決策高層與重要客戶的全力信任。")
            careerBlind.add("求好心切時容易事必躬親，導致自身精疲力竭，需學會授權。")
            careerAct.add("將精力聚焦於最高價值的戰略方向與人脈樞紐，建立個人品牌聲量。")
        } else if (careerStars.contains("武曲") || careerStars.contains("七殺") || careerStars.contains("破軍")) {
            careerAdv.add("執行力雷厲風行、遇難題沉著果決，是能打硬仗的開疆拓土先鋒。")
            careerAdv.add("勇於破除組織陳規與低效流程，能帶領業務團隊取得突破性業績。")
            careerBlind.add("性格剛烈直率，易因言語急切而得罪同儕或合作夥伴。")
            careerAct.add("溝通時多留三分餘地，注重團隊協作以柔克剛，更能無往不利。")
        } else {
            careerAdv.add("處事細膩周全、應變適應力強，擅長跨部門協調與方案策劃。")
            careerBlind.add("面對重大轉折時容易思慮過度，需培養敢於拍板承擔的勇氣。")
            careerAct.add("定期梳理職場里程碑與作品集，用無可挑剔的專業建立無可替代的壁壘。")
        }

        details["事業"] = MetisDimensionDetail(
            dimensionName = "事業",
            iconName = "Work",
            score = 90,
            ratingText = "大將之風・開疆拓土先鋒",
            palaceName = "官祿宮",
            palaceBranchName = "${careerPalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(careerPalace),
            transformations = formatTransformations(careerPalace),
            coreEssence = "官祿宮坐鎮 ${formatStars(careerPalace)}，職場自帶擔當與執行力。適合在需要獨立決策、戰略規劃或核心技術的舞台發揮長才，越早獨當一面越容易成器。",
            advantages = careerAdv,
            blindSpots = careerBlind,
            actionStrategies = careerAct,
            luckyFawnTips = "小鹿兒事業錦囊：辦公桌左手邊擺放一盆生機盎然的常青綠植，能為你帶來貴人助力與清晰思路！"
        )

        // 3. 感情
        val marriageStars = marriagePalace.majorStars.map { it.name }
        val marriageAdv = mutableListOf<String>()
        val marriageBlind = mutableListOf<String>()
        val marriageAct = mutableListOf<String>()

        if (marriageStars.contains("天同") || marriageStars.contains("太陰") || marriageStars.contains("天府")) {
            marriageAdv.add("在親密關係中溫柔細膩、富有同理心，能給伴侶滿滿的家庭溫暖與情緒價值。")
            marriageAdv.add("懂得營造生活情趣，願意為維護關係和諧而體諒付出。")
            marriageBlind.add("偶爾多愁善感或將委屈悶在心底，需建立主動坦率的溝通機制。")
            marriageAct.add("有話當面溫和表達，多用正面肯定句代替批評建議，讚美能化解一切冰霜。")
        } else if (marriageStars.contains("紫微") || marriageStars.contains("太陽") || marriageStars.contains("武曲")) {
            marriageAdv.add("對感情專一真誠、富有責任擔當，願意為共同未來構築堅實物質與精神後盾。")
            marriageBlind.add("性格較為強勢理性，說話習慣講道理而忽略了伴侶的情感共鳴需求。")
            marriageAct.add("每週安排專屬雙人時光，放下手機傾聽伴侶心聲，柔軟擁抱勝過千言萬語。")
        } else {
            marriageAdv.add("重視精神共鳴與彼此獨立自由的空間，相處像最好的知己與戰友。")
            marriageBlind.add("情緒易受外在環境牽動，偶有忽冷忽熱讓對方產生不安全感。")
            marriageAct.add("定期表達感恩與愛意，共同培養一項戶外或休閒興趣深化黏著度。")
        }

        details["感情"] = MetisDimensionDetail(
            dimensionName = "感情",
            iconName = "Favorite",
            score = 86,
            ratingText = "情深意篤・心靈共鳴伴侶",
            palaceName = "夫妻宮",
            palaceBranchName = "${marriagePalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(marriagePalace),
            transformations = formatTransformations(marriagePalace),
            coreEssence = "夫妻宮由 ${formatStars(marriagePalace)} 守護。你在親密關係中重視的是精神層面的深度對話與三觀契合，比起海誓山盟，你更珍惜患難與共、平淡真實的默契溫暖。",
            advantages = listOf(
                "對感情專一真誠，一旦認定對方願意傾力守護與付出。",
                "擅長在日常細節中照顧伴侶感受，給予實質安全感。",
                "遇分歧時願以家庭大局為重，具備成熟的包容度。"
            ),
            blindSpots = listOf(
                "有時習慣將煩惱悶在心裡自己扛，容易讓伴侶感到疏離。",
                "說話過於耿直講理，感情相處更需要柔軟共情與溫暖擁抱。"
            ),
            actionStrategies = listOf(
                "每週安排專屬約會夜，放下手機，純粹分享生活趣事與心情。",
                "多用正面肯定句代替批評建議，讚美能化解一切冰霜。"
            ),
            luckyFawnTips = "小鹿兒姻緣錦囊：臥室擺放柔和暖色系床頭夜燈，多噴點溫馨木質調香氛，良緣自然甜甜蜜蜜！"
        )

        details["性格"] = MetisDimensionDetail(
            dimensionName = "性格",
            iconName = "Person",
            score = 92,
            ratingText = "自尊獨立・內蘊剛毅之質",
            palaceName = "命宮 (本命元辰)",
            palaceBranchName = "${lifePalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(lifePalace),
            transformations = formatTransformations(lifePalace),
            coreEssence = "以 ${formatStars(lifePalace)} 為人格內核。你天生具有鮮明的主見與抗壓韌性，外表或許溫文儒雅，但內心自有一套不可動搖的原則與價值尺度。",
            advantages = listOf(
                "挫敗復原力極強，在逆境中往往能激發出超乎常人的爆發力。",
                "知世故而不世故，珍惜真誠朋友，不屑於虛偽迎合。",
                "自省能力高，能不斷在實踐中進化升級思維格局。"
            ),
            blindSpots = listOf(
                "容易因自我要求過高而陷入精神內耗，需學會放過自己。",
                "防備心較重，初期不容易輕易向他人打開心扉。"
            ),
            actionStrategies = listOf(
                "每天留給自己 15 分鐘放空靜心，與內在的小孩好好對話。",
                "接受不完美是人生的常態，七分奮鬥、三分隨緣最自在。"
            ),
            luckyFawnTips = "小鹿兒開運錦囊：晨起喝一杯溫開水，面向陽光深呼吸三次，喚醒元辰神清氣爽！"
        )

        details["健康"] = MetisDimensionDetail(
            dimensionName = "健康",
            iconName = "LocalHospital",
            score = 85,
            ratingText = "調和陰陽・養生蓄力時期",
            palaceName = "疾厄宮",
            palaceBranchName = "${healthPalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(healthPalace),
            transformations = formatTransformations(healthPalace),
            coreEssence = "疾厄宮坐鎮 ${formatStars(healthPalace)}。平日精力充沛，但需預防過度透支身體。你的健康關鍵在於情緒壓力疏導與順應四季的作息節律。",
            advantages = listOf(
                "身體自我修復力佳，平時注意養生便能長久維持健康狀態。",
                "對身體信號相對敏感，能及時察覺不適並調整生活節奏。"
            ),
            blindSpots = listOf(
                "工作投入時易忘記喝水與走動，久坐易引發肩頸腰背緊繃。",
                "晚餐時間若不規律，容易對消化系統產生額外負擔。"
            ),
            actionStrategies = listOf(
                "培養每週 2-3 次流汗運動（如慢跑、游泳、健走），促進代謝。",
                "睡前 30 分鐘關閉 3C 藍光螢幕，聽輕柔白噪音有助深度睡眠。"
            ),
            luckyFawnTips = "小鹿兒養生錦囊：隨身攜帶溫水保溫杯，多喝溫潤花草茶，脾胃溫暖人就長壽！"
        )

        details["人際貴人"] = MetisDimensionDetail(
            dimensionName = "人際貴人",
            iconName = "Group",
            score = 88,
            ratingText = "高朋滿座・長輩同儕照應",
            palaceName = "交友宮 / 遷移宮",
            palaceBranchName = "${friendsPalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(friendsPalace),
            transformations = formatTransformations(friendsPalace),
            coreEssence = "交友宮呈現 ${formatStars(friendsPalace)} 之相。你的貴人運多出自專業圈層與遠行機遇，以誠待人、言出必行是吸引大咖前輩提攜的致勝法寶。",
            advantages = listOf(
                "自帶親和力與可信度，容易在重要場合結交優質人脈。",
                "為人仗義知恩圖報，身邊總有願意鼎力相助的鐵桿摯友。"
            ),
            blindSpots = listOf(
                "對朋友防備心低，需防範酒肉朋友或居心叵測者的言語誘惑。"
            ),
            actionStrategies = listOf(
                "定期篩選人脈圈，多花時間深耕 5-10 位同頻共振的良師益友。",
                "主動為他人創造價值，善緣如同回力鏢必將豐厚回饋自身。"
            ),
            luckyFawnTips = "小鹿兒人緣錦囊：常懷感恩心，逢年過節主動向長輩前輩發送真誠祝福，貴人運長存！"
        )

        details["田宅"] = MetisDimensionDetail(
            dimensionName = "田宅",
            iconName = "Home",
            score = 89,
            ratingText = "基業安穩・福宅庇蔭後代",
            palaceName = "田宅宮",
            palaceBranchName = "${propertyPalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(propertyPalace),
            transformations = formatTransformations(propertyPalace),
            coreEssence = "田宅宮代表家庭安全感、不動產資產與祖業福蔭。宮內星曜和順，一生中極有機會擁有舒適溫馨、地段優越的理想居所。",
            advantages = listOf(
                "對房屋地段與居家舒適度有極佳品味，置產眼光精準。",
                "居家環境常能為你提供滿滿的充電能量與心靈安定感。"
            ),
            blindSpots = listOf(
                "裝潢修繕時易因追求完美而超支預算，需提前做好規劃。"
            ),
            actionStrategies = listOf(
                "資產累積到一定階段，優先配置穩健地段抗通膨的不動產。",
                "保持家中通風明亮、玄關乾淨無雜物，家肥屋潤氣自華。"
            ),
            luckyFawnTips = "小鹿兒家宅錦囊：客廳擺放圓葉植物或天然水晶礦石，全家人和樂融融福運滿堂！"
        )

        details["婚戀"] = details["感情"]!!

        details["父母長輩"] = MetisDimensionDetail(
            dimensionName = "父母長輩",
            iconName = "VolunteerActivism",
            score = 86,
            ratingText = "承蒙庇蔭・孝悌福祿隨身",
            palaceName = "父母宮",
            palaceBranchName = "${parentsPalace.earthlyBranch.branchName}宮",
            majorStarsDisplay = formatStars(parentsPalace),
            transformations = formatTransformations(parentsPalace),
            coreEssence = "父母宮坐鎮 ${formatStars(parentsPalace)}。長輩的家訓與言傳身教是你人生道路上的重要指路明燈，孝順父母乃世間第一大福田。",
            advantages = listOf(
                "自幼承蒙父母長輩關照，家庭觀念深厚而有溫度。",
                "在職場中容易得到年長主管或資深導師的特別青睞。"
            ),
            blindSpots = listOf(
                "偶有兩代觀念代溝，切勿因性急而口出重言傷害長輩。"
            ),
            actionStrategies = listOf(
                "定期致電關心父母生活細節，陪伴是最好的孝順方式。",
                "虛心請教長輩人生閱歷，他們的智慧能幫你避開許多暗坑。"
            ),
            luckyFawnTips = "小鹿兒福報錦囊：多給父母長輩添置保暖舒適衣物，百善孝為先，天地自護持！"
        )

        return MetisReading(
            dimensionScores = scores,
            oneSentenceHeadline = headline,
            threeCoreCards = coreCards,
            tenDimensions = tenDimensions,
            dimensionDetails = details
        )
    }
}
