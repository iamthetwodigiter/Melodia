import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';

final offlinePlaylistsProvider =
    StateNotifierProvider<OfflinePlaylistsNotifier, List<Playlists>>((ref) {
  return OfflinePlaylistsNotifier();
});

class OfflinePlaylistsNotifier extends StateNotifier<List<Playlists>> {
  final Box _offlinePlaylistsBox;

  OfflinePlaylistsNotifier()
      : _offlinePlaylistsBox = Hive.box('offlinePlaylists'),
        super([]) {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    state = _offlinePlaylistsBox.values.cast<Playlists>().toList();
  }

  void addPlaylist(Playlists playlist) {
    if (!_offlinePlaylistsBox.containsKey(playlist.id)) {
      _offlinePlaylistsBox.put(playlist.id, playlist);
      state = [...state, playlist];
    }
  }

  void removePlaylist(Playlists playlist) {
    if (_offlinePlaylistsBox.containsKey(playlist.id)) {
      _offlinePlaylistsBox.delete(playlist.id);
      state = state.where((item) => item.id != playlist.id).toList();
    }
  }

  bool addSongToPlaylist(Playlists playlist, Songs song) {
    final existingPlaylist = _offlinePlaylistsBox.get(playlist.id) as Playlists?;

    if (existingPlaylist != null && !existingPlaylist.songs.contains(song)) {
      final updatedSongs = List<Songs>.from(existingPlaylist.songs)..add(song);

      int songsCount = existingPlaylist.songCount! + 1;
      final updatedPlaylist = existingPlaylist.copyWith(
        songs: updatedSongs,
        songCount: songsCount,
      );

      _offlinePlaylistsBox.put(playlist.id, updatedPlaylist);

      state = [
        for (final item in state)
          if (item.id == playlist.id) updatedPlaylist else item
      ];
      return true;
    }
    return false;
  }

  bool isPlaylistAdded(Playlists playlist) {
    return _offlinePlaylistsBox.containsKey(playlist.id);
  }
}
