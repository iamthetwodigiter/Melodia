import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/search_result_model.dart';
import 'package:melodia/services/api_calls.dart';

class SearchResultNotifier extends StateNotifier<AsyncValue<SearchResult>> {
  SearchResultNotifier(String albumID) : super(const AsyncValue.loading()) {
    loadSearchResult(albumID);
  }

  Future<void> loadSearchResult(String query) async {
    try {
      final data = await searchResults(query);
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final searchResultProvider =
    StateNotifierProvider.family<SearchResultNotifier, AsyncValue<SearchResult>, String>(
  (ref, String query) => SearchResultNotifier(query),
);
