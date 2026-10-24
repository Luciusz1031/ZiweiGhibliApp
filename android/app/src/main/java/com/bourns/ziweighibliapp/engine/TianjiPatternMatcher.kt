package com.bourns.ziweighibliapp.engine

import com.bourns.ziweighibliapp.models.*

object TianjiPatternMatcher {
    fun matchPatterns(palaces: List<PalaceData>, lifeBranch: EarthlyBranch): List<TianjiPattern> {
        val patterns = mutableListOf<TianjiPattern>()
        val lifePalace = palaces.firstOrNull { it.earthlyBranch == lifeBranch } ?: return emptyList()

        val lifeStars = lifePalace.majorStars.map { it.name }.toSet()

        // 1. 紫府同宮格
        if (lifeStars.contains("紫微") && lifeStars.contains("天府")) {
            patterns.add(
                TianjiPattern(
                    name = "紫府同宮格",
                    isAuspicious = true,
                    description = "紫微帝星與天府庫星同宮坐命，一生福祿雙全，貴人多助，氣度寬宏。",
                    tianjiComment = "倪海廈《天紀》：紫微天府在寅申同宮，為極貴之格，為人忠厚有德，多得長輩提拔，衣食無憂。"
                )
            )
        }

        // 2. 殺破狼格
        val sanFangBranches = listOf(
            lifeBranch.index,
            (lifeBranch.index + 4) % 12,
            (lifeBranch.index + 8) % 12,
            (lifeBranch.index + 6) % 12
        )
        val sanFangStars = palaces
            .filter { sanFangBranches.contains(it.earthlyBranch.index) }
            .flatMap { it.majorStars }
            .map { it.name }
            .toSet()

        if (sanFangStars.contains("七殺") && sanFangStars.contains("破軍") && sanFangStars.contains("貪狼")) {
            patterns.add(
                TianjiPattern(
                    name = "殺破狼開拓格",
                    isAuspicious = true,
                    description = "七殺、破軍、貪狼三星於三方會照，一生敢闖敢拼，富冒險改革精神。",
                    tianjiComment = "倪海廈《天紀》：殺破狼為人生開拓格局，動中求財，變動中見真章，逢吉化則成大器。"
                )
            )
        }

        // 3. 巨日同宮格
        if (lifeStars.contains("太陽") && lifeStars.contains("巨門")) {
            patterns.add(
                TianjiPattern(
                    name = "巨日同宮格",
                    isAuspicious = true,
                    description = "太陽之光化解巨門之暗，具備極強的口才雄辯與領導才能，名揚四海。",
                    tianjiComment = "倪海廈《天紀》：巨門為暗宿，得太陽同宮照明，食祿千鐘，最利法律、傳媒與公眾事業。"
                )
            )
        }

        // 4. 機月同梁格
        if (sanFangStars.contains("天機") && sanFangStars.contains("太陰") && sanFangStars.contains("天同") && sanFangStars.contains("天梁")) {
            patterns.add(
                TianjiPattern(
                    name = "機月同梁格",
                    isAuspicious = true,
                    description = "天機太陰天同天梁會照，深具策劃輔佐長才，為頂尖參謀企劃型命格。",
                    tianjiComment = "倪海廈《天紀》：機月同梁作吏人，擅幕僚企劃、精密策劃與公職金融，生活穩定富足。"
                )
            )
        }

        return patterns
    }
}
