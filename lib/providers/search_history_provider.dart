import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final Box _searchHistoryBox;

  SearchHistoryNotifier()
      : _searchHistoryBox = Hive.box('searchHistory'),
        super([]) {
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    state = _searchHistoryBox.values.cast<String>().toList();
  }

  void addSearchHistory(String query) {
    // removeExtra();
    if (!state.contains(query)) {
      _searchHistoryBox.add(query);
      state = [...state, query];
    }
  }

  void removeSearchHistory(String query) {
    final index = state.indexOf(query);
    if (index != -1) {
      _searchHistoryBox.deleteAt(index);
      state = state.where((item) => item != query).toList();
    }
  }

  // void removeExtra() {
  //   if (state.length >= 3) {
  //     state = state.sublist(0, 2).toList();
  //     _searchHistoryBox.clear();
  //     for (var item in state) {
  //       _searchHistoryBox.add(item);
  //     }
  //   }
  // }
}
