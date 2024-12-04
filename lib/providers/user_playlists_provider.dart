import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';

final userPlaylistsProvider =
    StateNotifierProvider<UserPlaylistsNotifier, List<Playlists>>((ref) {
  return UserPlaylistsNotifier();
});

class UserPlaylistsNotifier extends StateNotifier<List<Playlists>> {
  final Box _playlistsBox;

  UserPlaylistsNotifier()
      : _playlistsBox = Hive.box('playlists'),
        super([]) {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    state = _playlistsBox.values.cast<Playlists>().toList();
  }

  void addPlaylist(Playlists playlist) {
    if (!_playlistsBox.containsKey(playlist.id)) {
      _playlistsBox.put(playlist.id, playlist);
      state = [...state, playlist];
    }
  }

  void removePlaylist(Playlists playlist) {
    if (_playlistsBox.containsKey(playlist.id)) {
      _playlistsBox.delete(playlist.id);
      state = state.where((item) => item.id != playlist.id).toList();
    }
  }

  bool addSongToPlaylist(Playlists playlist, Songs song) {
    final existingPlaylist = _playlistsBox.get(playlist.id) as Playlists?;

    if (existingPlaylist != null && !existingPlaylist.songs.contains(song)) {
      final updatedSongs = List<Songs>.from(existingPlaylist.songs)..add(song);

      int songsCount = existingPlaylist.songCount! + 1;
      final updatedPlaylist = existingPlaylist.copyWith(
        songs: updatedSongs,
        songCount: songsCount,
      );

      _playlistsBox.put(playlist.id, updatedPlaylist);

      state = [
        for (final item in state)
          if (item.id == playlist.id) updatedPlaylist else item
      ];
      return true;
    }
    return false;
  }

  void removeSongFromPlaylist(Playlists playlist, Songs song) {
    final existingPlaylist = _playlistsBox.get(playlist.id) as Playlists?;

    if (existingPlaylist != null && existingPlaylist.songs.contains(song)) {
      final updatedSongs = List<Songs>.from(existingPlaylist.songs)
        ..removeWhere((item) => item.id == song.id);

      int songsCount = existingPlaylist.songCount! - 1;
      final updatedPlaylist = existingPlaylist.copyWith(
        songs: updatedSongs,
        songCount: songsCount,
      );

      _playlistsBox.put(playlist.id, updatedPlaylist);

      state = [
        for (final item in state)
          if (item.id == playlist.id) updatedPlaylist else item
      ];
    }
  }
  
  bool isPlaylistAdded(Playlists playlist) {
    return _playlistsBox.containsKey(playlist.id);
  }
}
