package com.bourns.ziweighibliapp.engine

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.bourns.ziweighibliapp.models.AstrolabeChart
import java.text.SimpleDateFormat
import java.util.Locale

object AstrolabeTextReportGenerator {

    /**
     * 產生通俗易懂、結構完整的全套命盤白話文解說報告（可一鍵分享至 LINE、微信、Email、備忘錄）
     */
    fun generateFullReport(chart: AstrolabeChart): String {
        val df = SimpleDateFormat("yyyy年MM月dd日 HH:mm", Locale.TAIWAN)
        val birthStr = if (chart.isUnknownHour) {
            "${df.format(chart.birthDate)} (時辰未定・以子時起盤)"
        } else {
            df.format(chart.birthDate)
        }

        val metisReading = MetisAnalysisEngine.analyze(chart)

        val sb = StringBuilder()
        sb.append("🦌【小鹿兒算命・紫微斗數天命全覽報告】\n")
        sb.append("━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("【命主基本資料】\n")
        sb.append("• 命主姓名：${chart.userName}（${chart.gender.label}）\n")
        sb.append("• 國曆生辰：$birthStr\n")
        sb.append("• 農曆八字：${chart.lunarInfo.baZiString}\n")
        sb.append("• 農曆生辰：${chart.lunarInfo.lunarDateString}\n")
        sb.append("• 五行局數：${chart.elementBureau.bureauName}\n")
        sb.append("• 命宮坐鎮：${chart.lifePalaceBranch.branchName}宮（命主：${chart.lifeMasterStar}）\n")
        sb.append("• 身宮坐鎮：${chart.bodyPalaceBranch.branchName}宮（身主：${chart.bodyMasterStar}）\n")
        sb.append("• 流派標準：倪海廈先生《天紀》排盤體系・真太陽時精密校驗\n\n")

        sb.append("━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("✨【白話核心天命總綱】\n")
        sb.append("「${metisReading.oneSentenceHeadline}」\n\n")

        sb.append("━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("🔮【三大核心天命指引】\n")
        for (card in metisReading.threeCoreCards) {
            sb.append("• 【${card.title}】(${card.tag})：\n  ${card.description}\n")
        }

        sb.append("\n━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("🌟【六維天命能量雷達指數】\n")
        for ((k, v) in metisReading.dimensionScores) {
            sb.append("• $k：${(v * 100).toInt()} 分\n")
        }

        sb.append("\n━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("📜【人生十象專屬解說】\n")
        for (dim in metisReading.tenDimensions) {
            sb.append("• 【${dim.dimensionName}】(${dim.score}分・${dim.rating})：\n  ${dim.interpretation}\n")
        }

        sb.append("\n━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("📂【各大維度專屬深度剖析】\n")
        for ((dimName, detail) in metisReading.dimensionDetails) {
            sb.append("\n【$dimName 解析】（得分：${detail.score}分・評級：${detail.ratingText}）\n")
            sb.append("• 核心宮位：${detail.palaceName} (${detail.palaceBranchName})\n")
            sb.append("• 坐鎮星曜：${detail.majorStarsDisplay}\n")
            sb.append("• 核心天命：${detail.coreEssence}\n")
            sb.append("• 天賦優勢：${detail.advantages.joinToString("；")}\n")
            sb.append("• 避坑提醒：${detail.blindSpots.joinToString("；")}\n")
            sb.append("• 落地策略：${detail.actionStrategies.joinToString("；")}\n")
            sb.append("• 小鹿開運：${detail.luckyFawnTips}\n")
        }

        sb.append("\n━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("🏛️【倪海廈《天紀》經典格局匹配】\n")
        if (chart.patterns.isEmpty()) {
            sb.append("本命格局平正溫和，無極端偏煞，行運以穩健中求進展為上。\n")
        } else {
            for (pattern in chart.patterns) {
                sb.append("★【${pattern.name}】（${if (pattern.isAuspicious) "吉格" else "變局"}）\n")
                sb.append("  描述：${pattern.description}\n")
                sb.append("  倪師點評：${pattern.tianjiComment}\n")
            }
        }

        sb.append("\n━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("🦌【小鹿兒開運修心指引】\n")
        sb.append("「算命之目的，絕非消極認命，而在於知己知彼，順應天時。人人皆有先天命盤之強弱，然心念一轉，言行即變；言行一變，命運自開。」\n")
        sb.append("━━━━━━━━━━━━━━━━━━━━\n")
        sb.append("本報告由《小鹿兒算命》App 自動運算生成・祝您福祿安康、順遂平安！\n")

        return sb.toString()
    }

    /**
     * 呼叫 Android 系統原生分享 (支援 LINE, 微信, Gmail, 訊息等)
     */
    fun shareReport(context: Context, chart: AstrolabeChart) {
        val reportText = generateFullReport(chart)
        val sendIntent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_TEXT, reportText)
            putExtra(Intent.EXTRA_SUBJECT, "小鹿兒算命・${chart.userName}紫微斗數天命全覽報告")
            type = "text/plain"
        }
        val shareIntent = Intent.createChooser(sendIntent, "分享命盤解析報告至...")
        context.startActivity(shareIntent)
    }

    /**
     * 一鍵複製完整文字報告到剪貼簿
     */
    fun copyReportToClipboard(context: Context, chart: AstrolabeChart) {
        val reportText = generateFullReport(chart)
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("小鹿兒命盤報告", reportText)
        clipboard.setPrimaryClip(clip)
        Toast.makeText(context, "✅ 已成功複製完整命盤解析報告！", Toast.LENGTH_SHORT).show()
    }
}
