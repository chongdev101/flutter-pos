package com.chongdev.pos_android

import android.content.ContentResolver
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "security/dev_mode"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDevModeEnabled" -> result.success(isDevModeEnabled())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isDevModeEnabled(): Boolean {
        val resolver: ContentResolver = applicationContext.contentResolver
        val adb = Settings.Global.getInt(resolver, Settings.Global.ADB_ENABLED, 0) == 1
        val devSettings =
            Settings.Global.getInt(resolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1
        return adb || devSettings
    }
}
