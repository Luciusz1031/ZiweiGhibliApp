package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.GridOn
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.AstrolabeTextReportGenerator
import com.bourns.ziweighibliapp.engine.GoogleSheetsSyncManager
import com.bourns.ziweighibliapp.engine.ZiweiEngine
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.models.Gender
import com.bourns.ziweighibliapp.ui.theme.ForestMoss
import com.bourns.ziweighibliapp.ui.theme.ParchmentBg
import com.bourns.ziweighibliapp.ui.theme.ParchmentCard
import java.util.Date

enum class MainTab(val title: String) {
    METIS("命盤分析"),
    GRID("星盤總覽"),
    VERTICAL_PALACES("直列宮位"),
    SYNASTRY("合盤分析")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    val context = LocalContext.current
    var chart by remember { mutableStateOf<AstrolabeChart?>(null) }
    var selectedTab by remember { mutableStateOf(MainTab.METIS) }

    if (chart == null) {
        BirthInputScreen(
            onGenerateChart = { date: Date, gender: Gender, name: String, isUnknown: Boolean ->
                val newChart = ZiweiEngine.generateChart(
                    birthDate = date,
                    gender = gender,
                    userName = name,
                    isUnknownHour = isUnknown
                )
                chart = newChart
                // 自動在背景將輸入資料同步至 Google Sheet
                GoogleSheetsSyncManager.syncChart(context, newChart, date, isUnknown)
            }
        )
    } else {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            text = "小鹿兒算命",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = ForestMoss
                        )
                    },
                    actions = {
                        IconButton(onClick = {
                            chart?.let { c ->
                                AstrolabeTextReportGenerator.shareReport(context, c)
                            }
                        }) {
                            Icon(Icons.Default.Share, contentDescription = "分享命盤報告", tint = ForestMoss)
                        }
                        IconButton(onClick = { chart = null }) {
                            Icon(Icons.Default.Refresh, contentDescription = "重新起盤", tint = ForestMoss)
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = ParchmentCard)
                )
            },
            bottomBar = {
                NavigationBar(containerColor = ParchmentCard) {
                    NavigationBarItem(
                        selected = (selectedTab == MainTab.METIS),
                        onClick = { selectedTab = MainTab.METIS },
                        icon = { Icon(Icons.Default.AutoAwesome, contentDescription = null) },
                        label = { Text("命盤分析") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ForestMoss,
                            selectedTextColor = ForestMoss,
                            indicatorColor = ForestMoss.copy(alpha = 0.15f)
                        )
                    )
                    NavigationBarItem(
                        selected = (selectedTab == MainTab.GRID),
                        onClick = { selectedTab = MainTab.GRID },
                        icon = { Icon(Icons.Default.GridOn, contentDescription = null) },
                        label = { Text("星盤總覽") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ForestMoss,
                            selectedTextColor = ForestMoss,
                            indicatorColor = ForestMoss.copy(alpha = 0.15f)
                        )
                    )
                    NavigationBarItem(
                        selected = (selectedTab == MainTab.VERTICAL_PALACES),
                        onClick = { selectedTab = MainTab.VERTICAL_PALACES },
                        icon = { Icon(Icons.Default.List, contentDescription = null) },
                        label = { Text("直列宮位") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ForestMoss,
                            selectedTextColor = ForestMoss,
                            indicatorColor = ForestMoss.copy(alpha = 0.15f)
                        )
                    )
                    NavigationBarItem(
                        selected = (selectedTab == MainTab.SYNASTRY),
                        onClick = { selectedTab = MainTab.SYNASTRY },
                        icon = { Icon(Icons.Default.Favorite, contentDescription = null) },
                        label = { Text("合盤分析") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = ForestMoss,
                            selectedTextColor = ForestMoss,
                            indicatorColor = ForestMoss.copy(alpha = 0.15f)
                        )
                    )
                }
            }
        ) { paddingValues ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .background(ParchmentBg)
            ) {
                when (selectedTab) {
                    MainTab.METIS -> MetisAnalysisScreen(chart!!)
                    MainTab.GRID -> ChartGridScreen(chart!!)
                    MainTab.VERTICAL_PALACES -> VerticalPalaceListScreen(chart!!)
                    MainTab.SYNASTRY -> SynastryScreen(chart!!)
                }
            }
        }
    }
}
