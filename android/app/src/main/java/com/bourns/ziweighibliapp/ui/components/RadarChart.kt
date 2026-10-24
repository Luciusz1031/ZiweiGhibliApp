package com.bourns.ziweighibliapp.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.ui.theme.CalciferOrange
import com.bourns.ziweighibliapp.ui.theme.ForestMoss
import com.bourns.ziweighibliapp.ui.theme.LaputaSky
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun MetisRadarChart(
    data: Map<String, Double>,
    modifier: Modifier = Modifier,
    fillColor: Color = LaputaSky.copy(alpha = 0.35f),
    strokeColor: Color = ForestMoss
) {
    val labels = data.keys.toList()
    val values = data.values.toList()
    val n = labels.size
    if (n < 3) return

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(260.dp),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.size(240.dp)) {
            val center = Offset(size.width / 2f, size.height / 2f)
            val maxRadius = size.width * 0.36f

            // 1. 繪製同心多邊形網格
            val levels = 4
            for (level in 1..levels) {
                val r = maxRadius * (level.toFloat() / levels)
                val gridPath = Path()
                for (i in 0 until n) {
                    val angle = (2 * Math.PI * i / n) - (Math.PI / 2)
                    val x = center.x + (r * cos(angle)).toFloat()
                    val y = center.y + (r * sin(angle)).toFloat()
                    if (i == 0) gridPath.moveTo(x, y) else gridPath.lineTo(x, y)
                }
                gridPath.close()
                drawPath(gridPath, color = Color.Gray.copy(alpha = 0.25f), style = Stroke(width = 1.2f))
            }

            // 2. 繪製軸線
            for (i in 0 until n) {
                val angle = (2 * Math.PI * i / n) - (Math.PI / 2)
                val x = center.x + (maxRadius * cos(angle)).toFloat()
                val y = center.y + (maxRadius * sin(angle)).toFloat()
                drawLine(
                    color = Color.Gray.copy(alpha = 0.3f),
                    start = center,
                    end = Offset(x, y),
                    strokeWidth = 1f
                )
            }

            // 3. 繪製數據多邊形
            val dataPath = Path()
            val points = mutableListOf<Offset>()
            for (i in 0 until n) {
                val score = values[i].coerceIn(0.1, 1.0)
                val r = (maxRadius * score).toFloat()
                val angle = (2 * Math.PI * i / n) - (Math.PI / 2)
                val x = center.x + (r * cos(angle)).toFloat()
                val y = center.y + (r * sin(angle)).toFloat()
                points.add(Offset(x, y))
                if (i == 0) dataPath.moveTo(x, y) else dataPath.lineTo(x, y)
            }
            dataPath.close()
            drawPath(dataPath, color = fillColor)
            drawPath(dataPath, color = strokeColor, style = Stroke(width = 2.5f))

            // 節點小圓圈
            for (pt in points) {
                drawCircle(color = CalciferOrange, radius = 4.5f, center = pt)
                drawCircle(color = Color.White, radius = 2f, center = pt)
            }

            // 4. 繪製文字標籤 (Native Paint)
            val paint = android.graphics.Paint().apply {
                color = android.graphics.Color.parseColor("#2E4F3E")
                textSize = 28f
                isFakeBoldText = true
                textAlign = android.graphics.Paint.Align.CENTER
            }

            for (i in 0 until n) {
                val label = labels[i]
                val angle = (2 * Math.PI * i / n) - (Math.PI / 2)
                val labelRadius = maxRadius + 32f
                val lx = center.x + (labelRadius * cos(angle)).toFloat()
                val ly = center.y + (labelRadius * sin(angle)).toFloat() + 10f
                drawContext.canvas.nativeCanvas.drawText(label, lx, ly, paint)
            }
        }
    }
}
