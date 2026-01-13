package com.example.outvisionxr

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "outvisionxr/ar_view",
            ArPlatformViewFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}