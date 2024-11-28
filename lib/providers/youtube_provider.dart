import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/youtube.dart';

class YouTubeNotifier extends StateNotifier<AsyncValue<List<Songs>>> {
  YouTubeNotifier(String query, Ref ref) : super(const AsyncValue.loading()) {
    loadYouTubeData(query, ref);
  }

  Future<void> loadYouTubeData(String query, Ref ref) async {
    final quality = ref.read(settingsProvider)?.ytStreamingQuality ?? 48;
    try {
      final data = await fetchYTData(query, quality);
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final youtubeProvider = StateNotifierProvider.family<YouTubeNotifier,
    AsyncValue<List<Songs>>, String>(
  (ref, String query) => YouTubeNotifier(query, ref),
);
