package com.bourns.ziweighibliapp.ui.screens

import android.app.DatePickerDialog
import android.app.TimePickerDialog
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

        Spacer(modifier = Modifier.height(24.dp))

        // 4. 開啟命盤按鈕
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
}
