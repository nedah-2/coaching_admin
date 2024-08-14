import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getAccessToken() async {
  const clientId = 'rOSU1VZCQm2FPBvzTOT9qg';
  const clientSecret = 'kTJFN134txapiXcyDlmMPEwdxlnuSKNv';
  final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

  final response =
      await http.post(Uri.parse('https://zoom.us/oauth/token'), headers: {
    "Content-Type": "application/x-www-form-urlencoded",
    'Authorization': 'Basic $credentials',
  }, body: {
    "grant_type": "account_credentials",
    "account_id": "yYNKxwBkSoWXL1IqX1gc6g",
  });

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body['access_token'];
  } else {
    throw Exception('Failed to get access token');
  }
}

Future<Map<String, String>> scheduleMeeting(
    String topic, String startTime) async {
  const userId = 'me'; // You can also use a specific user ID or email address
  const defaultId = '';
  const defaultPasscode = '';

  final accessToken = await getAccessToken();

  // ignore: prefer_const_declarations
  final url = 'https://api.zoom.us/v2/users/$userId/meetings';

  final body = {
    "topic": topic,
    "type": 2, // Scheduled meeting
    "start_time": startTime, // In ISO 8601 format
    "duration": 90, // Meeting duration in minutes
    "settings": {
      "join_before_host": false,
      "waiting_room": true,
    },
  };

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return {'mid': data['id'], 'passcode': data['password']};
  }

  return {'mid': defaultId, 'passcode': defaultPasscode};
}
