import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/offline_audio_provider.dart';
import 'package:melodia/providers/playing_queue_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/player_screen.dart';
import 'package:melodia/views/offline_player_screen.dart';

class MusicSlab extends ConsumerStatefulWidget {
  const MusicSlab({
    super.key,
  });

  @override
  ConsumerState<MusicSlab> createState() => _MusicSlabState();
}

class _MusicSlabState extends ConsumerState<MusicSlab> {
  Box audioProviderBox = Hive.box('audioProvider');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final playingQueue = ref.watch(playingQueueProvider);

    final audioProvider = ref.watch(audioPlayerProvider);
    final audioPlayerNotifier = ref.watch(audioPlayerProvider.notifier);

    final offlineAudioProvider = ref.watch(offlineAudioPlayerProvider);
    final offlineAudioNotifier = ref.watch(offlineAudioPlayerProvider.notifier);

    final isOnlineSongsPlaying =
        (audioProvider.currentIndex != null || audioProviderBox.isNotEmpty) &&
            !offlineAudioProvider.isPlaying;

    final index = isOnlineSongsPlaying
        ? audioProvider.currentIndex
        : offlineAudioProvider.currentIndex;

    final songsList = isOnlineSongsPlaying
        ? playingQueue.isEmpty
            ? audioProviderBox.get('local')
            : playingQueue
        : offlineAudioNotifier.songsList;

    if (songsList.isNotEmpty) {
      Songs song = songsList.elementAt(index ?? 0);
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => isOnlineSongsPlaying
                  ? PlayerScreen(
                      playlist: playingQueue.isEmpty
                          ? (audioProviderBox.get('local') as List)
                              .cast<Songs>()
                          : playingQueue,
                      initialIndex: index ?? 0,
                      // here fromPlayMe is set to true to avoid loading suggestions
                      fromPlayMe: true,
                    )
                  : OfflinePlayerScreen(
                      playlist: songsList,
                      initialIndex: index ?? 0,
                    ),
            ),
          );
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: 0,
              left: 5,
              child: Container(
                height: 75,
                width: size.width - 10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppTheme.accentColor(ref), width: 0.25),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isOnlineSongsPlaying
                          ? CachedNetworkImage(
                              imageUrl: song.image,
                              height: 75,
                              width: 75,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.music_note),
                            )
                          : Image.file(
                              File(song.image),
                              height: 75,
                              width: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/song_thumb.png');
                              },
                            ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artists
                                .map((artists) => artists.name)
                                .toSet()
                                .join(", "),
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 125,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              isOnlineSongsPlaying
                                  ? audioPlayerNotifier.previous()
                                  : offlineAudioNotifier.previous();
                            },
                            child:
                                const Icon(Ionicons.play_skip_back, size: 25),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isOnlineSongsPlaying) {
                                  audioProvider.isPlaying
                                      ? audioPlayerNotifier.pause()
                                      : audioPlayerNotifier.play();
                                } else {
                                  offlineAudioProvider.isPlaying
                                      ? offlineAudioNotifier.pause()
                                      : offlineAudioNotifier.play();
                                }
                              });
                            },
                            child: Icon(
                              isOnlineSongsPlaying
                                  ? (audioProvider.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow)
                                  : (offlineAudioProvider.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                              size: 35,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              isOnlineSongsPlaying
                                  ? audioPlayerNotifier.next()
                                  : offlineAudioNotifier.next();
                            },
                            child: const Icon(Ionicons.play_skip_forward,
                                size: 25),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isOnlineSongsPlaying) {
                                  audioPlayerNotifier.stop();
                                  ref
                                      .read(playingQueueProvider.notifier)
                                      .clear();
                                  audioPlayerNotifier.resetSongsList();
                                  audioPlayerNotifier.changeSlabShowStatus();
                                  audioProviderBox.put('local', []);
                                } else {
                                  offlineAudioNotifier.stop();
                                  offlineAudioNotifier.resetSongsList();
                                  offlineAudioNotifier.changeSlabShowStatus();
                                }
                              });
                            },
                            child: const Icon(Icons.cancel_rounded, size: 25),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox(height: 0);
    }
  }
}
