package com.bourns.ziweighibliapp.ui.screens

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.GoogleSheetsSyncManager
import com.bourns.ziweighibliapp.models.Gender
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.theme.*
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun BirthInputScreen(
    onGenerateChart: (Date, Gender, String, Boolean) -> Unit
) {
    val context = LocalContext.current
    val scrollState = rememberScrollState()

    var userName by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf(Gender.MALE) }
    var isUnknownHour by remember { mutableStateOf(false) }

    var showGoogleSheetsDialog by remember { mutableStateOf(false) }
    var webhookUrlInput by remember { mutableStateOf(GoogleSheetsSyncManager.getWebhookUrl(context)) }
    var isSyncEnabled by remember { mutableStateOf(GoogleSheetsSyncManager.isEnabled(context)) }
    var testStatusMessage by remember { mutableStateOf<String?>(null) }
    var isTesting by remember { mutableStateOf(false) }

    // 預設日期：1982年10月31日 12:00
    val calendar = remember {
        Calendar.getInstance().apply {
            set(1982, Calendar.OCTOBER, 31, 12, 0, 0)
        }
    }
    var currentYear by remember { mutableStateOf(1982) }
    var currentMonth by remember { mutableStateOf(Calendar.OCTOBER) }
    var currentDay by remember { mutableStateOf(31) }
    var currentHour by remember { mutableStateOf(12) }
    var currentMinute by remember { mutableStateOf(0) }

    val chineseDateFormat = SimpleDateFormat("yyyy年MM月dd日 HH:mm", Locale.TAIWAN)
    val displayDateStr = remember(currentYear, currentMonth, currentDay, currentHour, currentMinute) {
        val c = Calendar.getInstance().apply {
            set(currentYear, currentMonth, currentDay, currentHour, currentMinute)
        }
        chineseDateFormat.format(c.time)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ParchmentBg)
            .verticalScroll(scrollState)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(12.dp))

        // 頂部小鹿吉祥物與標題
        CuteDeerMascot(size = 64.dp)
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "小鹿兒算命",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = ForestMoss
        )
        Text(
            text = "倪海廈《天紀》排盤・吉卜力純淨美學",
            fontSize = 12.sp,
            color = MagicBrass
        )

        Spacer(modifier = Modifier.height(20.dp))

        // 1. 命主姓名輸入區 (字體特別指定為黑色！)
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = ParchmentCard),
            shape = RoundedCornerShape(12.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("命主姓名 / 稱謂", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                    Text("選填", fontSize = 11.sp, color = SoftGray)
                }
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = userName,
                    onValueChange = { userName = it },
                    placeholder = { Text("請輸入您的姓名或暱稱（預設：命主）", color = Color.Gray) },
                    textStyle = TextStyle(color = Color.Black, fontSize = 15.sp, fontWeight = FontWeight.Normal),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.Black,
                        unfocusedTextColor = Color.Black,
                        focusedBorderColor = ForestMoss,
                        unfocusedBorderColor = BorderBrass.copy(alpha = 0.6f),
                        focusedContainerColor = Color.White,
                        unfocusedContainerColor = Color.White
                    ),
                    shape = RoundedCornerShape(8.dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 2. 性別選擇
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Gender.values().forEach { g ->
                val isSelected = (gender == g)
                Button(
                    onClick = { gender = g },
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (isSelected) ForestMoss else ParchmentCard
                    ),
                    shape = RoundedCornerShape(10.dp),
                    border = if (!isSelected) BorderStroke(1.dp, BorderBrass.copy(alpha = 0.5f)) else null
                ) {
                    Text(
                        text = g.label,
                        color = if (isSelected) Color.White else ForestMoss,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 3. 出生日期與時間選擇 (中文格式)
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = ParchmentCard),
            shape = RoundedCornerShape(12.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Text("出生時間（西曆標準時間）", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Spacer(modifier = Modifier.height(8.dp))

                // 點擊彈出 DatePicker
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(Color.White, RoundedCornerShape(8.dp))
                        .border(1.dp, BorderBrass.copy(alpha = 0.6f), RoundedCornerShape(8.dp))
                        .clickable {
                            DatePickerDialog(
                                context,
                                { _, y, m, d ->
                                    currentYear = y
                                    currentMonth = m
                                    currentDay = d
                                },
                                currentYear, currentMonth, currentDay
                            ).show()
                        }
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("日期", fontSize = 14.sp, color = ForestMoss)
                    Text("${currentYear}年${currentMonth + 1}月${currentDay}日", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = CalciferOrange)
                }

                if (!isUnknownHour) {
                    Spacer(modifier = Modifier.height(10.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(Color.White, RoundedCornerShape(8.dp))
                            .border(1.dp, BorderBrass.copy(alpha = 0.6f), RoundedCornerShape(8.dp))
                            .clickable {
                                TimePickerDialog(
                                    context,
                                    { _, h, min ->
                                        currentHour = h
                                        currentMinute = min
                                    },
                                    currentHour, currentMinute, true
                                ).show()
                            }
                            .padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("時間", fontSize = 14.sp, color = ForestMoss)
                        Text(String.format("%02d:%02d", currentHour, currentMinute), fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = CalciferOrange)
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // 不知道出生時間核取方塊
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { isUnknownHour = !isUnknownHour }
                        .padding(vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = isUnknownHour,
                        onCheckedChange = { isUnknownHour = it },
                        colors = CheckboxDefaults.colors(checkedColor = ForestMoss)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "不知道出生時間，以子時（23:00-01:00）起盤",
                        fontSize = 12.sp,
                        color = ForestMoss
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        // 4. 雲端試算表同步狀態卡
        val isConfigured = GoogleSheetsSyncManager.getWebhookUrl(context).isNotBlank()
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable {
                    webhookUrlInput = GoogleSheetsSyncManager.getWebhookUrl(context)
                    isSyncEnabled = GoogleSheetsSyncManager.isEnabled(context)
                    testStatusMessage = null
                    showGoogleSheetsDialog = true
                },
            shape = RoundedCornerShape(10.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.85f)),
            border = BorderStroke(1.dp, if (isConfigured) Color(0xFF2E7D32).copy(alpha = 0.6f) else CalciferOrange.copy(alpha = 0.6f))
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (isConfigured) "🟢" else "⚠️",
                    fontSize = 15.sp
                )
                Spacer(modifier = Modifier.width(8.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = if (isConfigured) "Google 試算表雲端同步：已連線" else "Google 試算表雲端同步：尚未設定",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = ForestMoss
                    )
                    Text(
                        text = if (isConfigured) "排盤時自動在背景將生辰資料記錄至您的專屬試算表" else "點此設定 Web App 網址，排盤時自動備份姓名與生辰",
                        fontSize = 11.sp,
                        color = Color.Gray
                    )
                }
                Text("設定", fontSize = 12.sp, color = MagicBrass, fontWeight = FontWeight.Bold)
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 5. 開啟命盤按鈕
        Button(
            onClick = {
                val cal = Calendar.getInstance().apply {
                    set(currentYear, currentMonth, currentDay, currentHour, currentMinute, 0)
                }
                onGenerateChart(cal.time, gender, userName.ifBlank { "命主" }, isUnknownHour)
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
            colors = ButtonDefaults.buttonColors(containerColor = ForestMoss),
            shape = RoundedCornerShape(12.dp)
        ) {
            Text(
                text = "✨ 開啟小鹿兒天命星盤",
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }

        Spacer(modifier = Modifier.height(16.dp))
    }

    if (showGoogleSheetsDialog) {
        AlertDialog(
            onDismissRequest = { showGoogleSheetsDialog = false },
            title = {
                Text("Google Sheet 雲端同步設定", fontWeight = FontWeight.Bold, color = ForestMoss)
            },
            text = {
                Column(
                    modifier = Modifier.verticalScroll(rememberScrollState()),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Text(
                        text = "將使用者每次排盤輸入的姓名、生日、生辰時辰與日期等資訊，自動記錄至您的專屬 Google 試算表中！",
                        fontSize = 12.sp,
                        color = ForestMoss.copy(alpha = 0.85f),
                        lineHeight = 17.sp
                    )

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { isSyncEnabled = !isSyncEnabled }
                    ) {
                        Checkbox(
                            checked = isSyncEnabled,
                            onCheckedChange = { isSyncEnabled = it },
                            colors = CheckboxDefaults.colors(checkedColor = ForestMoss)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("啟用自動同步至 Google Sheet", fontSize = 13.sp, color = ForestMoss)
                    }

                    OutlinedTextField(
                        value = webhookUrlInput,
                        onValueChange = { webhookUrlInput = it },
                        label = { Text("Web App URL (網頁應用程式網址)", fontSize = 11.sp) },
                        placeholder = { Text("https://script.google.com/macros/s/.../exec", fontSize = 10.sp) },
                        textStyle = TextStyle(color = Color.Black, fontSize = 12.sp),
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.Black,
                            unfocusedTextColor = Color.Black,
                            focusedBorderColor = ForestMoss,
                            unfocusedBorderColor = BorderBrass.copy(alpha = 0.6f)
                        )
                    )

                    if (webhookUrlInput.isNotBlank() && !webhookUrlInput.contains("/exec")) {
                        Text(
                            text = "⚠️ 提醒：正式網址結尾必須為 /exec，請確認是否複製到編輯器或開發網址。",
                            fontSize = 10.5.sp,
                            color = TabooRed
                        )
                    }

                    Button(
                        onClick = {
                            isTesting = true
                            testStatusMessage = null
                            GoogleSheetsSyncManager.testConnection(webhookUrlInput) { success, msg ->
                                isTesting = false
                                testStatusMessage = msg
                            }
                        },
                        enabled = !isTesting && webhookUrlInput.isNotBlank(),
                        colors = ButtonDefaults.buttonColors(containerColor = MagicBrass),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(if (isTesting) "測試連線中..." else "發送測試訊號至試算表", color = Color.White, fontSize = 12.sp)
                    }

                    testStatusMessage?.let { msg ->
                        Text(
                            text = msg,
                            fontSize = 11.sp,
                            color = if (msg.contains("✅") || msg.contains("成功")) Color(0xFF2E7D32) else TabooRed,
                            modifier = Modifier
                                .background(ParchmentCard, RoundedCornerShape(4.dp))
                                .padding(6.dp)
                        )
                    }

                    // 一鍵複製 Apps Script 代碼按鈕
                    OutlinedButton(
                        onClick = {
                            val scriptCode = """
                            // 🦌 小鹿兒算命・Google Sheet 雲端排盤紀錄接收端
                            var SPREADSHEET_ID = ""; // 從試算表內「擴充功能 > Apps Script」開啟者留空即可

                            function getTargetSheet() {
                              var ss = (SPREADSHEET_ID && SPREADSHEET_ID.trim() !== "") ? 
                                SpreadsheetApp.openById(SPREADSHEET_ID.trim()) : 
                                SpreadsheetApp.getActiveSpreadsheet();
                              if (!ss) throw new Error("找不到試算表！請確認本腳本從試算表內開啟。");
                              return ss.getActiveSheet();
                            }

                            function doPost(e) {
                              try {
                                var sheet = getTargetSheet();
                                if (sheet.getLastRow() === 0) {
                                  sheet.appendRow(["輸入時間","命主姓名","性別","國曆出生日期","出生時辰","時辰是否未知","農曆生辰","四柱八字","五行局","命主星","身主星","來源平台"]);
                                  sheet.getRange(1, 1, 1, 12).setFontWeight("bold").setBackground("#D1E7DD");
                                }
                                var data = {};
                                if (e && e.postData && e.postData.contents) {
                                  try { data = JSON.parse(e.postData.contents); } catch(err) { data = e.parameter || {}; }
                                } else if (e && e.parameter) { data = e.parameter; }
                                sheet.appendRow([
                                  data.timestamp || Utilities.formatDate(new Date(), "Asia/Taipei", "yyyy/MM/dd HH:mm:ss"),
                                  data.userName || "命主", data.gender || "-", data.solarBirthDate || "-",
                                  data.birthTime || "-", data.isUnknownHour || "-", data.lunarBirthDate || "-",
                                  data.baZi || "-", data.elementBureau || "-", data.lifeMaster || "-",
                                  data.bodyMaster || "-", data.platform || "Android App"
                                ]);
                                return ContentService.createTextOutput(JSON.stringify({ status: "success" })).setMimeType(ContentService.MimeType.JSON);
                              } catch(err) {
                                return ContentService.createTextOutput(JSON.stringify({ status: "error", message: err.toString() })).setMimeType(ContentService.MimeType.JSON);
                              }
                            }

                            function doGet(e) {
                              try {
                                var sheet = getTargetSheet();
                                return ContentService.createTextOutput("✅ 小鹿兒 Google Sheet 雲端接收端運作正常！\n綁定試算表：" + sheet.getParent().getName());
                              } catch(err) {
                                return ContentService.createTextOutput("⚠️ 警告：未綁定試算表！" + err.toString());
                              }
                            }
                            """.trimIndent()

                            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                            val clip = ClipData.newPlainText("AppsScriptCode", scriptCode)
                            clipboard.setPrimaryClip(clip)
                            Toast.makeText(context, "✅ 已複製 Apps Script 接收代碼！", Toast.LENGTH_SHORT).show()
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("📋 一鍵複製 Apps Script 接收代碼", fontSize = 11.5.sp, color = ForestMoss)
                    }

                    Text(
                        text = "📖 4 步驟設定：\n1. Google 試算表 >「擴充功能」>「Apps Script」\n2. 清空貼上代碼並儲存\n3. 點選「部署」>「新增部署作業」>「網頁應用程式」\n4. 執行身分選「我」，存取權限務必選「所有人 (Anyone)」，將 /exec 網址貼在上方！",
                        fontSize = 11.sp,
                        color = ForestMoss.copy(alpha = 0.8f),
                        lineHeight = 15.sp,
                        modifier = Modifier
                            .background(Color.White.copy(alpha = 0.6f), RoundedCornerShape(6.dp))
                            .padding(8.dp)
                    )
                }
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        GoogleSheetsSyncManager.setWebhookUrl(context, webhookUrlInput)
                        GoogleSheetsSyncManager.setEnabled(context, isSyncEnabled)
                        showGoogleSheetsDialog = false
                    }
                ) {
                    Text("儲存", fontWeight = FontWeight.Bold, color = ForestMoss)
                }
            },
            dismissButton = {
                TextButton(onClick = { showGoogleSheetsDialog = false }) {
                    Text("取消", color = Color.Gray)
                }
            },
            containerColor = ParchmentBg
        )
    }
            containerColor = ParchmentBg
        )
    }
}
