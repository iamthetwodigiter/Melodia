import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';

final playingQueueProvider = StateNotifierProvider<PlayingQueueNotifier, List<Songs>>(
  (ref) => PlayingQueueNotifier(),
);

class PlayingQueueNotifier extends StateNotifier<List<Songs>> {
  PlayingQueueNotifier() : super([]);

  void addAll(List<Songs> songs) {
    state = [...state, ...songs];
  }

  void add(Songs song) {
    state = [...state, song];
  }

  void remove(Songs song) {
    state = state.where((item) => item != song).toList();
  }

  void clear() {
    state = [];
  }

  void move(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length || newIndex < 0 || newIndex >= state.length) {
      return;
    }

    final item = state[oldIndex];
    state = List.from(state)..removeAt(oldIndex)..insert(newIndex, item);
  }
}