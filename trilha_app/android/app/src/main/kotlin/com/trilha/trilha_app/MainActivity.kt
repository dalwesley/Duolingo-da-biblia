package com.trilha.trilha_app

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "stway/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Robôs do Firebase Test Lab / relatório de pré-lançamento
                    // do Play marcam o aparelho com esta configuração.
                    "isTestLab" -> result.success(
                        Settings.System.getString(contentResolver, "firebase.test.lab") == "true"
                    )
                    else -> result.notImplemented()
                }
            }
    }
}
