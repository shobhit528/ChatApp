package com.example.firebase_chat_demo

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    var versionCode: Int? = BuildConfig.VERSION_CODE
    var versionName: String? = BuildConfig.VERSION_NAME

    private var forService: Intent? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        GeneratedPluginRegistrant.registerWith(this);
        forService = Intent(this, MyService::class.java)
        MethodChannel(getFlutterView(), "enableWakeLock").setMethodCallHandler { call, result ->
            if (call.method.equals("startService")) {
                startService()
                result.success("Service started")
            } else if (call.method.equals("stopService")) {
                stopService()
                result.success("Service stopped")
            }else if(call.method.equals("getAppInfo")){
                result.success(mapOf("versionCode" to BuildConfig.VERSION_CODE, "versionName" to BuildConfig.VERSION_NAME));
            }
        }

    }

    fun getFlutterView(): BinaryMessenger? {
        return flutterEngine!!.dartExecutor.binaryMessenger
    }


    private fun startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService)
        } else {
            startService(forService)
        }
    }

    private fun stopService() {
        stopService(forService);
    }
}
