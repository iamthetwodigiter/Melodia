import 'package:melodia/models/artists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<List<Songs>> fetchYTData(String query, int quality) async {
  const int maxResults = 10;
  final yt = YoutubeExplode();

  final searchResults = await yt.search(query, filter: TypeFilters.video);

  List<Songs> songs = [];
  List<Future> futures = [];
  int count = 0;

  try {
    for (var video in searchResults) {
      if (count >= maxResults) break;

      futures.add(_fetchVideoDetails(yt, video, quality, songs));
      count++;
    }

    await Future.wait(futures);

    return songs;
  } catch (e) {
    throw Exception('Error fetching data: $e');
  } finally {
    yt.close();
  }
}

Future<void> _fetchVideoDetails(
    YoutubeExplode yt, Video video, int quality, List<Songs> songs) async {
  try {
    final videoId = video.id.value;
    final title = video.title;
    final author = video.author;
    final thumbnail = video.thumbnails.highResUrl;
    final duration = video.duration?.inSeconds ?? 0;

    final manifest = await yt.videos.streams.getManifest(videoId);
    final audio = manifest.audioOnly.firstWhere(
      (stream) => stream.tag == (quality == 48 ? 139 : 140),
      orElse: () => manifest.audioOnly.first,
    );

    final song = Songs(
      id: videoId,
      title: title,
      type: 'YouTube',
      year: DateTime.now().year.toString(),
      duration: duration,
      explicitContent: false,
      language: 'Unknown',
      hasLyrics: false,
      image: thumbnail,
      downloadUrl: audio.url.toString(),
      artists: [
        Artists(id: '', name: author, role: '', images: [], type: '', url: '')
      ],
      albumTitle: 'YouTube',
     
    );

    songs.add(song);
  } catch (e) {
    throw Exception(
        "Error fetching suggestions for video: ${video.title}. Error: $e");
  }
}

Future<List<Songs>> getSuggestions(Video video, int quality) async {
  final yt = YoutubeExplode();
  List<Songs> songs = [];

  try {
    final suggestions = await yt.videos.getRelatedVideos(video);

    if (suggestions != null) {
      for (var suggestion in suggestions) {
        final suggestionId = suggestion.id.value;
        final title = suggestion.title;
        final author = suggestion.author;
        final thumbnail = suggestion.thumbnails.highResUrl;
        final duration = suggestion.duration?.inSeconds ?? 0;

        final manifest = await yt.videos.streams.getManifest(suggestionId);
        final audio = manifest.audioOnly.firstWhere(
          (stream) => stream.tag == (quality == 48 ? 139 : 140),
          orElse: () => manifest.audioOnly.first,
        );

        final song = Songs(
          id: suggestionId,
          title: title,
          type: 'YouTube',
          year: DateTime.now().year.toString(),
          duration: duration,
          explicitContent: false,
          language: 'Unknown',
          hasLyrics: false,
          image: thumbnail,
          downloadUrl: audio.url.toString(),
          artists: [
            Artists(
                id: '', name: author, role: '', images: [], type: '', url: '')
          ],
          albumTitle: 'YouTube',
        );

        songs.add(song);
      }
    }

    return songs;
  } catch (e) {
    throw Exception('Error fetching suggestions: $e');
  } finally {
    yt.close();
  }
}
