package com.bourns.ziweighibliapp.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.engine.ZiweiEngine
import com.bourns.ziweighibliapp.models.AstrolabeChart
import com.bourns.ziweighibliapp.models.Gender
import com.bourns.ziweighibliapp.ui.theme.ForestMoss
import com.bourns.ziweighibliapp.ui.theme.ParchmentBg
import com.bourns.ziweighibliapp.ui.theme.ParchmentCard
import java.util.Date

enum class MainTab(val title: String) {
    METIS("現代白話"),
    VERTICAL_PALACES("直列宮位"),
    SYNASTRY("雙人合盤")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen() {
    var chart by remember { mutableStateOf<AstrolabeChart?>(null) }
    var selectedTab by remember { mutableStateOf(MainTab.METIS) }

    if (chart == null) {
        BirthInputScreen(
            onGenerateChart = { date: Date, gender: Gender, name: String, isUnknown: Boolean ->
                chart = ZiweiEngine.generateChart(
                    birthDate = date,
                    gender = gender,
                    userName = name,
                    isUnknownHour = isUnknown
                )
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
                        label = { Text("現代白話") },
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
                        label = { Text("雙人合盤") },
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
                    MainTab.VERTICAL_PALACES -> VerticalPalaceListScreen(chart!!)
                    MainTab.SYNASTRY -> SynastryScreen(chart!!)
                }
            }
        }
    }
}
