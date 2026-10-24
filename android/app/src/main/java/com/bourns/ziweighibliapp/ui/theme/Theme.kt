package com.bourns.ziweighibliapp.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColorScheme = lightColorScheme(
    primary = ForestMoss,
    onPrimary = Color.White,
    secondary = LaputaSky,
    onSecondary = Color.White,
    tertiary = CalciferOrange,
    background = ParchmentBg,
    onBackground = TextDark,
    surface = ParchmentCard,
    onSurface = TextDark
)

@Composable
fun ZiweiGhibliAppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        content = content
    )
}
