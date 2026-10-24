package com.bourns.ziweighibliapp.engine

import android.content.Context
import com.bourns.ziweighibliapp.models.AstrolabeChart
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

object GoogleSheetsSyncManager {
    private const val PREF_NAME = "xiaoluer_google_sheets_pref"
    private const val KEY_WEBHOOK_URL = "webhook_url"
    private const val KEY_ENABLED = "sync_enabled"

    fun getWebhookUrl(context: Context): String {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        return sp.getString(KEY_WEBHOOK_URL, "") ?: ""
    }

    fun setWebhookUrl(context: Context, url: String) {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        sp.edit().putString(KEY_WEBHOOK_URL, url.trim()).apply()
    }

    fun isEnabled(context: Context): Boolean {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        return sp.getBoolean(KEY_ENABLED, true)
    }

    fun setEnabled(context: Context, enabled: Boolean) {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        sp.edit().putBoolean(KEY_ENABLED, enabled).apply()
    }

    /**
     * 非同步將排盤紀錄上傳至 Google Sheet
     */
    fun syncChart(
        context: Context,
        chart: AstrolabeChart,
        solarBirthDate: Date,
        isUnknownHour: Boolean,
        onComplete: ((Boolean, String?) -> Unit)? = null
    ) {
        val urlStr = getWebhookUrl(context)
        if (!isEnabled(context) || urlStr.isBlank()) {
            onComplete?.invoke(false, "未設定 Google Sheet 網址或已關閉同步")
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val nowDf = SimpleDateFormat("yyyy/MM/dd HH:mm:ss", Locale.TAIWAN).apply {
                    timeZone = TimeZone.getTimeZone("Asia/Taipei")
                }
                val birthDf = SimpleDateFormat("yyyy年MM月dd日", Locale.TAIWAN)
                val timeDf = SimpleDateFormat("HH:mm", Locale.TAIWAN)

                val birthTimeStr = if (isUnknownHour) "未知 (以子時起盤)" else timeDf.format(solarBirthDate)

                val json = JSONObject().apply {
                    put("timestamp", nowDf.format(Date()))
                    put("userName", chart.userName)
                    put("gender", chart.gender.label)
                    put("solarBirthDate", birthDf.format(solarBirthDate))
                    put("birthTime", birthTimeStr)
                    put("isUnknownHour", if (isUnknownHour) "是 (以子時起盤)" else "否")
                    put("lunarBirthDate", chart.lunarInfo.lunarDateString)
                    put("baZi", chart.lunarInfo.baZiString)
                    put("elementBureau", chart.elementBureau.bureauName)
                    put("lifeMaster", chart.lifeMasterStar)
                    put("bodyMaster", chart.bodyMasterStar)
                    put("platform", "Android (小鹿兒算命)")
                }

                val result = sendPostRequest(urlStr, json.toString())
                withContext(Dispatchers.Main) {
                    onComplete?.invoke(result.first, result.second)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    onComplete?.invoke(false, e.localizedMessage)
                }
            }
        }
    }

    /**
     * 測試 Google Apps Script Web App 連線
     */
    fun testConnection(
        urlStr: String,
        onComplete: (Boolean, String) -> Unit
    ) {
        val trimmed = urlStr.trim()
        if (trimmed.isBlank()) {
            onComplete(false, "網址不得為空")
            return
        }
        if (trimmed.contains("docs.google.com/spreadsheets")) {
            onComplete(false, "⚠️ 您輸入的是 Google 試算表頁面網址，請依照教學貼上 Apps Script 部署後的「網頁應用程式網址 (Web App URL)」(結尾應為 /exec)！")
            return
        }
        if (trimmed.endsWith("/edit") || trimmed.contains("script.google.com/home/projects")) {
            onComplete(false, "⚠️ 您輸入的是 Apps Script 編輯器網址，請點選右上角「部署」>「新增部署作業」複製網頁應用程式網址！")
            return
        }
        if (trimmed.endsWith("/dev")) {
            onComplete(false, "⚠️ 您輸入的是測試開發網址 (/dev)，此網址要求登入 Google 帳號。請在部署時建立正式網頁應用程式，取得 /exec 結尾的網址！")
            return
        }
        if (!trimmed.startsWith("https://")) {
            onComplete(false, "網址格式不正確，必須以 https:// 開頭")
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val testJson = JSONObject().apply {
                    put("timestamp", "測試連線")
                    put("userName", "小鹿連線測試")
                    put("gender", "-")
                    put("solarBirthDate", "-")
                    put("birthTime", "-")
                    put("isUnknownHour", "-")
                    put("lunarBirthDate", "測試成功")
                    put("baZi", "-")
                    put("elementBureau", "-")
                    put("lifeMaster", "-")
                    put("bodyMaster", "-")
                    put("platform", "Android 測試訊號")
                }
                val (success, msg) = sendPostRequest(trimmed, testJson.toString())
                withContext(Dispatchers.Main) {
                    if (success) {
                        onComplete(true, "✅ 連線成功！已傳送一筆測試資料至 Google Sheet，請查看試算表是否出現「小鹿連線測試」一列。")
                    } else {
                        onComplete(false, msg ?: "連線失敗，請檢查網址或權限設定。")
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    onComplete(false, e.localizedMessage ?: "連線發生錯誤")
                }
            }
        }
    }

    private fun sendPostRequest(targetUrl: String, jsonString: String): Pair<Boolean, String?> {
        var connection: HttpURLConnection? = null
        return try {
            val url = URL(targetUrl)
            connection = (url.openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                doOutput = true
                doInput = true
                instanceFollowRedirects = true
                connectTimeout = 12000
                readTimeout = 12000
                setRequestProperty("Content-Type", "application/json; charset=UTF-8")
                setRequestProperty("Accept", "application/json")
            }

            OutputStreamWriter(connection.outputStream, "UTF-8").use { os ->
                os.write(jsonString)
                os.flush()
            }

            val responseCode = connection.responseCode
            val stream = if (responseCode in 200..399) connection.inputStream else connection.errorStream
            val responseBody = stream?.bufferedReader()?.use { it.readText() } ?: ""

            if (responseBody.contains("accounts.google.com") || responseBody.contains("ServiceLogin")) {
                Pair(false, "❌ 權限設定錯誤：Apps Script 部署時「誰可以存取 (Who has access)」未設為「所有人 (Anyone)」，請至 Apps Script 重新部署！")
            } else if (responseBody.contains("\"status\":\"error\"")) {
                val errJson = try { JSONObject(responseBody).optString("message") } catch (e: Exception) { responseBody }
                Pair(false, "❌ 試算表寫入失敗: $errJson")
            } else if (responseCode in 200..399) {
                Pair(true, null)
            } else {
                Pair(false, "❌ 伺服器回應碼: $responseCode")
            }
        } catch (e: Exception) {
            Pair(false, e.message)
        } finally {
            connection?.disconnect()
        }
    }
}
