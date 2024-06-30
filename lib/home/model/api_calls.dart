import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/home/model/homepage_repository.dart';

const baseUrl = 'https://www.jiosaavn.com/';
const String endpoint = "__call=content.getHomepageData";
Map<String, String> headers = {
  "ctx": "wap6dot0",
  "api_version": "4",
  "_format": "json",
  "_marker": "0"
};

Future<List<NewAlbums>> getHomePage() async {
  final response =
      await http.get(Uri.parse('$baseUrl/api.php?$endpoint'), headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['new_albums'];
    List<NewAlbums> newAlbumsList = [];
    for (int i = 0; i < data.length; i++) {
      final id = data[i]['albumid'];
      final title = data[i]['title'];
      final image = data[i]['image'];
      final language = data[i]['language'];
      final year = data[i]['year'];
      final artists =
          data[i]['Artist']['music'].map((artist) => artist).toList();
      final newAlbum = NewAlbums(
        id: id,
        title: title,
        image: image,
        language: language,
        year: year,
        artists: artists,
      );
      newAlbumsList.add(newAlbum);
    }
    return newAlbumsList;
  }
  return [
    NewAlbums(id: '', title: '', image: '', language: '', year: '', artists: [])
  ];
}

Future<List<FeaturedPlaylist>> featuredPlaylist() async {
  final response =
      await http.get(Uri.parse('$baseUrl/api.php?$endpoint'), headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['featured_playlists'];
    List<FeaturedPlaylist> featuredList = [];
    for (int i = 0; i < data.length; i++) {
      if(data[i]['perma_url'] == 'https://www.jiosaavn.com/featured/surprise-me/1ZOczFTRyFw_') {
        continue;
      }
      final id = data[i]['listid'];
      final title = data[i]['listname'];
      final image = data[i]['image'];
      final url = data[i]['perma_url'];
      final count = data[i]['count'];
      final newAlbum = FeaturedPlaylist(
        listID: id,
        listname: title,
        image: image,
        count: count,
        permaUrl: url,
      );
      featuredList.add(newAlbum);
    }
    return featuredList;
  }
  return [
    FeaturedPlaylist(
        listID: '', listname: '', count: 0, image: '', permaUrl: '')
  ];
}

Future<List<OtherPlaylists>> getOtherPlaylists() async {
  /*
  List of Playlists = [
    Trending Today,
    Romantic Top 40,
    Hindi 2000s,
    Hindi 1990s,
    Hindi 1980s,
    Hindi 1970s
  ]
  */
  final response =
      await http.get(Uri.parse('$baseUrl/api.php?$endpoint'), headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['charts'];
    List<OtherPlaylists> otherPlaylists = [];
    for (var items in data) {
      final id = items['listid'];
      final name = items['listname'];
      final image = items['image'];
      final otherplaylistdata =
          OtherPlaylists(id: id, name: name, imageUrl: image);
      otherPlaylists.add(otherplaylistdata);
    }
    return otherPlaylists;
  }
  return [OtherPlaylists(id: '', name: '', imageUrl: '')];
}
