import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/constants/constants.dart';

Future<String> searchLyrics(String id) async {
  final response = await http
      .get(Uri.parse('${Constants.lyricsUrl}$id/lyrics'));
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data['data']['lyrics'].replaceAll('<br>', '\n').toUpperCase();
  } else if(data['success'] == false) {
    return 'No lyrics found';
  }
  return '';
}
