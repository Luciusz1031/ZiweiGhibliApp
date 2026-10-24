package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.TimelineFortuneEngine
import com.bourns.ziweighibliapp.engine.TimelineFortuneReading
import com.bourns.ziweighibliapp.engine.TimelineScope
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.models.EarthlyBranch
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.components.TransformationBadge
import com.bourns.ziweighibliapp.ui.theme.*
import java.util.Calendar

@Composable
fun ChartGridScreen(chart: AstrolabeChart) {
    val scrollState = rememberScrollState()

    var activeScope by remember { mutableStateOf(TimelineScope.NATAL) }
    var selectedDecadeIndex by remember { mutableStateOf(0) }
    var selectedYear by remember { mutableStateOf(2026) }
    var selectedMonth by remember { mutableStateOf(1) }
    var selectedDay by remember { mutableStateOf(1) }

    val fortuneReading = remember(chart, activeScope, selectedDecadeIndex, selectedYear, selectedMonth, selectedDay) {
        TimelineFortuneEngine.calculateReading(
            chart = chart,
            scope = activeScope,
            decadeIndex = selectedDecadeIndex,
            selectedYear = selectedYear,
            selectedMonth = selectedMonth,
            selectedDay = selectedDay
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ParchmentBg)
            .verticalScroll(scrollState)
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // 1. 頂部時光階層切換標籤 (本命 / 大限 / 流年 / 小限 / 流月 / 流日)
        LazyRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(TimelineScope.values()) { scope ->
                val isSelected = (activeScope == scope)
                Box(
                    modifier = Modifier
                        .background(
                            if (isSelected) ForestMoss else ParchmentCard,
                            RoundedCornerShape(12.dp)
                        )
                        .border(
                            1.dp,
                            if (isSelected) MagicBrass else BorderBrass.copy(alpha = 0.5f),
                            RoundedCornerShape(12.dp)
                        )
                        .clickable { activeScope = scope }
                        .padding(horizontal = 14.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = scope.label,
                        fontSize = 12.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) Color.White else ForestMoss
                    )
                }
            }
        }

        // 2. 時光二級切換器
        when (activeScope) {
            TimelineScope.NATAL -> {
                Text(
                    text = "當前檢視本命元辰盤・點選周圍宮位可查閱詳細解析",
                    fontSize = 11.5.sp,
                    color = ForestMoss.copy(alpha = 0.8f)
                )
            }
            TimelineScope.DECADE -> {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    itemsIndexed(chart.palaces) { idx, p ->
                        val isSelected = (selectedDecadeIndex == idx)
                        Box(
                            modifier = Modifier
                                .background(if (isSelected) ForestMoss else ParchmentCard, RoundedCornerShape(8.dp))
                                .border(1.dp, if (isSelected) CalciferOrange else BorderBrass.copy(alpha = 0.4f), RoundedCornerShape(8.dp))
                                .clickable { selectedDecadeIndex = idx }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("${p.decadeStartAge}-${p.decadeEndAge}歲", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = if (isSelected) Color.White else ForestMoss)
                                Text(p.type.palaceName, fontSize = 9.sp, color = if (isSelected) Color.White.copy(alpha = 0.8f) else MagicBrass)
                            }
                        }
                    }
                }
            }
            TimelineScope.ANNUAL -> {
                val currentY = Calendar.getInstance().get(Calendar.YEAR)
                LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    items((currentY - 2)..(currentY + 6)) { y ->
                        val isSelected = (selectedYear == y)
                        Box(
                            modifier = Modifier
                                .background(if (isSelected) ForestMoss else ParchmentCard, RoundedCornerShape(8.dp))
                                .border(1.dp, if (isSelected) CalciferOrange else BorderBrass.copy(alpha = 0.4f), RoundedCornerShape(8.dp))
                                .clickable { selectedYear = y }
                                .padding(horizontal = 10.dp, vertical = 5.dp)
                        ) {
                            Text("${y}年", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = if (isSelected) Color.White else ForestMoss)
                        }
                    }
                }
            }
            TimelineScope.MINOR -> {
                Text(
                    text = "小限依生年起算，隨實歲流轉反映個人心境氣候",
                    fontSize = 11.5.sp,
                    color = ForestMoss.copy(alpha = 0.8f)
                )
            }
            TimelineScope.MONTHLY -> {
                val monthNames = arrayOf("", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "臘月")
                LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    items((1..12).toList()) { m ->
                        val isSelected = (selectedMonth == m)
                        Box(
                            modifier = Modifier
                                .background(if (isSelected) ForestMoss else ParchmentCard, RoundedCornerShape(6.dp))
                                .clickable { selectedMonth = m }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text(monthNames[m], fontSize = 11.sp, color = if (isSelected) Color.White else ForestMoss)
                        }
                    }
                }
            }
            TimelineScope.DAILY -> {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    items((1..30).toList()) { d ->
                        val isSelected = (selectedDay == d)
                        Box(
                            modifier = Modifier
                                .background(if (isSelected) ForestMoss else ParchmentCard, RoundedCornerShape(6.dp))
                                .clickable { selectedDay = d }
                                .padding(horizontal = 7.dp, vertical = 4.dp)
                        ) {
                            Text("${d}日", fontSize = 10.5.sp, color = if (isSelected) Color.White else ForestMoss)
                        }
                    }
                }
            }
        }

        // 3. 時空運勢白話文深度解析卡片 (核心解決說明問題！)
        TimelineReadingCard(reading = fortuneReading)

        Spacer(modifier = Modifier.height(20.dp))
    }
}

@Composable
fun TimelineReadingCard(reading: TimelineFortuneReading) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = ParchmentCard),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("【${reading.scope.label}】時空運勢", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = reading.palaceName,
                            fontSize = 11.sp,
                            color = Color.White,
                            modifier = Modifier
                                .background(SpiritPurple, RoundedCornerShape(4.dp))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    Text(reading.currentFocusText, fontSize = 11.sp, color = Color.Gray)
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text("焦點星曜", fontSize = 9.sp, color = MagicBrass)
                    Text(reading.starsDisplay, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = CalciferOrange)
                }
            }

            Divider()

            Text(reading.headline, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
            Text(reading.plainOverview, fontSize = 13.sp, color = TextDark, lineHeight = 19.sp)

            // 機遇
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.8f)),
                shape = RoundedCornerShape(8.dp)
            ) {
                Column(modifier = Modifier.padding(10.dp)) {
                    Text("🌟 時空機遇與利好：", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                    reading.opportunities.forEach { opp ->
                        Text("• $opp", fontSize = 11.5.sp, color = TextDark, modifier = Modifier.padding(vertical = 1.dp))
                    }
                }
            }

            // 避坑
            if (reading.precautions.isNotEmpty()) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = CalciferOrange.copy(alpha = 0.08f)),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Column(modifier = Modifier.padding(10.dp)) {
                        Text("⚠️ 需留意的暗礁與避坑：", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = CalciferOrange)
                        reading.precautions.forEach { pre ->
                            Text("• $pre", fontSize = 11.5.sp, color = TextDark, modifier = Modifier.padding(vertical = 1.dp))
                        }
                    }
                }
            }

            // 小鹿兒叮嚀
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(LaputaSky.copy(alpha = 0.12f), RoundedCornerShape(10.dp))
                    .padding(10.dp),
                verticalAlignment = Alignment.Top
            ) {
                CuteDeerMascot(size = 32.dp)
                Spacer(modifier = Modifier.width(8.dp))
                Text(reading.fawnAdvice, fontSize = 12.sp, color = ForestMoss, lineHeight = 17.sp)
            }
        }
    }
}
