import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/songs_model.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<Songs>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<Songs>> {
  final Box _historyBox;

  HistoryNotifier()
      : _historyBox = Hive.box('history'),
        super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    state = _historyBox.values.cast<Songs>().toList();
  }

  void addHistory(Songs song) {
    if (!_historyBox.values.contains(song)) {
      _historyBox.add(song);
      state = [...state, song];
    }
  }

  void removeHistory(Songs song) {
    _historyBox.delete(song);
    state = state.where((item) => item.id != song.id).toList();
  }

  void clearHistory() {
    _historyBox.clear();
    state = [];
  }
}
