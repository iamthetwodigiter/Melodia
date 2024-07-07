import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/constants/constants.dart';

Future<void> sendNotificationToUsers(String message) async {
  String oneSignalApiKey = Constants.oneSignalAPIKEY;
  String oneSignalAppId = Constants.oneSignalAppID;
  String url = 'https://onesignal.com/api/v1/notifications';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Basic $oneSignalApiKey',
  };
  Map<String, dynamic> notification = {
    'app_id': oneSignalAppId,
    'included_segments': ['All'],
    'contents': {'en': message},
  };

  try {
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(notification),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}
