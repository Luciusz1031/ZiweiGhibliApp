package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.MetisAnalysisEngine
import com.bourns.ziweighibliapp.engine.MetisDimensionDetail
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.components.MetisRadarChart
import com.bourns.ziweighibliapp.ui.theme.*

@Composable
fun MetisAnalysisScreen(chart: AstrolabeChart) {
    val scrollState = rememberScrollState()
    val reading = remember(chart) { MetisAnalysisEngine.analyze(chart) }
    var selectedTab by remember { mutableStateOf("命格總覽") }

    val dimensionTabs = listOf(
        "命格總覽", "財富", "事業", "感情", "性格", "健康", "人際貴人", "田宅", "婚戀", "父母長輩"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ParchmentBg)
    ) {
        // 頂部維度切換標籤欄 (水平滑動)
        LazyRow(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp, horizontal = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(dimensionTabs) { tab ->
                val isSelected = (selectedTab == tab)
                Box(
                    modifier = Modifier
                        .background(
                            if (isSelected) ForestMoss else ParchmentCard,
                            RoundedCornerShape(14.dp)
                        )
                        .border(
                            1.dp,
                            if (isSelected) MagicBrass else BorderBrass.copy(alpha = 0.5f),
                            RoundedCornerShape(14.dp)
                        )
                        .clickable { selectedTab = tab }
                        .padding(horizontal = 14.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = tab,
                        fontSize = 12.5.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                        color = if (isSelected) Color.White else ForestMoss
                    )
                }
            }
        }

        // 內容滾動區
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(horizontal = 14.dp)
        ) {
            if (selectedTab == "命格總覽") {
                // 1. 命主標頭與白話總綱卡片
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "命主：${chart.userName}",
                                fontSize = 17.sp,
                                fontWeight = FontWeight.Bold,
                                color = ForestMoss
                            )
                            if (chart.isUnknownHour) {
                                Text(
                                    text = "[時辰基準：子時]",
                                    fontSize = 11.sp,
                                    color = CalciferOrange
                                )
                            }
                        }
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = reading.oneSentenceHeadline,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Medium,
                            color = ForestMoss,
                            lineHeight = 20.sp
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = chart.lunarInfo.lunarDateString,
                            fontSize = 11.sp,
                            color = MagicBrass
                        )
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // 2. 六維雷達圖
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "🌟 六維天命能量雷達",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = ForestMoss
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        MetisRadarChart(data = reading.dimensionScores)
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // 3. 九大子頁面捷徑入口卡片
                Text(
                    text = "📂 九大維度子頁面解析",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = ForestMoss
                )
                Spacer(modifier = Modifier.height(8.dp))

                val subTabs = listOf("財富", "事業", "感情", "性格", "健康", "人際貴人", "田宅", "婚戀", "父母長輩")
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    for (i in subTabs.indices step 2) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            val tab1 = subTabs[i]
                            val detail1 = reading.dimensionDetails[tab1]
                            Card(
                                modifier = Modifier
                                    .weight(1f)
                                    .clickable { selectedTab = tab1 },
                                colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                                shape = RoundedCornerShape(10.dp)
                            ) {
                                Column(modifier = Modifier.padding(10.dp)) {
                                    Text(tab1, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                                    detail1?.let {
                                        Text("${it.score}分・${it.palaceName}", fontSize = 10.sp, color = Color.Gray)
                                    }
                                }
                            }

                            if (i + 1 < subTabs.size) {
                                val tab2 = subTabs[i + 1]
                                val detail2 = reading.dimensionDetails[tab2]
                                Card(
                                    modifier = Modifier
                                        .weight(1f)
                                    .clickable { selectedTab = tab2 },
                                    colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                                    shape = RoundedCornerShape(10.dp)
                                ) {
                                    Column(modifier = Modifier.padding(10.dp)) {
                                        Text(tab2, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                                        detail2?.let {
                                            Text("${it.score}分・${it.palaceName}", fontSize = 10.sp, color = Color.Gray)
                                        }
                                    }
                                }
                            } else {
                                Spacer(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // 4. 三大核心白話卡片
                Text(
                    text = "🔮 三大核心天命指引",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = ForestMoss
                )
                Spacer(modifier = Modifier.height(8.dp))

                reading.threeCoreCards.forEach { card ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(card.title, fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                                Text(
                                    text = card.tag,
                                    fontSize = 10.sp,
                                    color = Color.White,
                                    modifier = Modifier
                                        .background(SpiritPurple, RoundedCornerShape(4.dp))
                                        .padding(horizontal = 6.dp, vertical = 2.dp)
                                )
                            }
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(card.description, fontSize = 12.sp, color = TextDark, lineHeight = 18.sp)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // 5. 十大維度詳解
                Text(
                    text = "📜 人生十象專屬解說",
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = ForestMoss
                )
                Spacer(modifier = Modifier.height(8.dp))

                reading.tenDimensions.forEach { dim ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 3.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.85f)),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(10.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text(dim.dimensionName, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(dim.rating, fontSize = 10.sp, color = CalciferOrange, fontWeight = FontWeight.Bold)
                                }
                                Spacer(modifier = Modifier.height(2.dp))
                                Text(dim.interpretation, fontSize = 11.5.sp, color = TextDark, lineHeight = 16.sp)
                            }
                            Text("${dim.score}分", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = MagicBrass)
                        }
                    }
                }
            } else {
                // 專屬維度子頁面
                val detail = reading.dimensionDetails[selectedTab]
                if (detail != null) {
                    DimensionDetailView(detail = detail, onBack = { selectedTab = "命格總覽" })
                }
            }

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
fun DimensionDetailView(detail: MetisDimensionDetail, onBack: () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        // 頭部卡片
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = ParchmentCard),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("【${detail.dimensionName}】專屬命理解析", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                        Text("核心宮位：${detail.palaceName} (${detail.palaceBranchName})", fontSize = 11.sp, color = Color.Gray)
                    }
                    Column(horizontalAlignment = Alignment.End) {
                        Text("${detail.score}分", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = CalciferOrange)
                        Text(detail.ratingText, fontSize = 10.sp, color = ForestMoss)
                    }
                }
                Spacer(modifier = Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("坐鎮星曜：", fontSize = 11.sp, color = Color.Gray)
                    Text(detail.majorStarsDisplay, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = SpiritPurple)
                }
            }
        }

        // 核心定位
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text("✨ 白話核心天命定位", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Spacer(modifier = Modifier.height(6.dp))
                Text(detail.coreEssence, fontSize = 13.sp, color = TextDark, lineHeight = 19.sp)
            }
        }

        // 天賦優勢
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = ParchmentCard),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text("🌟 天賦優勢與順風管道", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Spacer(modifier = Modifier.height(6.dp))
                detail.advantages.forEach { adv ->
                    Text("• $adv", fontSize = 12.sp, color = TextDark, lineHeight = 17.sp, modifier = Modifier.padding(vertical = 2.dp))
                }
            }
        }

        // 盲點避坑
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = CalciferOrange.copy(alpha = 0.08f)),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text("⚠️ 隱形盲點與避坑提醒", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = CalciferOrange)
                Spacer(modifier = Modifier.height(6.dp))
                detail.blindSpots.forEach { bs ->
                    Text("• $bs", fontSize = 12.sp, color = TextDark, lineHeight = 17.sp, modifier = Modifier.padding(vertical = 2.dp))
                }
            }
        }

        // 實戰指引
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = ParchmentCard),
            shape = RoundedCornerShape(12.dp)
        ) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text("🎯 落地實戰行動策略", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Spacer(modifier = Modifier.height(6.dp))
                detail.actionStrategies.forEach { act ->
                    Row(modifier = Modifier.padding(vertical = 2.dp), verticalAlignment = Alignment.Top) {
                        Icon(Icons.Default.Check, contentDescription = null, tint = ForestMoss, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(act, fontSize = 12.sp, color = TextDark, lineHeight = 17.sp)
                    }
                }
            }
        }

        // 小鹿兒對話框
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(LaputaSky.copy(alpha = 0.12f), RoundedCornerShape(12.dp))
                .padding(12.dp),
            verticalAlignment = Alignment.Top
        ) {
            CuteDeerMascot(size = 38.dp)
            Spacer(modifier = Modifier.width(8.dp))
            Column {
                Text("小鹿兒開運錦囊：", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                Text(detail.luckyFawnTips, fontSize = 12.sp, color = ForestMoss, lineHeight = 17.sp)
            }
        }

        // 返回按鈕
        Button(
            onClick = onBack,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = ForestMoss),
            shape = RoundedCornerShape(10.dp)
        ) {
            Icon(Icons.Default.ArrowBack, contentDescription = null, tint = Color.White)
            Spacer(modifier = Modifier.width(6.dp))
            Text("返回命格總覽", color = Color.White)
        }
    }
}
