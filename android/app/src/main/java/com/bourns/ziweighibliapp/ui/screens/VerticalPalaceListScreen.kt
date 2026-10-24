package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.PlainLanguageInterpreter
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.models.PalaceData
import com.bourns.ziweighibliapp.ui.components.CuteDeerMascot
import com.bourns.ziweighibliapp.ui.components.TransformationBadge
import com.bourns.ziweighibliapp.ui.theme.*
import kotlinx.coroutines.launch

@Composable
fun VerticalPalaceListScreen(chart: AstrolabeChart) {
    val coroutineScope = rememberCoroutineScope()
    val listState = rememberLazyListState()
    var selectedBranchIndex by remember { mutableStateOf(chart.lifePalaceBranch.index) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(ParchmentBg)
    ) {
        // 1. 頂部水平快速切換快捷導航欄
        LazyRow(
            modifier = Modifier
                .fillMaxWidth()
                .background(ParchmentBg)
                .padding(vertical = 8.dp, horizontal = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            itemsIndexed(chart.palaces) { index, palace ->
                val isSelected = (selectedBranchIndex == palace.earthlyBranch.index)
                Row(
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
                        .clickable {
                            selectedBranchIndex = palace.earthlyBranch.index
                            coroutineScope.launch {
                                listState.animateScrollToItem(index)
                            }
                        }
                        .padding(horizontal = 12.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = palace.type.palaceName,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = if (isSelected) Color.White else ForestMoss
                    )
                    if (palace.isLifePalace) {
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "命",
                            fontSize = 8.sp,
                            color = Color.White,
                            modifier = Modifier
                                .background(SpiritPurple, CircleShape)
                                .padding(horizontal = 4.dp, vertical = 1.dp)
                        )
                    }
                }
            }
        }

        // 2. 直列宮位資訊流
        LazyColumn(
            state = listState,
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            item {
                // 頂部小鹿導覽卡
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        CuteDeerMascot(size = 40.dp)
                        Spacer(modifier = Modifier.width(10.dp))
                        Column {
                            Text("小鹿兒十二宮解說", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = ForestMoss)
                            Text(
                                "點選上方宮位標籤，即可快速滑動至該宮位！每張卡片皆包含大限年齡與白話建議。",
                                fontSize = 11.5.sp,
                                color = TextDark.copy(alpha = 0.8f)
                            )
                        }
                    }
                }
            }

            itemsIndexed(chart.palaces) { _, palace ->
                val interp = PlainLanguageInterpreter.interpret(palace, chart)
                val isSelected = (selectedBranchIndex == palace.earthlyBranch.index)

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { selectedBranchIndex = palace.earthlyBranch.index },
                    colors = CardDefaults.cardColors(containerColor = ParchmentCard),
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(
                        if (isSelected) 2.dp else 1.dp,
                        if (isSelected) CalciferOrange else BorderBrass.copy(alpha = 0.5f)
                    )
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        // 宮位頭部
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    text = palace.type.palaceName,
                                    fontSize = 17.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = ForestMoss
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "(${palace.heavenlyStem.stemName}${palace.earthlyBranch.branchName})",
                                    fontSize = 11.sp,
                                    color = SoftGray
                                )
                                if (palace.isLifePalace) {
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = "本命元辰",
                                        fontSize = 9.sp,
                                        color = Color.White,
                                        modifier = Modifier
                                            .background(SpiritPurple, RoundedCornerShape(4.dp))
                                            .padding(horizontal = 4.dp, vertical = 2.dp)
                                    )
                                }
                            }
                            Text(
                                text = "大限：${palace.decadeStartAge} - ${palace.decadeEndAge} 歲",
                                fontSize = 11.sp,
                                color = MagicBrass,
                                fontWeight = FontWeight.SemiBold
                            )
                        }

                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = interp.lifeTheme,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = ForestMoss
                        )

                        // 主星列
                        if (palace.majorStars.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(6.dp))
                            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                palace.majorStars.forEach { star ->
                                    Row(
                                        modifier = Modifier
                                            .background(Color.White, RoundedCornerShape(6.dp))
                                            .padding(horizontal = 6.dp, vertical = 3.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(star.name, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = SpiritPurple)
                                        star.brightness?.let { b ->
                                            Spacer(modifier = Modifier.width(3.dp))
                                            Text(b.label, fontSize = 9.sp, color = MagicBrass)
                                        }
                                        star.natalTransformation?.let { tf ->
                                            Spacer(modifier = Modifier.width(3.dp))
                                            TransformationBadge(type = tf)
                                        }
                                    }
                                }
                            }
                        }

                        // 星宿特質
                        if (interp.starHighlights.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(6.dp))
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(Color.White.copy(alpha = 0.6f), RoundedCornerShape(6.dp))
                                    .padding(8.dp)
                            ) {
                                interp.starHighlights.forEach { highlight ->
                                    Text(highlight, fontSize = 11.5.sp, color = TextDark, lineHeight = 16.sp)
                                }
                            }
                        }

                        // 四化提醒
                        interp.transformationAdvice?.let { trans ->
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(trans, fontSize = 11.5.sp, color = CalciferOrange, lineHeight = 16.sp)
                        }

                        // 小鹿兒對話框
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(LaputaSky.copy(alpha = 0.12f), RoundedCornerShape(8.dp))
                                .padding(8.dp),
                            verticalAlignment = Alignment.Top
                        ) {
                            CuteDeerMascot(size = 32.dp)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(interp.fawnAdvice, fontSize = 11.5.sp, color = ForestMoss, lineHeight = 16.sp)
                        }
                    }
                }
            }

            item {
                Spacer(modifier = Modifier.height(20.dp))
            }
        }
    }
}
