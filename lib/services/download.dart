import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/download_path_provider.dart';
import 'package:melodia/providers/offline_files_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/api_calls.dart';
import 'package:melodia/services/notification_service.dart';
import 'package:melodia/utils/helper_function.dart';

Future<void> downloadSong(
  List<Songs> songsList,
  String quality,
  WidgetRef ref,
) async {
  final Dio dio = Dio();
  final Audiotagger tagger = Audiotagger();

  try {
    final settings = ref.watch(settingsProvider);
    final cacheDirectory =
        Directory('/storage/emulated/0/Music/Melodia/.thumbnails/');
    if (!cacheDirectory.existsSync()) {
      cacheDirectory.createSync();
    }
    final path = ref.watch(downloadPathProvider);
    path.then(
      (downloadDir) async {
        String finalPath = '';
        for (final song in songsList) {
          if (settings!.separatePlaylistFolder) {
            if (Directory('${downloadDir!.path}/${song.albumTitle}/')
                .existsSync()) {
              Directory('${downloadDir.path}/${song.albumTitle}/')
                  .createSync(recursive: true);
            }
            finalPath =
                '${downloadDir.path}/${song.albumTitle}/${song.title}.m4a';
          } else {
            finalPath = '${downloadDir!.path}/${song.title}.m4a';
          }

          await dio.download(
            song.downloadUrl.replaceAll("_320", "_$quality"),
            finalPath,
            onReceiveProgress: (count, total) {
              String progress = formatBytes(count.ceil());
              String maxProgress = formatBytes(total.ceil());
              if (count == total) {
                NotificationService.showInstanceNotification(
                    'Downloading Songs complete', '');
              }
              NotificationService.showInstanceNotification(
                'Downloading ${song.title}',
                '$progress/$maxProgress',
                progress: count.floor(),
                maxProgress: total.floor(),
              );
            },
          );

          final imageFilePath =
              '${cacheDirectory.path}/${song.title}_artwork.jpg';
          if (song.image.isNotEmpty) {
            await dio.download(
              song.image,
              imageFilePath,
            );
          }
          await fetchLyrics(song.id).then((lyrics) async {
            final tag = Tag(
              title: song.title,
              artist: song.artists.map((artist) => artist.name).join(', '),
              albumArtist: song.artists.map((artist) => artist.name).join(', '),
              album: song.albumTitle,
              artwork: imageFilePath,
              trackNumber: (songsList.indexOf(song) + 1).toString(),
              trackTotal: songsList.length.toString(),
              year: song.year,
              lyrics: lyrics,
            );
            await tagger.writeTags(
              path: finalPath,
              tag: tag,
            );
          });
          final filesNotifier = ref.read(filesProvider.notifier);
          await filesNotifier.refreshFiles();
          NotificationService.showInstanceNotification('Download Song complete',
              'Downloading ${song.title} has been completed');
        }
      },
    );
  } catch (e) {
    NotificationService.showInstanceNotification('Error Occured', e.toString());
    throw Exception(e);
  }
}
