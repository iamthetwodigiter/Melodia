import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:dio/dio.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

Future<void> ytDownload(Songs song) async {
  final yt = YoutubeExplode();
  final tagger = Audiotagger();
  final dio = Dio();

  final cacheDirectory = await getApplicationCacheDirectory();
  final Directory dir = Directory('storage/emulated/0/Music/Melodia/YouTube');

  if (!dir.existsSync()) {
    dir.createSync();
  }

  try {
    final manifest = await yt.videos.streams.getManifest(song.id);

    final audioStreamInfo = manifest.audioOnly.first;

    final response = await http.Client()
        .send(http.Request('GET', Uri.parse(audioStreamInfo.url.toString())));

    final file = ('${dir.path}/${song.title}.m4a');
    final sink = File(file).openWrite();

    await response.stream.pipe(sink);

    await sink.flush();
    await sink.close();

    final imageFilePath = '${cacheDirectory.path}/${song.title}_artwork.jpg';
    if (song.image.isNotEmpty) {
      await dio.download(
        song.image,
        imageFilePath,
      );
    }

    final tag = Tag(
      title: song.title,
      artist: song.artists.map((artist) => artist.name).join(', '),
      albumArtist: song.artists.map((artist) => artist.name).join(', '),
      album: song.albumTitle,
      artwork: imageFilePath,
      trackNumber: '1',
      trackTotal: '1',
      year: song.year,
      lyrics: 'No lyrics available',
    );
    await tagger.writeTags(
      path: file,
      tag: tag,
    );
  } catch (e) {
    throw Exception(e);
  } finally {
    yt.close();
  }
}
