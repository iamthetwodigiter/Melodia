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
    if (!_historyBox.containsKey(song.id)) {
      _historyBox.put(song.id, song);
      state = [...state, song];
    }
  }

  void removeHistory(Songs song) {
    if (_historyBox.containsKey(song.id)) {
      _historyBox.delete(song.id);
      state = state.where((item) => item.id != song.id).toList();
    }
  }

  void clearHistory() {
    _historyBox.clear();
    state = [];
  }

  bool isHistory(Songs song) {
    return _historyBox.containsKey(song.id);
  }
}
