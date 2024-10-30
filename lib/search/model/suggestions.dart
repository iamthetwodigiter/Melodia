import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/constants/constants.dart';
import 'package:melodia/search/model/search_repository.dart';

Future<List<SongsResult>> getSuggestions(String songID) async {
  final url = '${Constants.suggeestionUrl}$songID/suggestions?query=limit=50';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<SongsResult> suggestionsList = [];

    if (data['success'] == true) {
      try {
        final suggestions = data['data'];

        for (var items in suggestions) {
          final id = items['id'] ?? '';
          final title = items['name']?.replaceAll('&quot;', '').replaceAll("/", "_") ?? '';
          final duration = items['duration']?.toString() ?? '';

          var imageUrl = items['image']?.last['url'] ?? '';

          final album = items['album']?['name']?.replaceAll('&quot;', '') ?? '';
          final url = items['url'] ?? '';
          final type = items['type'] ?? '';
          final artists = items['artists']?['primary'] ?? [];
          
          List<String> artistsList = [];
          for (var artist in artists) {
            artistsList.add(artist['name'] ?? '');
          }

          List<String> downloadUrlList = [];
          for (var link in items['downloadUrl'] ?? []) {
            downloadUrlList.add(link['url']?.toString() ?? '');
          }

          final songsData = SongsResult(
            id: id,
            title: title,
            duration: duration,
            imageUrl: imageUrl,
            album: album,
            url: url,
            type: type,
            artist: artistsList,
            downloadUrls: downloadUrlList,
          );
          suggestionsList.add(songsData);
        }
      } catch (e) {
        rethrow;
      }
    }
    return suggestionsList;
  }
  return [];
}
