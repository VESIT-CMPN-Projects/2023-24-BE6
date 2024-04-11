import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../eventlogger.dart';

class send_receiver_otp {
  String? senderId;
  String? orderId;

  String receiverPhone = '';
  final twilioFlutter = TwilioFlutter(
    accountSid: 'ACd58a3939bdfe7db652ecbc90f159b1d6',
    authToken: 'cc53029e2c5bcadc9952d30ca032e5ba',
    twilioNumber: '+17657222040',
  );
  int hashStringTo6DigitNumber(String input) {
    var bytes = utf8.encode(input); // Encode the input string as bytes
    var digest = sha256.convert(bytes);

    final hashSubstring = digest.toString().substring(0, 6);
    print(hashSubstring);

    final hashedNumber = int.parse(hashSubstring, radix: 16);

    final sixDigitNumber = hashedNumber % 1000000;

    return sixDigitNumber;
  }

  void handleSMSSendResponse(dynamic response) {
    if (response == 201) {
      print('SMS sent successfully!');
      // Log event for OTP sent to receiver successfully
      EventLogger.logVerifyReceiverOTPEvent(
        'low',
        DateTime.now().toString(),
        1,
        'traveler',
        'ReceiverOTPSuccessful',
        'OTP sent to receiver successfully',
        {'senderId': senderId, 'orderId': orderId},
      );
    } else {
      final errorMessage = response.toString();
      print('Failed to send SMS. Error details:  $errorMessage');
      // Log event for failed OTP sending to receiver
      EventLogger.logVerifyReceiverOTPEvent(
        'low',
        DateTime.now().toString(),
        1,
        'traveler',
        'ReceiverOTPFailed',
        'Failed to send OTP to receiver. Error: $errorMessage',
        {'senderId': senderId, 'orderId': orderId},
      );
    }
  }

  Future<String?> sendSMS(String? senderId, String? orderId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(senderId)
          .collection("orders")
          .doc(orderId)
          .get();

      receiverPhone = userDoc['Receiver Phone'];

      print(userDoc);

      DateTime currentDateTime = DateTime.now();
      int currentTimestamp = currentDateTime.millisecondsSinceEpoch;
      String timestamp = currentTimestamp.toString();

      String s = hashStringTo6DigitNumber(orderId! + timestamp).toString();
      final response = await twilioFlutter.sendSMS(
        toNumber: '+91$receiverPhone',
        messageBody: s,
      );

      handleSMSSendResponse(response);
      return s;
    } catch (e) {
      final errorMessage = e.toString();
      print('Error sending SMS: $errorMessage');
      // Log event for failed OTP sending to receiver
      EventLogger.logVerifyReceiverOTPEvent(
        'low',
        DateTime.now().toString(),
        1,
        'traveler',
        'ReceiverOTPFailed',
        'Failed to send OTP to receiver. Error: $errorMessage',
        {'senderId': senderId, 'orderId': orderId},
      );
    }
    return null;
  }
}
