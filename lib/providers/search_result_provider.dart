import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/search_result_model.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/api_calls.dart';

class SearchResultNotifier extends StateNotifier<AsyncValue<SearchResult>> {
  final String query;
  final int quality;

  SearchResultNotifier(this.query, this.quality)
      : super(const AsyncValue.loading()) {
    loadSearchResult(query, quality);
  }

  Future<void> loadSearchResult(String query, int quality) async {
    try {
      final data = await searchResults(query, quality);
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final searchResultProvider = StateNotifierProvider.family<SearchResultNotifier,
    AsyncValue<SearchResult>, String>(
  (ref, query) {
    final quality = ref.read(settingsProvider)?.ytStreamingQuality ?? 48;
    return SearchResultNotifier(query, quality);
  },
);
