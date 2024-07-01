import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/player/model/songs_model.dart';

// Player state provider
final isPlayingProvider = StateProvider<bool>((ref) => false);

// Current song provider
final currentSongProvider = StateProvider<SongModel?>((ref) => null);

// // AudioPlayer provider
// final audioPlayerProvider = Provider<AudioPlayer>((ref) {
//   final player = AudioPlayer();
//   ref.onDispose(() {
//     player.pause();
//     player.dispose();
//   });
//   return player;
// });
