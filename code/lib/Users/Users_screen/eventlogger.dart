import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EventLogger {
  static late File _file;
  static const int maxFileSize = 3072; // 3 KB

  static Future<void> init() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      _file = File('${directory.path}/logs.txt');
      if (!await _file.exists()) {
        await _file.create();
      }
    } else {
      print('Directory is null.');
    }
  }

  static void logEvent(Map<String, dynamic> event) {
    String jsonString = jsonEncode(event);
    print(jsonString);
    // write the event to file immediately
    _file.writeAsStringSync('$jsonString\n', mode: FileMode.append);
    _manageFileSize();
  }

  static Future<void> _manageFileSize() async {
    int fileSize = _file.lengthSync();
    print("filesize: $fileSize");
    if (fileSize > maxFileSize) {
      // // Read the last log
      // List<String> logs = await _file.readAsLines();
      // String lastLog = logs.isNotEmpty ? logs.last : '';

      // // Clear the file
      // await _file.writeAsString('');
      // print("\nlog file contents cleared, file was too biggggggggg\n");

      // // Write the last log back to the file
      // await _file.writeAsString(lastLog, mode: FileMode.append);

      _rotateLogs();
    }
  }

  static void _rotateLogs() async {
    // Read the logs
    List<String> logs = await _file.readAsLines();

    // Calculate the total size of the logs
    int totalSize = logs.fold<int>(
        0,
        (previousValue, element) =>
            previousValue + utf8.encode(element).length);

    // Remove logs until the total size is within the limit
    int index = 0;
    while (totalSize > maxFileSize && index < logs.length) {
      totalSize -= utf8.encode(logs[index]).length;
      index++;
    }

    // Retain the latest logs
    List<String> latestLogs = logs.sublist(index);

    // Write the latest logs back to the file
    await _file.writeAsString('${latestLogs.join('\n')}\n');
    print("\nInitial logs overwritten. Latest logs retained.\n");
  }

  static void logLoginWithEmailEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'LoginWithEmail',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logLoginWithOTPEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'LoginWithOTP',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logRegistrationEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'Registration',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logOnboardingEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'Onboarding',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logHomepageEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'Homepage',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logProfileEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'ProfilePage',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logSendersMyOrdersEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'SendersMyOrders',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logSplashScreenEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'SplashScreen',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logChatbotEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'Chatbot',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logOrderSummaryEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'OrderSummaryPage',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logSenderOrderDetailsEvent(String severity, timestamp, user,
      object, eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'SenderOrderDetails',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logPackageDetailsEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'SenderPackageDetails',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logContinueDeliveringEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'ContinueDelivering',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logQRScannerEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'QRScanner',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logScanPackageEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'ScanPackage',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }

  static void logVerifyReceiverOTPEvent(String severity, timestamp, user, object,
      eventType, message, Map<String, dynamic> details) {
    Map<String, dynamic> event = {
      'event_id': 'xxxxx',
      'screen_name': 'VerifyReceiverOTP',
      'severity': severity,
      'timestamp': timestamp,
      'user': user,
      'object': object,
      'event_type': eventType,
      'message': message,
      'details': details,
    };
    logEvent(event);
  }


}
