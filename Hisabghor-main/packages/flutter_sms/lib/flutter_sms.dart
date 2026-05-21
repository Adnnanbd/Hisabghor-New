import 'dart:async';
import 'package:flutter/services.dart';

/// SMS sending result status
enum SmsStatus { sent, failed, unknown }

/// Represents an SMS message
class SmsMessage {
  final String recipient;
  final String message;

  SmsMessage({required this.recipient, required this.message});
}

/// Send SMS using the native platform plugin
/// 
/// Returns a Future that resolves to a list of SmsStatus values,
/// one for each message sent.
Future<List<SmsStatus>> sendSmsMessages(
  List<SmsMessage> messages, {
  bool directSender = false,
}) async {
  final List<String> recipients = messages.map((m) => m.recipient).toList();
  final List<String> contents = messages.map((m) => m.message).toList();

  try {
    final dynamic result = await MethodChannel('flutter_sms')
        .invokeMethod('sendSMS', {
      'recipients': recipients,
      'message': contents.join('\n'),
      'directSender': directSender,
    });

    // Return success for all messages if the intent was launched successfully
    return List.filled(messages.length, SmsStatus.sent);
  } on PlatformException catch (e) {
    // If there's an error, return failed status for all messages
    return List.filled(messages.length, SmsStatus.failed);
  }
}

/// Simple helper to send a single SMS message
Future<SmsStatus> sendSms(String recipient, String message,
    {bool directSender = false}) async {
  final results = await sendSmsMessages(
    [SmsMessage(recipient: recipient, message: message)],
    directSender: directSender,
  );
  return results.first;
}
