import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/services/api_calls.dart';

class PlaylistsNotifier extends StateNotifier<AsyncValue<Playlists>> {
  PlaylistsNotifier(String playlistID) : super(const AsyncValue.loading()) {
    loadPlaylistsData(playlistID);
  }

  Future<void> loadPlaylistsData(String playlistID) async {
  
    try {
      final data = await playlistsData(playlistID);
      
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final playlistsProvider =
    StateNotifierProvider.family<PlaylistsNotifier, AsyncValue<Playlists>, String>(
  (ref, String playlistID) => PlaylistsNotifier(playlistID),
);
