import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/album/model/albums_repository.dart';

const albumUrl = "https://melodia-six.vercel.app/api/albums?id=";
const playlistUrl = "https://melodia-six.vercel.app/api/playlists?id=";

Future<Albums> fetchAlbumData(String type, String endpoint) async {
  String baseUrl = (type == 'album') ? albumUrl + endpoint : '$playlistUrl$endpoint&limit=50';
  final response = await http.get(Uri.parse(baseUrl));
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    final albumData = data['data'];
    final id = albumData['id'];
    final name = albumData['name'];
    final description = albumData['description'];
    final type = albumData['type'];
    int? year = albumData['year'];
    year ??= 0;
    final url = albumData['url'];
    final songsCount = albumData['songCount'];

    final artists = (type == 'album') ? albumData['artists']['all'] : albumData['artists'];
    List<Artist> artistsList = [];
    for (var items in artists) {
      String imageUrl = items['image'].length == 0 ? '' : items['image'][0]['url'].toString();
      final artistData = Artist(
        id: items['id'],
        name: items['name'],
        imageUrl: imageUrl,
        role: items['role'],
        url: items['url'],
      );

      artistsList.add(artistData);
    }
    final image = albumData['image'][0]['url'].toString().replaceAll('50', '500');
    List<Songs> songs = [];
    for (var songItems in albumData['songs']) {
      List<String> downloadUrlList = [];
      for (var links in songItems['downloadUrl']) {
        downloadUrlList.add(links['url'].toString());
      }
      List<String> artistsList = [];
      for (var singers in songItems['artists']['primary']) {
        artistsList.add(singers['name'].toString());
      }
      final songsData = Songs(
        id: songItems['id'],
        name: songItems['name'],
        type: songItems['type'],
        duration: songItems['duration'].toString(),
        label: songItems['label'],
        url: songItems['url'],
        image: songItems['image'][0]['url'].replaceAll('50', '500'),
        downloadUrl: downloadUrlList,
        artists: artistsList,
      );
      songs.add(songsData);
    }
    return Albums(
      id: id,
      name: name,
      description: description,
      type: type,
      year: year,
      url: url,
      songsCount: songsCount,
      artists: artistsList,
      image: image,
      songs: songs,
    );
  }
  return Albums(
    id: '',
    name: '',
    description: '',
    type: '',
    year: 0,
    url: '',
    songsCount: 0,
    artists: <Artist>[],
    image: '',
    songs: <Songs>[],
  );
}
