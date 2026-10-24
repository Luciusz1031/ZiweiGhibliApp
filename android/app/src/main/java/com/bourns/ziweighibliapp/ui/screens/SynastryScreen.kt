package com.bourns.ziweighibliapp.ui.screens

import android.app.DatePickerDialog
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
import com.bourns.ziweighibliapp.engine.SynastryEngine
import com.bourns.ziweighibliapp.engine.ZiweiEngine
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.models.Gender
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.components.MetisRadarChart
import com.bourns.ziweighibliapp.ui.theme.*
import java.util.*

@Composable
fun SynastryScreen(chartA: AstrolabeChart) {
    val context = LocalContext.current
    val scrollState = rememberScrollState()

    var partnerName by remember { mutableStateOf("伴侶") }
    var partnerGender by remember { mutableStateOf(if (chartA.gender.isMale) Gender.FEMALE else Gender.MALE) }
    var partnerYear by remember { mutableStateOf(1985) }
    var partnerMonth by remember { mutableStateOf(Calendar.JUNE) }
    var partnerDay by remember { mutableStateOf(15) }
    var isPartnerUnknownHour by remember { mutableStateOf(true) }

    // 當對象資料變更時，即時重新排盤並生成合盤報告
    val chartB = remember(partnerName, partnerGender, partnerYear, partnerMonth, partnerDay, isPartnerUnknownHour) {
        val cal = Calendar.getInstance().apply {
            set(partnerYear, partnerMonth, partnerDay, 12, 0, 0)
        }
        ZiweiEngine.generateChart(
            birthDate = cal.time,
            gender = partnerGender,
            userName = partnerName.ifBlank { "伴侶" },
            isUnknownHour = isPartnerUnknownHour
        )
    }

    val report = remember(chartA, chartB) {
        SynastryEngine.analyze(chartA, chartB)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ParchmentBg)
            .verticalScroll(scrollState)
            .padding(14.dp)
    ) {
        // 1. 對象資料設定卡片
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = ParchmentCard),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Text("💑 雙人合盤對象設定", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Spacer(modifier = Modifier.height(10.dp))

                // 對象姓名輸入 (黑色字體！)
                OutlinedTextField(
                    value = partnerName,
                    onValueChange = { partnerName = it },
                    label = { Text("對象姓名 / 稱謂", color = ForestMoss) },
                    textStyle = TextStyle(color = Color.Black, fontSize = 14.sp),
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

                Spacer(modifier = Modifier.height(10.dp))

                // 性別選擇
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Gender.values().forEach { g ->
                        val isSelected = (partnerGender == g)
                        Button(
                            onClick = { partnerGender = g },
                            modifier = Modifier.weight(1f),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (isSelected) ForestMoss else Color.White
                            ),
                            shape = RoundedCornerShape(8.dp),
                            border = BorderStroke(1.dp, BorderBrass.copy(alpha = 0.5f))
                        ) {
                            Text(g.label, color = if (isSelected) Color.White else ForestMoss, fontSize = 13.sp)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // 出生日期選擇 (點擊彈出 DatePicker)
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(Color.White, RoundedCornerShape(8.dp))
                        .border(1.dp, BorderBrass.copy(alpha = 0.6f), RoundedCornerShape(8.dp))
                        .clickable {
                            DatePickerDialog(
                                context,
                                { _, y, m, d ->
                                    partnerYear = y
                                    partnerMonth = m
                                    partnerDay = d
                                },
                                partnerYear, partnerMonth, partnerDay
                            ).show()
                        }
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("對象生日", fontSize = 13.sp, color = ForestMoss)
                    Text("${partnerYear}年${partnerMonth + 1}月${partnerDay}日", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = CalciferOrange)
                }
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 2. 合盤總分與評價標題
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("💫 默契契合度指數", fontSize = 14.sp, color = SoftGray)
                Text(
                    text = "${report.overallScore} 分",
                    fontSize = 36.sp,
                    fontWeight = FontWeight.Bold,
                    color = CalciferOrange
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = report.chemistryHeadline,
                    fontSize = 13.5.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = ForestMoss,
                    lineHeight = 20.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 3. 雙人雷達圖
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(
                modifier = Modifier.padding(14.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("📊 五維相處默契分析", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Spacer(modifier = Modifier.height(8.dp))
                MetisRadarChart(data = report.radarScores)
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 4. 小鹿兒合盤建議
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = LaputaSky.copy(alpha = 0.12f)),
            shape = RoundedCornerShape(12.dp)
        ) {
            Row(
                modifier = Modifier.padding(14.dp),
                verticalAlignment = Alignment.Top
            ) {
                CuteDeerMascot(size = 40.dp)
                Spacer(modifier = Modifier.width(10.dp))
                Text(report.deerAdvice, fontSize = 12.5.sp, color = ForestMoss, lineHeight = 18.sp)
            }
        }

        Spacer(modifier = Modifier.height(14.dp))

        // 5. 契合亮點
        Text("✨ 相處最佳亮點", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
        Spacer(modifier = Modifier.height(6.dp))
        report.strengths.forEach { s ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 3.dp),
                colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text(
                    text = "• $s",
                    fontSize = 12.sp,
                    color = TextDark,
                    modifier = Modifier.padding(10.dp),
                    lineHeight = 16.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}
