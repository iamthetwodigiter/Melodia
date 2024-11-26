import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/songs_model.dart';

final offlineFavoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Songs>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<Songs>> {
  final Box _offlineFavoritesBox;

  FavoritesNotifier()
      : _offlineFavoritesBox = Hive.box('offlineFavorites'),
        super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _offlineFavoritesBox.values.cast<Songs>().toList();
  }

  void addFavorite(Songs song) {
    if (!_offlineFavoritesBox.containsKey(song.id)) {
      _offlineFavoritesBox.put(song.id, song);
      state = [...state, song];
    }
  }

  void removeFavorite(Songs song) {
    if (_offlineFavoritesBox.containsKey(song.id)) {
      _offlineFavoritesBox.delete(song.id);
      state = state.where((item) => item.id != song.id).toList();
    }
  }

  bool isFavorite(Songs song) {
    return _offlineFavoritesBox.containsKey(song.id);
  }
}
