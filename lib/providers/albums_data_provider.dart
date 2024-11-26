import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/albums_model.dart';
import 'package:melodia/services/api_calls.dart';

class AlbumsDataNotifier extends StateNotifier<AsyncValue<Albums>> {
  AlbumsDataNotifier(String albumID) : super(const AsyncValue.loading()) {
    loadAlbumsData(albumID);
  }

  Future<void> loadAlbumsData(String albumID) async {
    try {
      final data = await albumsData(albumID);
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final albumsDataProvider =
    StateNotifierProvider.family<AlbumsDataNotifier, AsyncValue<Albums>, String>(
  (ref, String albumID) => AlbumsDataNotifier(albumID),
);
