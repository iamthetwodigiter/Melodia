import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/search/model/search_repository.dart';

Future<SearchResult> searchResult(String query) async {
  final response = await http.get(Uri.parse(
      "https://melodia-six.vercel.app/api/search/songs?query=${query.replaceAll(" ", "+")}&limit=50"));
  final data = jsonDecode(response.body);
  List<SongsResult> songsResultList = [];
  // List<AlbumResult> albumResultList = [];
  if (data['success'] == true) {
    try {
      final songsResult = data['data']['results'];
      for (var items in songsResult) {
        final id = items['id'];
        final title = items['name'].replaceAll('&quot;', '');
        final duration = items['duration'].toString();

        var imageUrl = items['image'].last['url'];

        final album = items['album']['name'].replaceAll('&quot;', '');
        final url = items['url'];
        final type = items['type'];
        final artists = items['artists']['primary'];
        List<String> artistsList = [];
        for (var items in artists) {
          artistsList.add(items['name']);
        }
        List<String> downloadUrlList = [];
        for (var links in items['downloadUrl']) {
          downloadUrlList.add(links['url'].toString());
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
        songsResultList.add(songsData);
      }
    } catch (e) {
      rethrow;
    }
    // final albumResults = data['data']['albums']['results'];
    // for (var items in albumResults) {
    //   final id = items['id'];
    //   final title = items['title'];
    //   final imageUrl = items['image'].last['url'];
    //   final url = items['url'];
    //   final type = items['type'];
    //   final artist = items['artist'];

    //   final albumData = AlbumResult(
    //       id: id,
    //       title: title,
    //       imageUrl: imageUrl,
    //       url: url,
    //       type: type,
    //       artist: artist);
    //   albumResultList.add(albumData);
    // }
    return SearchResult(
      songs: songsResultList,
    );
  }
  return SearchResult(songs: []);
}