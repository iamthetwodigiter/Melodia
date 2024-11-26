import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/models/songs_model.dart';

final currentOfflineSongsProvider =
    StateProvider.autoDispose.family<List<AudioSource>, List<Songs>>(
  (ref, playlist) {
    return playlist.map((song) {
      final currentSong = song.copyWith(downloadUrl: song.downloadUrl);
      return AudioSource.file(
        currentSong.downloadUrl,
        tag: MediaItem(
          id: song.id,
          title: song.title,
          artist: song.artists.map((artists) => artists.name).join(", "),
          artUri: Uri.parse(song.image),
        ),
      );
    }).toList();
  },
);
