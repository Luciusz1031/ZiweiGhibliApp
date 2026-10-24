package com.bourns.ziweighibliapp.engine

import android.icu.util.ChineseCalendar
import com.bourns.ziweighibliapp.models.EarthlyBranch
import com.bourns.ziweighibliapp.models.HeavenlyStem
import com.bourns.ziweighibliapp.models.LunarDateInfo
import java.util.Calendar
import java.util.Date

object ChineseCalendarHelper {
    fun getLunarDateInfo(date: Date, hourBranch: EarthlyBranch): LunarDateInfo {
        val cc = ChineseCalendar()
        cc.time = date

        val lunarMonthRaw = cc.get(ChineseCalendar.MONTH) + 1
        val isLeapMonth = cc.get(ChineseCalendar.IS_LEAP_MONTH) == 1
        val lunarDay = cc.get(ChineseCalendar.DAY_OF_MONTH)

        val cal = Calendar.getInstance()
        cal.time = date
        val gregYear = cal.get(Calendar.YEAR)
        val gregMonth = cal.get(Calendar.MONTH) + 1
        var actualYear = gregYear
        if (gregMonth == 1 && lunarMonthRaw >= 11) {
            actualYear = gregYear - 1
        }

        val yearStemIndex = (actualYear - 4) % 10
        val yearStem = HeavenlyStem.fromIndex(yearStemIndex)
        val yearBranchIndex = (actualYear - 4) % 12
        val yearBranch = EarthlyBranch.fromIndex(yearBranchIndex)

        // 五虎遁月起月干
        val startStemIndex = when (yearStem) {
            HeavenlyStem.JIA, HeavenlyStem.JI -> HeavenlyStem.BING.index
            HeavenlyStem.YI, HeavenlyStem.GENG -> HeavenlyStem.WU.index
            HeavenlyStem.BING, HeavenlyStem.XIN -> HeavenlyStem.GENG.index
            HeavenlyStem.DING, HeavenlyStem.REN -> HeavenlyStem.REN.index
            HeavenlyStem.WU, HeavenlyStem.GUI -> HeavenlyStem.JIA.index
        }
        val monthStem = HeavenlyStem.fromIndex(startStemIndex + (lunarMonthRaw - 1))
        val monthBranch = EarthlyBranch.fromIndex(EarthlyBranch.YIN.index + (lunarMonthRaw - 1))

        // 日干支：基準日 1900-01-31 為 甲辰日
        val baseCal = Calendar.getInstance().apply {
            set(1900, 0, 31, 0, 0, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val diffDays = ((date.time - baseCal.timeInMillis) / (1000 * 60 * 60 * 24)).toInt()
        val dayStemIndex = (HeavenlyStem.JIA.index + diffDays) % 10
        val dayBranchIndex = (EarthlyBranch.CHEN.index + diffDays) % 12
        val dayStem = HeavenlyStem.fromIndex(dayStemIndex)
        val dayBranch = EarthlyBranch.fromIndex(dayBranchIndex)

        // 五鼠遁日起時干
        val hourStartStemIndex = when (dayStem) {
            HeavenlyStem.JIA, HeavenlyStem.JI -> HeavenlyStem.JIA.index
            HeavenlyStem.YI, HeavenlyStem.GENG -> HeavenlyStem.BING.index
            HeavenlyStem.BING, HeavenlyStem.XIN -> HeavenlyStem.WU.index
            HeavenlyStem.DING, HeavenlyStem.REN -> HeavenlyStem.GENG.index
            HeavenlyStem.WU, HeavenlyStem.GUI -> HeavenlyStem.REN.index
        }
        val hourStem = HeavenlyStem.fromIndex(hourStartStemIndex + hourBranch.index)

        return LunarDateInfo(
            lunarYear = actualYear,
            lunarMonth = lunarMonthRaw,
            lunarDay = lunarDay,
            isLeapMonth = isLeapMonth,
            yearStem = yearStem,
            yearBranch = yearBranch,
            monthStem = monthStem,
            monthBranch = monthBranch,
            dayStem = dayStem,
            dayBranch = dayBranch,
            hourStem = hourStem,
            hourBranch = hourBranch
        )
    }
}
