import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/services/api_calls.dart';

class SearchSongDataNotifier extends StateNotifier<AsyncValue<List<Songs>>> {
  SearchSongDataNotifier(String songID) : super(const AsyncValue.loading()) {
    loadSearchSongData(songID);
  }

  Future<void> loadSearchSongData(String songID) async {
    try {
      final song = await getSong(songID);
      final suggestions = await getSuggestions(songID);
      final allSongs = [song, ...suggestions];
      state = AsyncValue.data(allSongs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final searchSongDataProvider = StateNotifierProvider.family<
    SearchSongDataNotifier, AsyncValue<List<Songs>>, String>(
  (ref, String songID) => SearchSongDataNotifier(songID),
);
