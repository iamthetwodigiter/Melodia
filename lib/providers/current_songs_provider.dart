import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/settings_provider.dart';

final currentSongsProvider =
    StateProvider.autoDispose.family<List<AudioSource>, List<Songs>>(
  (ref, playlist) {
    final streamingQuality = ref.watch(settingsProvider)?.streamingQuality;

    return playlist.map((song) {
      final currentSong = song.copyWith(
        downloadUrl: song.downloadUrl.replaceAll(
          "_320",
          "_$streamingQuality",
        ),
      );
      return AudioSource.uri(
        Uri.parse(currentSong.downloadUrl),
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
