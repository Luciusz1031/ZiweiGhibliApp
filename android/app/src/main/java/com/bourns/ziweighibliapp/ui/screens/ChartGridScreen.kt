package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.TimelineFortuneEngine
import com.bourns.ziweighibliapp.engine.TimelineFortuneReading
import com.bourns.ziweighibliapp.engine.TimelineScope
import com.bourns.ziweighibliapp.models.*
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.components.TransformationBadge
import com.bourns.ziweighibliapp.ui.theme.*
import java.util.Calendar

@Composable
fun ChartGridScreen(chart: AstrolabeChart) {
    val scrollState = rememberScrollState()

    var activeScope by remember { mutableStateOf(TimelineScope.NATAL) }
    var selectedDecadeIndex by remember { mutableStateOf(0) }
    var selectedYear by remember { mutableStateOf(Calendar.getInstance().get(Calendar.YEAR)) }
    var selectedMonth by remember { mutableStateOf(1) }
    var selectedDay by remember { mutableStateOf(1) }
    var selectedBranch by remember { mutableStateOf<EarthlyBranch?>(chart.lifePalaceBranch) }
    var filterMode by remember { mutableStateOf("三合") }

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
            .padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // 1. 頂部時光階層切換標籤 (本命 / 大限 / 流年 / 小限 / 流月 / 流日)
        LazyRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(TimelineScope.values().toList()) { scope ->
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
                    items(((currentY - 2)..(currentY + 6)).toList()) { y ->
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

        // 3. 4x4 天圓地方宮格 (Metis 風格配色，高亮時空焦點宮位)
        AstrolabeGrid4x4(
            chart = chart,
            selectedBranch = selectedBranch,
            highlightedBranch = fortuneReading.highlightedBranch,
            onPalaceClick = { branch -> selectedBranch = branch }
        )

        // 4. 時空運勢白話文深度解析卡片 (核心解決說明問題！)
        TimelineReadingCard(reading = fortuneReading)

        // 5. 底部飛星 / 三合 / 四化 過濾切換列
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            listOf("飛星", "三合", "四化").forEach { filter ->
                val isSel = (filterMode == filter)
                Box(
                    modifier = Modifier
                        .clickable { filterMode = filter }
                        .background(if (isSel) MagicBrass.copy(alpha = 0.15f) else Color.Transparent, RoundedCornerShape(6.dp))
                        .padding(horizontal = 14.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = filter,
                        fontSize = 11.sp,
                        fontWeight = if (isSel) FontWeight.Bold else FontWeight.Medium,
                        color = if (isSel) MagicBrass else ForestMoss.copy(alpha = 0.6f)
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))
    }
}

@Composable
fun AstrolabeGrid4x4(
    chart: AstrolabeChart,
    selectedBranch: EarthlyBranch?,
    highlightedBranch: EarthlyBranch,
    onPalaceClick: (EarthlyBranch) -> Unit
) {
    BoxWithConstraints(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1f)
    ) {
        val totalWidth = maxWidth
        val spacing = 3.dp
        val cellSize = (totalWidth - spacing * 3) / 4f
        val centerSize = cellSize * 2f + spacing

        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(spacing)
        ) {
            // Row 0: 巳, 午, 未, 申
            Row(
                modifier = Modifier.height(cellSize),
                horizontalArrangement = Arrangement.spacedBy(spacing)
            ) {
                PalaceCell(chart.palace(EarthlyBranch.SI), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                PalaceCell(chart.palace(EarthlyBranch.WU), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                PalaceCell(chart.palace(EarthlyBranch.WEI), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                PalaceCell(chart.palace(EarthlyBranch.SHEN), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
            }

            // Middle 2 Rows (Rows 1 & 2): Left (辰, 卯), Center 2x2, Right (酉, 戌)
            Row(
                modifier = Modifier.height(centerSize),
                horizontalArrangement = Arrangement.spacedBy(spacing)
            ) {
                // 左側直列 (辰, 卯)
                Column(
                    modifier = Modifier.width(cellSize),
                    verticalArrangement = Arrangement.spacedBy(spacing)
                ) {
                    PalaceCell(chart.palace(EarthlyBranch.CHEN), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                    PalaceCell(chart.palace(EarthlyBranch.MAO), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                }

                // 中宮 (2x2 天心儀表)
                MetisCenterHub(chart = chart, modifier = Modifier.size(centerSize))

                // 右側直列 (酉, 戌)
                Column(
                    modifier = Modifier.width(cellSize),
                    verticalArrangement = Arrangement.spacedBy(spacing)
                ) {
                    PalaceCell(chart.palace(EarthlyBranch.YOU), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                    PalaceCell(chart.palace(EarthlyBranch.XU), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                }
            }

            // Row 3: 寅, 丑, 子, 亥
            Row(
                modifier = Modifier.height(cellSize),
                horizontalArrangement = Arrangement.spacedBy(spacing)
            ) {
                PalaceCell(chart.palace(EarthlyBranch.YIN), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                PalaceCell(chart.palace(EarthlyBranch.CHOU), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                PalaceCell(chart.palace(EarthlyBranch.ZI), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
                PalaceCell(chart.palace(EarthlyBranch.HAI), cellSize, selectedBranch, highlightedBranch, onPalaceClick)
            }
        }
    }
}

@Composable
fun PalaceCell(
    palace: PalaceData,
    size: androidx.compose.ui.unit.Dp,
    selectedBranch: EarthlyBranch?,
    highlightedBranch: EarthlyBranch,
    onClick: (EarthlyBranch) -> Unit
) {
    val isFocused = (highlightedBranch == palace.earthlyBranch)
    val isSelected = (selectedBranch == palace.earthlyBranch)

    Box(
        modifier = Modifier
            .size(size)
            .background(ParchmentCard, RoundedCornerShape(6.dp))
            .border(
                width = if (isFocused) 2.2.dp else (if (isSelected) 1.5.dp else 1.dp),
                color = if (isFocused) CalciferOrange else (if (isSelected) MagicBrass else BorderBrass.copy(alpha = 0.4f)),
                shape = RoundedCornerShape(6.dp)
            )
            .clickable { onClick(palace.earthlyBranch) }
            .padding(3.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // 頂部列：宮名 + 命/身徽章 + 大限年齡
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = palace.type.palaceName,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (palace.isLifePalace) SpiritPurple else ForestMoss
                    )
                    if (palace.isLifePalace) {
                        Spacer(modifier = Modifier.width(2.dp))
                        Text(
                            text = "命",
                            fontSize = 7.sp,
                            color = Color.White,
                            modifier = Modifier
                                .background(SpiritPurple, CircleShape)
                                .padding(horizontal = 2.dp, vertical = 0.5.dp)
                        )
                    }
                }
                Text(
                    text = "${palace.decadeStartAge}-${palace.decadeEndAge}",
                    fontSize = 8.sp,
                    color = MagicBrass
                )
            }

            // 中間：主星與四化展示
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(1.dp)
            ) {
                palace.majorStars.take(2).forEach { star ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(1.dp)
                    ) {
                        Text(
                            text = star.name,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            color = ForestMoss
                        )
                        star.brightness?.let { b ->
                            Text(b.label, fontSize = 7.sp, color = MagicBrass)
                        }
                        star.natalTransformation?.let { tf ->
                            TransformationBadge(type = tf)
                        }
                    }
                }
                if (palace.majorStars.isEmpty()) {
                    Text("對宮借照", fontSize = 8.sp, color = Color.Gray)
                }
            }

            // 底部列：地支 + 干支
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${palace.heavenlyStem.stemName}${palace.earthlyBranch.branchName}",
                    fontSize = 8.5.sp,
                    color = SoftGray
                )
                if (isFocused) {
                    Text(
                        text = "焦點",
                        fontSize = 7.sp,
                        color = Color.White,
                        modifier = Modifier
                            .background(CalciferOrange, RoundedCornerShape(2.dp))
                            .padding(horizontal = 2.dp, vertical = 0.5.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun MetisCenterHub(chart: AstrolabeChart, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .background(Color.White.copy(alpha = 0.92f), RoundedCornerShape(10.dp))
            .border(1.dp, BorderBrass.copy(alpha = 0.5f), RoundedCornerShape(10.dp))
            .padding(6.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Text(
                text = chart.userName,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                color = ForestMoss
            )
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(chart.gender.label, fontSize = 9.5.sp, color = ForestMoss)
                Text(chart.elementBureau.bureauName, fontSize = 9.5.sp, fontWeight = FontWeight.Bold, color = CalciferOrange)
                if (chart.isUnknownHour) {
                    Text("[子時]", fontSize = 8.5.sp, color = SpiritPurple)
                }
            }
            Text(
                text = chart.lunarInfo.baZiString,
                fontSize = 8.5.sp,
                color = ForestMoss,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Text("命主 ${chart.lifeMasterStar}", fontSize = 8.5.sp, color = SpiritPurple)
                Text("身主 ${chart.bodyMasterStar}", fontSize = 8.5.sp, color = ForestMoss)
            }
        }
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
