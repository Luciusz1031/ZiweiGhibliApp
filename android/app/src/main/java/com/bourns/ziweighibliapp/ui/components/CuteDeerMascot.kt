package com.bourns.ziweighibliapp.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun CuteDeerMascot(size: Dp = 48.dp, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height

        // 鹿角 (咖啡金)
        val antlerColor = Color(0xFFB8860B)
        drawLine(
            color = antlerColor,
            start = Offset(w * 0.35f, h * 0.35f),
            end = Offset(w * 0.20f, h * 0.12f),
            strokeWidth = w * 0.06f
        )
        drawLine(
            color = antlerColor,
            start = Offset(w * 0.25f, h * 0.22f),
            end = Offset(w * 0.14f, h * 0.22f),
            strokeWidth = w * 0.05f
        )
        drawLine(
            color = antlerColor,
            start = Offset(w * 0.65f, h * 0.35f),
            end = Offset(w * 0.80f, h * 0.12f),
            strokeWidth = w * 0.06f
        )
        drawLine(
            color = antlerColor,
            start = Offset(w * 0.75f, h * 0.22f),
            end = Offset(w * 0.86f, h * 0.22f),
            strokeWidth = w * 0.05f
        )

        // 鹿耳
        val earColor = Color(0xFFC48B5E)
        drawOval(
            color = earColor,
            topLeft = Offset(w * 0.12f, h * 0.30f),
            size = Size(w * 0.22f, h * 0.16f)
        )
        drawOval(
            color = earColor,
            topLeft = Offset(w * 0.66f, h * 0.30f),
            size = Size(w * 0.22f, h * 0.16f)
        )

        // 鹿頭 (溫暖駝棕色)
        val deerBrown = Color(0xFFD2996E)
        drawOval(
            color = deerBrown,
            topLeft = Offset(w * 0.20f, h * 0.32f),
            size = Size(w * 0.60f, h * 0.58f)
        )

        // 圓圓大眼睛 (帶高光)
        drawCircle(color = Color(0xFF221100), radius = w * 0.065f, center = Offset(w * 0.38f, h * 0.54f))
        drawCircle(color = Color.White, radius = w * 0.025f, center = Offset(w * 0.36f, h * 0.52f))
        drawCircle(color = Color(0xFF221100), radius = w * 0.065f, center = Offset(w * 0.62f, h * 0.54f))
        drawCircle(color = Color.White, radius = w * 0.025f, center = Offset(w * 0.60f, h * 0.52f))

        // 粉紅腮紅
        val blushColor = Color(0xFFFF9EA6).copy(alpha = 0.5f)
        drawCircle(color = blushColor, radius = w * 0.07f, center = Offset(w * 0.28f, h * 0.64f))
        drawCircle(color = blushColor, radius = w * 0.07f, center = Offset(w * 0.72f, h * 0.64f))

        // 小鹿黑鼻子
        drawOval(
            color = Color(0xFF332211),
            topLeft = Offset(w * 0.44f, h * 0.64f),
            size = Size(w * 0.12f, h * 0.09f)
        )

        // 微笑嘴型
        drawArc(
            color = Color(0xFF332211),
            startAngle = 0f,
            sweepAngle = 180f,
            useCenter = false,
            topLeft = Offset(w * 0.45f, h * 0.72f),
            size = Size(w * 0.10f, h * 0.08f),
            style = Stroke(width = w * 0.035f)
        )
    }
}
