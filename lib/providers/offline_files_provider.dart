import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/artists_model.dart';
import 'package:melodia/utils/helper_function.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:melodia/models/songs_model.dart';

final filesProvider = StateNotifierProvider<FilesNotifier, List<Songs>>(
  (ref) => FilesNotifier(),
);

class FilesNotifier extends StateNotifier<List<Songs>> {
  List<Songs> songs = [];
  FilesNotifier() : super([]) {
    _loadMusicFiles();
  }

  Future<void> _loadMusicFiles() async {
    try {
      Directory musicDir = Directory('');
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) return;

        musicDir = Directory(
            '${directory.parent.parent.parent.parent.path}/Music/Melodia');
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();

        musicDir = Directory('${directory.path}/Melodia');
      }

      if (musicDir.existsSync()) {
        final tagger = Audiotagger();
        final musicFiles = musicDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) =>
                file.path.endsWith('.m4a') || file.path.endsWith('.mp3'))
            .map((file) => _buildSongFromFile(file.path, tagger));

        songs = await Future.wait(musicFiles);
        state = songs;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Songs> _buildSongFromFile(String filePath, Audiotagger tagger) async {
    final fileSize = File(filePath).statSync().size;
    final tag = await tagger.readTags(path: filePath) ?? Tag();
    final id = Random().nextInt(100000).toString();
    final cacheDirectory = Directory('/storage/emulated/0/Music/Melodia/.thumbnails/');

    final imageFilePath =
        '${cacheDirectory.path}/${filePath.split('/').last.split(".").first}_artwork.jpg';

    return Songs(
      id: (tag.title) ?? id,
      title: tag.title ?? filePath.split('/').last,
      type: tag.lyrics ?? 'No lyrics available',
      year: tag.year ?? '2024',
      duration: 0,
      explicitContent: false,
      language: formatBytes(fileSize),
      hasLyrics: tag.lyrics != null,
      image: imageFilePath,
      downloadUrl: filePath,
      artists: [
        if (tag.artist != null)
          Artists(
            id: '',
            name: tag.artist!,
            role: '',
            images: [],
            type: '',
            url: '',
          )
      ],
      albumTitle: tag.album ?? 'Unknown',
    );
  }

  Future<void> refreshFiles() async {
    await _loadMusicFiles();
  }

  bool isDownloaded(String title) {
    for (final song in songs) {
      if (song.title.contains(title)) {
        return true;
      }
    }
    return false;
  }

  void deleteSong(List<String> filePathList) async {
    try {
      for (final filePath in filePathList) {
        final file = File(filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      await refreshFiles();
      state = List.from(songs);
    } catch (e) {
      throw Exception(e);
    }
  }
}
