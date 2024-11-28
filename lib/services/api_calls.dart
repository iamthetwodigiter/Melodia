import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:melodia/models/albums_model.dart';
import 'package:melodia/models/homepage_model.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/search_result_model.dart';
import 'package:melodia/models/songs_model.dart';

const homepageUrl =
    'https://www.jiosaavn.com//api.php?__call=content.getHomepageData';
const albumAPI = "https://melodia-six.vercel.app/api/albums?id=";
const playlistAPI = "https://melodia-six.vercel.app/api/playlists?id=";
const lyricsAPI = "https://melodia-six.vercel.app/api/songs";
const suggestionAPI = "https://melodia-six.vercel.app/api/songs";
const searchAPI = "https://melodia-six.vercel.app/api/search?query=";
const songAPI = "https://melodia-six.vercel.app/api/songs";
const repositoryURL =
    'https://api.github.com/repos/iamthetwodigiter/melodia/releases/latest';

Future<HomePageModel> homePageData() async {
  final response = await http.get(Uri.parse(homepageUrl));
  final data = jsonDecode(response.body);

  return HomePageModel.fromMap(data);
}

Future<Albums> albumsData(String albumID) async {
  final response = await http.get(Uri.parse('$albumAPI$albumID'));
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return Albums.fromMap(data['data']);
  }
  return Albums(
    id: '',
    title: '',
    type: '',
    year: 0,
    language: '',
    explicitContent: false,
    url: '',
    songCount: 0,
    artists: [],
    image: '',
    songs: [],
  );
}

Future<Playlists> playlistsData(String playlistID) async {
  final response = await http.get(Uri.parse('$playlistAPI$playlistID'));
  final data = jsonDecode(response.body);

  if (data['success'] == true) {
    return Playlists.fromMap(data['data']);
  }
  return Playlists(
    id: '',
    title: '',
    type: '',
    year: 0,
    language: '',
    explicitContent: false,
    url: '',
    songCount: 0,
    artists: [],
    image: '',
    songs: [],
  );
}

Future<String> fetchLyrics(String id) async {
  final response = await http.get(Uri.parse('$lyricsAPI/$id/lyrics'));
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return data['data']['lyrics'].replaceAll('<br>', '\n').toUpperCase();
  } else if (data['success'] == false) {
    return 'No lyrics found';
  }
  return '';
}

Future<List<Songs>> getSuggestions(String songID) async {
  final response = await http.get(
    Uri.parse('$suggestionAPI/$songID/suggestions?limit=100'),
  );
  final data = jsonDecode(response.body);
  if (data['success'] == true && data['data'] != null) {
    return List<Songs>.from(
      data['data'].map((song) => Songs.fromMap(song)),
    );
  } else {
    return [];
  }
}

Future<SearchResult> searchResults(String query, int quality) async {
  final response =
      await http.get(Uri.parse('$searchAPI${query.replaceAll(" ", "+")}'));
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return SearchResult.fromMap(data['data']);
  } else {
    return SearchResult(
      searchResultSongs: [],
      searchResultAlbums: [],
      searchResultPlaylists: [],
    );
  }
}

Future<Songs> getSong(String songID) async {
  final response = await http.get(Uri.parse('$songAPI/$songID'));
  final data = jsonDecode(response.body);
  if (data['success'] == true) {
    return Songs.fromMap(data['data'][0]);
  } else {
    return Songs(
      id: '',
      title: '',
      type: '',
      year: '',
      duration: 0,
      explicitContent: false,
      language: '',
      hasLyrics: false,
      image: '',
      downloadUrl: '',
      artists: [],
      albumTitle: '',
    );
  }
}

Future<String> fetchUpdates() async {
  final response = await http.get(Uri.parse(repositoryURL));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['tag_name'];
  } else {
    throw Exception('Failed to fetch latest release');
  }
}
