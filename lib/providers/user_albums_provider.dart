import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/albums_model.dart';

final userAlbumsProvider =
    StateNotifierProvider<UserAlbumsNotifier, List<Albums>>((ref) {
  return UserAlbumsNotifier();
});

class UserAlbumsNotifier extends StateNotifier<List<Albums>> {
  final Box _albumsBox;

  UserAlbumsNotifier()
      : _albumsBox = Hive.box('albums'),
        super([]) {
    _loadAlbums();
  }

  void _loadAlbums() {
    state = _albumsBox.values.cast<Albums>().toList();
  }

  void addAlbum(Albums album) {
    if (!_albumsBox.containsKey(album.id)) {
      _albumsBox.put(album.id, album);
      state = [...state, album];
    }
  }

  void removeAlbum(Albums album) {
    if (_albumsBox.containsKey(album.id)) {
      _albumsBox.delete(album.id);
      state = state.where((item) => item.id != album.id).toList();
    }
  }

  bool isAlbumAdded(Albums album) {
    return _albumsBox.containsKey(album.id);
  }
}
