package com.example.outvisionxr

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Descarta a splash do sistema imediatamente (Android 12+)
        installSplashScreen().setKeepOnScreenCondition { false }
        super.onCreate(savedInstanceState)
    }
}
