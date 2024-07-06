import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/player/model/offline_song_model.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/audio_player.dart';
import 'package:melodia/provider/offline_audio_player.dart';

final currentSongProvider = StateProvider<SongModel?>((ref) {
  return null;
});

final audioServiceProvider = ChangeNotifierProvider((ref) {
  final currentSong = ref.watch(currentSongProvider);
  if (currentSong != null) {
    return AudioService(song: currentSong);
  } else {
    return null;
  }
});

final offlineSongProvider = StateProvider<OfflineSongModel?>((ref) {
  return null;
});

final offlineAudioServiceProvider = ChangeNotifierProvider((ref) {
  final offlineSong = ref.watch(offlineSongProvider);
  if (offlineSong != null) {
    return OfflineAudioPlayer(song: offlineSong);
  } else {
    return null;
  }
});

final isMinimisedProvider = StateProvider<bool>((ref) => false);

final sleepTimerProvider = StateProvider<Duration>((ref) => Duration.zero);
final remainingTimeProvider = StateProvider<Duration>((ref) => Duration.zero);