package com.bourns.ziweighibliapp.models

enum class EarthlyBranch(val index: Int, val branchName: String, val element: String) {
    ZI(0, "子", "水"),
    CHOU(1, "丑", "土"),
    YIN(2, "寅", "木"),
    MAO(3, "卯", "木"),
    CHEN(4, "辰", "土"),
    SI(5, "巳", "火"),
    WU(6, "午", "火"),
    WEI(7, "未", "土"),
    SHEN(8, "申", "金"),
    YOU(9, "酉", "金"),
    XU(10, "戌", "土"),
    HAI(11, "亥", "水");

    companion object {
        fun fromIndex(idx: Int): EarthlyBranch = values()[(idx % 12 + 12) % 12]
    }
}

enum class HeavenlyStem(val index: Int, val stemName: String, val element: String, val isYang: Boolean) {
    JIA(0, "甲", "木", true),
    YI(1, "乙", "木", false),
    BING(2, "丙", "火", true),
    DING(3, "丁", "火", false),
    WU(4, "戊", "土", true),
    JI(5, "己", "土", false),
    GENG(6, "庚", "金", true),
    XIN(7, "辛", "金", false),
    REN(8, "壬", "水", true),
    GUI(9, "癸", "水", false);

    companion object {
        fun fromIndex(idx: Int): HeavenlyStem = values()[(idx % 10 + 10) % 10]
    }
}

enum class Gender(val label: String, val isMale: Boolean) {
    MALE("男乾造", true),
    FEMALE("女坤造", false)
}

enum class StarCategory {
    MAJOR,
    LUCKY,
    FIERCE,
    AUXILIARY,
    MINOR
}

enum class StarBrightness(val label: String) {
    MIAO("廟"),
    WANG("旺"),
    DE("得"),
    LI("利"),
    PING("平"),
    XIAN("閑"),
    TRAPPED("陷")
}

enum class TransformationType(val label: String) {
    LU("祿"),
    QUAN("權"),
    KE("科"),
    JI("忌")
}

enum class PalaceType(val index: Int, val palaceName: String) {
    LIFE(0, "命宮"),
    SIBLINGS(1, "兄弟宮"),
    MARRIAGE(2, "夫妻宮"),
    CHILDREN(3, "子女宮"),
    WEALTH(4, "財帛宮"),
    HEALTH(5, "疾厄宮"),
    TRAVEL(6, "遷移宮"),
    FRIENDS(7, "交友宮"),
    CAREER(8, "官祿宮"),
    PROPERTY(9, "田宅宮"),
    HAPPINESS(10, "福德宮"),
    PARENTS(11, "父母宮");

    companion object {
        fun fromIndex(idx: Int): PalaceType = values()[(idx % 12 + 12) % 12]
    }
}

enum class ElementBureau(val bureauName: String, val number: Int) {
    WATER_2("水二局", 2),
    WOOD_3("木三局", 3),
    METAL_4("金四局", 4),
    EARTH_5("土五局", 5),
    FIRE_6("火六局", 6)
}
