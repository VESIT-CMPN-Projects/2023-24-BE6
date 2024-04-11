import 'dart:convert';

import 'package:http/http.dart' as http;

String apiKey = "493baded-2128-4268-aa76-5f23d7eafa38";
String accountId = "b3ec58295bd0/cba752d8-cad6-4c0e-9bdb-498e143edd91";

// Future<String> getApiKey() async {
//   print("Loading API_KEY from .env...");
//   await dotenv.load(fileName: ".env");
//   print("API_KEY loaded: ${dotenv.env['API_KEY'] ?? 'Not found'}");
//   return dotenv.env['API_KEY'] ?? "";
// }

// Future<String> getAccountId() async {
//   print("Loading ACCOUNT_ID from .env...");
//   await dotenv.load(fileName: ".env");
//   print("ACCOUNT_ID loaded: ${dotenv.env['ACCOUNT_ID'] ?? 'Not found'}");
//   return dotenv.env['ACCOUNT_ID'] ?? "";
// }

Future<String?> verifyAadhar(String? aadharNumber) async {
// String apiKey = "2b8dc35e-be70-4c8e-8467-85af013e9c3a";
  // String _apiKey = apiKey ;
  // // String accountId = "10cf0f1f391e/901d0c54-81dc-4b34-abf1-85e668f5091b";
  // String _accountId = accountId;

  print(apiKey);
  const url =
      'https://eve.idfy.com/v3/tasks/async/verify_with_source/aadhaar_lite';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'api-key': apiKey,
      'account-id': accountId,
      'Content-Type': 'application/json',
    },
    body: '''
    {
      "task_id": "74f4c926-250c-43ca-9c53-453e87ceacd1",
      "group_id": "8e16424a-58fc-4ba4-ab20-5bc8e7c3c41e",
      "data": {
        "aadhaar_number": "$aadharNumber"
      }
    }
    ''',
  );

  if (response.statusCode == 202) {
    final jsonResponse = json.decode(response.body); // Parse the JSON response
    final requestId = jsonResponse['request_id'];
    final getResult = await getVerificationResult(requestId);
    print('Aadhar verification result: $getResult');

    if (getResult != null) {
      Map<String, dynamic> parsedJson = json.decode(getResult);

      String? status = parsedJson['status'];
      print(status);
      return status;
    }
  } else {
    // Handle the API error here
    print('Aadhar verification failed. Status Code: ${response.statusCode}');
  }
  return null;
}

Future<String?> getVerificationResult(String? requestId) async {
  final headers = {
    'api-key': apiKey,
    'account-id': accountId,
  };

  String? verificationResult;
  bool completed = false;

  while (!completed) {
    final url = 'https://eve.idfy.com/v3/tasks?request_id=$requestId';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final status = jsonResponse[0]['status'];

      if (status == 'completed') {
        // Verification is completed, store the result and exit the loop
        verificationResult = json.encode(jsonResponse[0]);
        completed = true;
      } else if (status == 'failed') {
        print('Verification failed. Response Body: ${response.body}');
        break;
      } else {
        // Verification is still in progress, wait for a while before polling again
        await Future.delayed(
            const Duration(seconds: 5)); // Adjust the delay as needed
      }
    } else {
      // Handle the API error here
      print(
          'Failed to fetch verification result. Status Code: ${response.statusCode}');
      print('Reason: ${response.reasonPhrase}');
      return null;
    }
  }

  return verificationResult;
}

Future<Map<String, String?>> verifyPan(String? panNumber) async {
  // String _apiKey = apiKey;
  // String _accountId = accountId;

  print(apiKey);
  const url =
      'https://eve.idfy.com/v3/tasks/async/verify_with_source/ind_pan_plus';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'api-key': apiKey,
      'account-id': accountId,
      'Content-Type': 'application/json',
    },
    body: '''
    {
      "task_id": "74f4c926-250c-43ca-9c53-453e87ceacd1",
      "group_id": "8e16424a-58fc-4ba4-ab20-5bc8e7c3c41e",
      "data": {
        "id_number": "$panNumber"
      }
    }
    ''',
  );

  if (response.statusCode == 202) {
    final jsonResponse = json.decode(response.body); // Parse the JSON response
    final requestId = jsonResponse['request_id'];
    print('Request_id: $requestId');
    final getResult = await getVerificationResultPan(requestId);
    print('Pan verification result: $getResult');

    if (getResult != null) {
      Map<String, dynamic> parsedJson = json.decode(getResult);

      String? fullName = parsedJson["result"]["source_output"]["full_name"];
      String? maskedAadhaar =
          parsedJson["result"]["source_output"]["masked_aadhaar"];

      return {
        'fullName': fullName,
        'maskedAadhaar': maskedAadhaar,
      };
    }
  } else {
    // Handle the API error here
    print('Aadhar verification failed. Status Code: ${response.statusCode}');
  }

  // Return an empty Map if the function doesn't succeed
  return {};
}

Future<String?> getVerificationResultPan(String requestId) async {
  final headers = {
    'api-key': apiKey,
    'account-id': accountId,
    //String accountId = "10cf0f1f391e/901d0c54-81dc-4b34-abf1-85e668f5091b";
  };

  String? verificationResult;
  bool completed = false;

  while (!completed) {
    final url = 'https://eve.idfy.com/v3/tasks?request_id=$requestId';
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final status = jsonResponse[0]['status'];

      if (status == 'completed') {
        // Verification is completed, store the result and exit the loop
        verificationResult = json.encode(jsonResponse[0]);
        completed = true;
      } else if (status == 'failed') {
        print('Verification failed. Response Body: ${response.body}');
        break;
      } else {
        // Verification is still in progress, wait for a while before polling again
        await Future.delayed(
            const Duration(seconds: 5)); // Adjust the delay as needed
      }
    } else {
      // Handle the API error here
      print(
          'Failed to fetch verification result. Status Code: ${response.statusCode}');
      print('Reason: ${response.reasonPhrase}');
      return null;
    }
  }

  return verificationResult;
}
