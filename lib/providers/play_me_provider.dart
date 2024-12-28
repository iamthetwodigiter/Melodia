import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/songs_model.dart';

final playMeProvider =
    StateNotifierProvider<PlayMeNotifier, List<Songs>>((ref) {
  return PlayMeNotifier();
});

class PlayMeNotifier extends StateNotifier<List<Songs>> {
  final Box _playMeBox;

  PlayMeNotifier()
      : _playMeBox = Hive.box<Songs>('playMe'),
        super([]) {
    _loadPlayMe();
  }

  void _loadPlayMe() {
    state = _playMeBox.values.cast<Songs>().toList();
  }

  void addToPlayMe(Songs song) {
    if (!_playMeBox.values.contains(song)) {
      _playMeBox.add(song);
      state = [...state, song];
    }
  }

  void addAllToPlayMe(List<Songs> songsList) {
    _playMeBox.addAll(songsList);
    state = state + songsList;
  }

  void removeFromPlayMe(Songs song) {
    _playMeBox.delete(song);
    state = state.where((item) => item.id != song.id).toList();
  }

  void clearPlayMe() {
    _playMeBox.clear();
    state = [];
  }
}
