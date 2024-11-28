import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/youtube.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SuggestionsNotifier extends StateNotifier<AsyncValue<List<Songs>>> {
  SuggestionsNotifier(Video video, Ref ref)
      : super(const AsyncValue.loading()) {
    fetchSuggestions(video, ref);
  }

  Future<void> fetchSuggestions(Video video, Ref ref) async {
    final quality = ref.read(settingsProvider)?.ytStreamingQuality ?? 48;
    try {
      final data = await getSuggestions(video, quality);
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final suggestionsProvider = StateNotifierProvider.family<SuggestionsNotifier,
    AsyncValue<List<Songs>>, Video>(
  (ref, video) => SuggestionsNotifier(video, ref),
);
