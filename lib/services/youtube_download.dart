import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/notification_service.dart';
import 'package:melodia/utils/helper_function.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> ytDownload(Songs song, WidgetRef ref) async {
  final yt = YoutubeExplode();
  final tagger = Audiotagger();
  final dio = Dio();
  final ytDownloadQuality = ref.read(settingsProvider)?.ytDownloadQuality ?? 48;
  final cacheDirectory = await getApplicationCacheDirectory();
  final Directory dir = Directory('storage/emulated/0/Music/YouTube');

  if (!dir.existsSync()) {
    dir.createSync();
  }

  try {
    final manifest = await yt.videos.streams.getManifest(song.id);

    final audioStreamInfo = manifest.audioOnly.firstWhere(
      (stream) => stream.tag == (ytDownloadQuality == 48 ? 139 : 140),
      orElse: () => manifest.audioOnly.first,
    );

    final file = ('${dir.path}/${song.title}.m4a');
    await dio.download(
      audioStreamInfo.url.toString(),
      file,
      onReceiveProgress: (count, total) {
        NotificationService.showInstanceNotification(
          'Downloading ${song.title}',
          '${formatBytes(count.ceil())}/${formatBytes(total.ceil())}',
          progress: count.floor(),
          maxProgress: total.floor(),
        );

        if (count == total) {
          NotificationService.showInstanceNotification('Download complete', song.title);
        }
      },
    );

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
    NotificationService.showInstanceNotification('Error Occured',
              e.toString());
    throw Exception(e);
  } finally {
    yt.close();
  }
}
