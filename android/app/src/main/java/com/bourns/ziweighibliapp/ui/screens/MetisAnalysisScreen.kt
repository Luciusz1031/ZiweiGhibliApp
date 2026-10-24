package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.MetisAnalysisEngine
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.components.MetisRadarChart
import com.bourns.ziweighibliapp.ui.theme.*

@Composable
fun MetisAnalysisScreen(chart: AstrolabeChart) {
    val scrollState = rememberScrollState()
    val reading = MetisAnalysisEngine.analyze(chart)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ParchmentBg)
            .verticalScroll(scrollState)
            .padding(14.dp)
    ) {
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

        // 3. 三大核心白話卡片
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

        // 4. 十大維度白話詳解
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

        Spacer(modifier = Modifier.height(20.dp))
    }
}
