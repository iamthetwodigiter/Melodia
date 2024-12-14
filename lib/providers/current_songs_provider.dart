import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/playing_queue_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/services/api_calls.dart';

final currentSongsProvider =
    StateProvider.autoDispose.family<Future<List<AudioSource>>, List<Songs>>(
  (ref, playlist) async {
    final settings = ref.watch(settingsProvider);
    final streamingQuality = settings?.streamingQuality ?? 96;
    final suggestionsEnabled = settings?.suggestions ?? false;
    final playingQueue = ref.read(playingQueueProvider);
    final playingQueueNotifier = ref.read(playingQueueProvider.notifier);
    try {
      if (suggestionsEnabled) {
        final currentSongID = playlist.last.id;
        final suggestedSongs = await getSuggestions(currentSongID);
        final List<Songs> finalPlaylist = playlist + suggestedSongs;
        if (playingQueue.isEmpty ||
            playlist != ref.read(playingQueueProvider)) {
          playingQueueNotifier.clear();
          playingQueueNotifier.addAll(playlist + suggestedSongs);
        }
        return finalPlaylist.map((song) {
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
      } else {
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
      }
    } catch (e) {
      throw Exception('Failed to load suggestions: $e');
    }
  },
);
