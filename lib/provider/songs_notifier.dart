import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/audio_player.dart';

final currentSongProvider = StateProvider<SongModel?>((ref) => null);

final audioServiceProvider = ChangeNotifierProvider((ref) {
  final currentSong = ref.watch(currentSongProvider);
  if (currentSong != null) {
    return AudioService(song: currentSong);
  } else {
    return null;
  }
});

final isMinimisedProvider = StateProvider<bool>((ref) => false);

// final audioPlayerProvider = Provider<AudioPlayer>((ref) {
//   final player = AudioPlayer();
//   ref.onDispose(() {
//     player.pause();
//     player.dispose();
//   });
//   return player;
// });
