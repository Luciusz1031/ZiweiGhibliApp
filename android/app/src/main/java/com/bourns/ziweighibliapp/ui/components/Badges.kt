package com.bourns.ziweighibliapp.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bourns.ziweighibliapp.models.TransformationType

@Composable
fun TransformationBadge(type: TransformationType, modifier: Modifier = Modifier) {
    val bgColor = when (type) {
        TransformationType.LU -> Color(0xFF2E7D32) // 祿 (綠)
        TransformationType.QUAN -> Color(0xFFC62828) // 權 (紅)
        TransformationType.KE -> Color(0xFF1565C0) // 科 (藍)
        TransformationType.JI -> Color(0xFF4A148C) // 忌 (紫)
    }

    Text(
        text = type.label,
        color = Color.White,
        fontSize = 10.sp,
        fontWeight = FontWeight.Bold,
        modifier = modifier
            .background(bgColor, RoundedCornerShape(4.dp))
            .padding(horizontal = 4.dp, vertical = 1.dp)
    )
}
