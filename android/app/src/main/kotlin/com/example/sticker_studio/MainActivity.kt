package com.example.sticker_studio

import android.os.Bundle
import com.example.sticker_studio.whatsapp.WhatsAppIntentHandler
import com.example.sticker_studio.work.UrlImportScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UrlImportScheduler.scheduleResume(applicationContext)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WhatsAppIntentHandler.CHANNEL_NAME)
        channel.setMethodCallHandler(WhatsAppIntentHandler(applicationContext) { this })
    }
}
