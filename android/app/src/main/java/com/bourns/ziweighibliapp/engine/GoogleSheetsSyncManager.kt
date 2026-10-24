package com.bourns.ziweighibliapp.engine

import android.content.Context
import com.bourns.ziweighibliapp.models.AstrolabeChart
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

object GoogleSheetsSyncManager {
    private const val PREF_NAME = "xiaoluer_google_sheets_pref"
    private const val KEY_WEBHOOK_URL = "webhook_url"
    private const val KEY_OFFLINE_QUEUE = "offline_queue"

    // 正式部署的 Google Apps Script Web App 網址
    const val DEFAULT_WEBHOOK_URL = "https://script.google.com/macros/s/AKfycbzUZm93oNx74FAUj-5ZkUI8pNLXh4AnY_h_UV6VlgzWmWw4gC4chrYGQajC8aePgtM5/exec"

    fun getWebhookUrl(context: Context): String {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val saved = sp.getString(KEY_WEBHOOK_URL, "") ?: ""
        return if (saved.isBlank()) DEFAULT_WEBHOOK_URL else saved
    }

    fun setWebhookUrl(context: Context, url: String) {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        sp.edit().putString(KEY_WEBHOOK_URL, url.trim()).apply()
    }

    /**
     * 非同步將排盤紀錄上傳至 Google Sheet（離線時自動暫存於本機）
     */
    fun syncChart(
        context: Context,
        chart: AstrolabeChart,
        solarBirthDate: Date,
        isUnknownHour: Boolean,
        onComplete: ((Boolean, String?) -> Unit)? = null
    ) {
        val urlStr = getWebhookUrl(context)

        CoroutineScope(Dispatchers.IO).launch {
            val json = try {
                val nowDf = SimpleDateFormat("yyyy/MM/dd HH:mm:ss", Locale.TAIWAN).apply {
                    timeZone = TimeZone.getTimeZone("Asia/Taipei")
                }
                val birthDf = SimpleDateFormat("yyyy年MM月dd日", Locale.TAIWAN)
                val timeDf = SimpleDateFormat("HH:mm", Locale.TAIWAN)
                val birthTimeStr = if (isUnknownHour) "未知 (以子時起盤)" else timeDf.format(solarBirthDate)

                JSONObject().apply {
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
            } catch (e: Exception) {
                null
            }

            if (json == null) {
                withContext(Dispatchers.Main) { onComplete?.invoke(false, "資料封裝失敗") }
                return@launch
            }

            val result = sendPostRequest(urlStr, json.toString())
            if (!result.first) {
                // 網路失敗或離線：存入本機離線隊列
                enqueueOffline(context, json)
            } else {
                // 發送成功：順便嘗試清空先前的離線隊列
                flushOfflineQueue(context)
            }

            withContext(Dispatchers.Main) {
                onComplete?.invoke(result.first, result.second)
            }
        }
    }

    // MARK: - 離線隊列與自動重試

    private fun getOfflineQueue(context: Context): MutableList<String> {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val raw = sp.getString(KEY_OFFLINE_QUEUE, "[]") ?: "[]"
        val list = mutableListOf<String>()
        try {
            val arr = JSONArray(raw)
            for (i in 0 until arr.length()) {
                list.add(arr.getString(i))
            }
        } catch (_: Exception) {}
        return list
    }

    private fun saveOfflineQueue(context: Context, list: List<String>) {
        val sp = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val arr = JSONArray()
        list.forEach { arr.put(it) }
        sp.edit().putString(KEY_OFFLINE_QUEUE, arr.toString()).apply()
    }

    private fun enqueueOffline(context: Context, json: JSONObject) {
        val list = getOfflineQueue(context)
        list.add(json.toString())
        saveOfflineQueue(context, list)
    }

    /**
     * 當 App 啟動或有網路時，自動將所有未送出的離線資料補傳至 Google Sheet
     */
    fun flushOfflineQueue(context: Context) {
        CoroutineScope(Dispatchers.IO).launch {
            val list = getOfflineQueue(context)
            if (list.isEmpty()) return@launch

            val urlStr = getWebhookUrl(context)
            val remaining = mutableListOf<String>()

            for (item in list) {
                val res = sendPostRequest(urlStr, item)
                if (!res.first) {
                    remaining.add(item)
                }
            }

            saveOfflineQueue(context, remaining)
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

            if (responseCode in 200..399 && !responseBody.contains("\"status\":\"error\"")) {
                Pair(true, null)
            } else {
                Pair(false, "回應錯誤: $responseCode")
            }
        } catch (e: Exception) {
            Pair(false, e.message)
        } finally {
            connection?.disconnect()
        }
    }
}
