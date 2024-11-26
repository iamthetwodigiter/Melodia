import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/songs_model.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Songs>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<Songs>> {
  final Box _favoritesBox;

  FavoritesNotifier()
      : _favoritesBox = Hive.box('favorites'),
        super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _favoritesBox.values.cast<Songs>().toList();
  }

  void addFavorite(Songs song) {
    if (!_favoritesBox.containsKey(song.id)) {
      _favoritesBox.put(song.id, song);
      state = [...state, song];
    }
  }

  void removeFavorite(Songs song) {
    if (_favoritesBox.containsKey(song.id)) {
      _favoritesBox.delete(song.id);
      state = state.where((item) => item.id != song.id).toList();
    }
  }

  bool isFavorite(Songs song) {
    return _favoritesBox.containsKey(song.id);
  }
}
