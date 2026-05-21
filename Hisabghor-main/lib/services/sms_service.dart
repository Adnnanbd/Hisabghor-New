import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../core/app_constants.dart';
import '../core/formatters.dart';

class SmsResult {
  const SmsResult({
    required this.success,
    required this.message,
    required this.smsText,
  });

  final bool success;
  final String message;
  final String smsText;
}

class SmsService {
  static const _channel = MethodChannel(AppConstants.smsChannelName);

  String dueMessage({
    required String customerName,
    required double dueAmount,
    required String shopName,
    String languageCode = 'bn',
  }) {
    return AppConstants.smsTemplate
        .replaceAll('{name}', customerName)
        .replaceAll('{amount}', Formatters.money(dueAmount, languageCode: languageCode).replaceAll('৳', '').trim())
        .replaceAll('হিসাবঘর', shopName.trim().isEmpty ? AppConstants.defaultShopName : shopName.trim());
  }

  Future<SmsResult> sendDueReminder({
    required String customerName,
    required String phoneNumber,
    required double dueAmount,
    required Map<String, String> settings,
  }) async {
    final shopName = settings['shop_name'] ?? AppConstants.defaultShopName;
    final provider = settings['sms_provider'] ?? 'manual';
    final languageCode = settings['app_language'] ?? 'bn';
    final smsText = dueMessage(
      customerName: customerName,
      dueAmount: dueAmount,
      shopName: shopName,
      languageCode: languageCode,
    );

    if (phoneNumber.trim().isEmpty) {
      await Clipboard.setData(ClipboardData(text: smsText));
      return SmsResult(success: false, message: 'ফোন নম্বর নেই। SMS কপি করা হয়েছে।', smsText: smsText);
    }

    if (provider == 'manual') {
      await Clipboard.setData(ClipboardData(text: smsText));
      return SmsResult(success: true, message: 'SMS কপি করা হয়েছে। মেসেজ অ্যাপে পেস্ট করে পাঠান।', smsText: smsText);
    }

    if (provider == 'device') {
      return _sendDeviceSms(phoneNumber: phoneNumber, message: smsText);
    }

    if (provider == 'sslwireless') {
      return _sendSslWireless(phoneNumber: phoneNumber, message: smsText, settings: settings);
    }

    if (provider == 'bulksmsbd') {
      return _sendBulkSmsBd(phoneNumber: phoneNumber, message: smsText, settings: settings);
    }

    await Clipboard.setData(ClipboardData(text: smsText));
    return SmsResult(success: false, message: 'SMS provider সেট করা নেই। SMS কপি করা হয়েছে।', smsText: smsText);
  }

  Future<SmsResult> _sendDeviceSms({
    required String phoneNumber,
    required String message,
  }) async {
    final permission = await Permission.sms.request();
    if (!permission.isGranted) {
      await Clipboard.setData(ClipboardData(text: message));
      return SmsResult(success: false, message: 'SMS permission পাওয়া যায়নি। SMS কপি করা হয়েছে।', smsText: message);
    }

    try {
      final sent = await _channel.invokeMethod<bool>('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      return SmsResult(
        success: sent ?? false,
        message: sent == true ? 'SMS পাঠানো হয়েছে।' : 'SMS পাঠানো যায়নি।',
        smsText: message,
      );
    } catch (error) {
      debugPrint('SMS send failed: $error');
      await Clipboard.setData(ClipboardData(text: message));
      return SmsResult(success: false, message: 'SMS পাঠাতে সমস্যা হয়েছে। SMS কপি করা হয়েছে।', smsText: message);
    }
  }

  Future<SmsResult> _sendSslWireless({
    required String phoneNumber,
    required String message,
    required Map<String, String> settings,
  }) async {
    final endpoint = settings['ssl_endpoint']?.trim().isNotEmpty == true
        ? settings['ssl_endpoint']!.trim()
        : 'https://smsplus.sslwireless.com/api/v3/send-sms';
    final apiToken = settings['ssl_api_token'] ?? '';
    final sid = settings['ssl_sid'] ?? '';
    if (apiToken.isEmpty || sid.isEmpty) {
      await Clipboard.setData(ClipboardData(text: message));
      return SmsResult(success: false, message: 'SSL Wireless API তথ্য অসম্পূর্ণ। SMS কপি করা হয়েছে।', smsText: message);
    }

    return _postSms(
      endpoint: endpoint,
      body: {
        'api_token': apiToken,
        'sid': sid,
        'msisdn': phoneNumber,
        'sms': message,
        'csms_id': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      successMessage: 'SSL Wireless দিয়ে SMS পাঠানো হয়েছে।',
      smsText: message,
    );
  }

  Future<SmsResult> _sendBulkSmsBd({
    required String phoneNumber,
    required String message,
    required Map<String, String> settings,
  }) async {
    final endpoint = settings['bulksmsbd_endpoint']?.trim().isNotEmpty == true
        ? settings['bulksmsbd_endpoint']!.trim()
        : 'https://bulksmsbd.net/api/smsapi';
    final apiKey = settings['bulksmsbd_api_key'] ?? '';
    final senderId = settings['bulksmsbd_sender_id'] ?? '';
    if (apiKey.isEmpty || senderId.isEmpty) {
      await Clipboard.setData(ClipboardData(text: message));
      return SmsResult(success: false, message: 'BulkSMSBD API তথ্য অসম্পূর্ণ। SMS কপি করা হয়েছে।', smsText: message);
    }

    return _postSms(
      endpoint: endpoint,
      body: {
        'api_key': apiKey,
        'senderid': senderId,
        'number': phoneNumber,
        'message': message,
        'type': 'unicode',
      },
      successMessage: 'BulkSMSBD দিয়ে SMS পাঠানো হয়েছে।',
      smsText: message,
    );
  }

  Future<SmsResult> _postSms({
    required String endpoint,
    required Map<String, String> body,
    required String successMessage,
    required String smsText,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'},
            body: body,
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SmsResult(success: true, message: successMessage, smsText: smsText);
      }
      debugPrint('SMS API response ${response.statusCode}: ${utf8.decode(response.bodyBytes)}');
    } catch (error) {
      debugPrint('SMS API error: $error');
    }
    await Clipboard.setData(ClipboardData(text: smsText));
    return SmsResult(success: false, message: 'API SMS পাঠানো যায়নি। SMS কপি করা হয়েছে।', smsText: smsText);
  }
}
