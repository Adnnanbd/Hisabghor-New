package com.example.flutter_sms

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterSmsPlugin */
class FlutterSmsPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_sms")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "sendSMS") {
      val recipients = call.argument<List<String>>("recipients")
      val message = call.argument<String>("message")
      
      if (recipients != null && recipients.isNotEmpty() && message != null) {
        sendSMS(recipients, message, result)
      } else {
        result.error("INVALID_ARGUMENTS", "Recipients and message are required", null)
      }
    } else {
      result.notImplemented()
    }
  }

  private fun sendSMS(recipients: List<String>, message: String, result: Result) {
    try {
      val uriBuilder = Uri.Builder()
        .scheme("sms")
        .appendPath(recipients.first())
        .appendQueryParameter("body", message)
      
      val intent = Intent(Intent.ACTION_SENDTO).apply {
        data = uriBuilder.build()
      }
      
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      context.startActivity(intent)
      result.success("SMS intent launched")
    } catch (e: Exception) {
      result.error("SEND_FAILED", e.message, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
