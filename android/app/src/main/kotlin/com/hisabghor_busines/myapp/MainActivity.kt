package com.hisabghor_busines.myapp

import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val smsChannel = "hisabghor_business/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsChannel).setMethodCallHandler { call, result ->
            if (call.method != "sendSms") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val phoneNumber = call.argument<String>("phoneNumber")?.trim().orEmpty()
            val message = call.argument<String>("message").orEmpty()
            if (phoneNumber.isEmpty() || message.isEmpty()) {
                result.success(false)
                return@setMethodCallHandler
            }

            try {
                val smsManager = SmsManager.getDefault()
                val parts = smsManager.divideMessage(message)
                smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
                result.success(true)
            } catch (error: Exception) {
                result.error("SMS_SEND_FAILED", error.message, null)
            }
        }
    }
}
