import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/api_calls.dart';

final currentSongsProvider =
    StateProvider.autoDispose.family<Future<List<AudioSource>>, List<Songs>>(
  (ref, playlist) async {
    final settings = ref.watch(settingsProvider);
    final streamingQuality = settings?.streamingQuality ?? 96;
    final suggestionsEnabled = settings?.suggestions ?? false;

    try {
      if (suggestionsEnabled) {
        final currentSongID = playlist.last.id;
        final suggestedSongs = await getSuggestions(currentSongID);

        playlist.addAll(suggestedSongs);
      }

      return playlist.map((song) {
        final currentSong = song.copyWith(
          downloadUrl: song.downloadUrl.replaceAll(
            "_320",
            "_$streamingQuality",
          ),
        );
        return AudioSource.uri(
          Uri.parse(currentSong.downloadUrl),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artists.map((artist) => artist.name).join(", "),
            artUri: Uri.parse(song.image),
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load suggestions: $e');
    }
  },
);
