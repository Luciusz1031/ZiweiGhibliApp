package com.bourns.ziweighibliapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.bourns.ziweighibliapp.ui.screens.MainScreen
import com.bourns.ziweighibliapp.ui.theme.ZiweiGhibliAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ZiweiGhibliAppTheme {
                MainScreen()
            }
        }
    }
}
