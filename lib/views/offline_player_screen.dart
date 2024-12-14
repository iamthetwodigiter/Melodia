import 'dart:async';
import 'dart:io';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/models/audio_player_state_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/current_offline_song_provider.dart';
import 'package:melodia/providers/offline_audio_provider.dart';
import 'package:melodia/providers/offline_favorites_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/offline_song_list_item.dart';
import 'package:melodia/widgets/sleep_timer.dart';

class OfflinePlayerScreen extends ConsumerStatefulWidget {
  final List<Songs> playlist;
  final int initialIndex;

  const OfflinePlayerScreen({
    super.key,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  ConsumerState<OfflinePlayerScreen> createState() =>
      _OfflinePlayerScreenState();
}

class _OfflinePlayerScreenState extends ConsumerState<OfflinePlayerScreen> {
  late final AudioPlayerState audioProvider;
  late final OfflineAudioPlayerNotifier audioNotifier;
  String lyrics = '';
  bool _showLyrics = false;

  Duration? _remainingDuration;
  Timer? _countdownTimer;

  Duration? endOfSongAfter;

  void startSleepTimer(Duration duration) {
    setState(() {
      _remainingDuration = duration;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingDuration! > const Duration(seconds: 1)) {
        setState(() {
          _remainingDuration = _remainingDuration! - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        ref.read(offlineAudioPlayerProvider.notifier).stop(); // Stop music
        setState(() {
          _remainingDuration = null; // Reset timer
        });
      }
    });
  }

  void cancelSleepTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingDuration = null;
    });
  }

  void addTimer(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => SleepTimerDialog(
        stopMusic: cancelSleepTimer,
        remainingDuration: _remainingDuration,
        onStartTimer: startSleepTimer,
        onCancelTimer: cancelSleepTimer,
        endOfSongAfter: endOfSongAfter,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    audioProvider = ref.read(offlineAudioPlayerProvider);
    audioNotifier = ref.read(offlineAudioPlayerProvider.notifier);
    final onlineSongNotifier = ref.read(audioPlayerProvider.notifier);
    onlineSongNotifier.stop();
    onlineSongNotifier.resetSongsList();
    final audioSources = ref.read(currentOfflineSongsProvider(widget.playlist));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!audioNotifier.isPlaylistSet ||
          !(audioNotifier.songsList == widget.playlist)) {
        audioNotifier.setPlaylist(
          audioSources,
          widget.playlist,
          initialIndex: widget.initialIndex,
        );
      } else {
        if (audioProvider.currentIndex == widget.initialIndex) {
          audioNotifier.seek(audioProvider.progress,
              index: widget.initialIndex);
        } else {
          audioNotifier.seek(Duration.zero, index: widget.initialIndex);
        }
      }
      audioNotifier.play();
      audioNotifier.changeSlabShowStatus();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(offlineAudioPlayerProvider);
    final audioNotifier = ref.read(offlineAudioPlayerProvider.notifier);
    final offlineFavorites = ref.watch(offlineFavoritesProvider.notifier);

    final size = MediaQuery.of(context).size;

    final currentSong = (audioState.currentIndex != null &&
            audioState.currentIndex! < widget.playlist.length)
        ? widget.playlist[audioState.currentIndex!]
        : widget.playlist[widget.initialIndex];

    final isFavorite = offlineFavorites.isFavorite(currentSong);

    if (currentSong.hasLyrics) {
      setState(() {
        lyrics = currentSong.type;
      });
    } else {
      setState(() {
        lyrics = "No lyrics found";
      });
    }

    void showPlayingQueue() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Consumer(
            builder: (context, ref, _) {
              return ListView.builder(
                itemCount: audioNotifier.songsList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const ListTile(
                      title: Text(
                        'Playing Queue',
                        style: TextStyle(fontSize: 25),
                      ),
                    );
                  }
                  final song = audioNotifier.songsList.elementAt(index - 1);

                  return Container(
                    color: index - 1 == audioState.currentIndex
                        ? AppTheme.accentColor(ref).withAlpha(50)
                        : null,
                    child: OfflineSongsListItem(
                      songList: audioNotifier.songsList,
                      song: song,
                      index: index - 1,
                      fromPlayingQueue: true,
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _showLyrics
                    ? Container(
                        color: AppTheme.accentColor(ref).withAlpha(25),
                        padding: const EdgeInsets.all(5),
                        height: 300,
                        width: 300,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Text(
                            lyrics,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : currentSong.image.isNotEmpty
                        ? Image.file(
                            File(currentSong.image),
                            height: 300,
                            width: 300,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/song_thumb.png',
                                height: 300,
                                width: 300,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/song_thumb.png',
                            height: 300,
                            width: 300,
                          ),
              ),
              const SizedBox(height: 20),
              Text(
                currentSong.title,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                (currentSong.artists)
                    .map((artist) => artist.name)
                    .toSet()
                    .join(", "),
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              StreamBuilder<AudioPlayerState>(
                stream: audioNotifier.durationStateStream,
                builder: (context, snapshot) {
                  final durationState = snapshot.data;
                  final progress = durationState?.progress ?? Duration.zero;
                  final buffered = durationState?.buffered ?? Duration.zero;
                  final total = durationState?.total ?? Duration.zero;
                  endOfSongAfter = total - progress;
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ProgressBar(
                      progress: progress,
                      buffered: buffered,
                      total: total,
                      progressBarColor: AppTheme.accentColor(ref),
                      baseBarColor: AppTheme.accentColor(ref).withAlpha(100),
                      bufferedBarColor:
                          AppTheme.accentColor(ref).withAlpha(100),
                      thumbColor: AppTheme.accentColor(ref),
                      onSeek: (duration) {
                        audioNotifier.seek(duration);
                      },
                    ),
                  );
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      audioNotifier.toggleShuffle();
                    },
                    child: Icon(
                      Ionicons.shuffle,
                      size: 28,
                      color: audioState.isShuffleMode
                          ? AppTheme.accentColor(ref)
                          : Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      audioNotifier.previous();
                    },
                    child: const Icon(Ionicons.play_skip_back, size: 28),
                  ),
                  InkWell(
                    onTap: () {
                      audioState.isPlaying
                          ? audioNotifier.pause()
                          : audioNotifier.play();
                    },
                    child: Icon(
                      audioState.isPlaying
                          ? Ionicons.pause_circle
                          : Ionicons.play_circle,
                      size: 60,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      audioNotifier.next();
                    },
                    child: const Icon(Ionicons.play_skip_forward, size: 28),
                  ),
                  InkWell(
                    onTap: () {
                      audioNotifier.toggleLoop();
                    },
                    child: Icon(
                      audioState.loopMode == LoopMode.one
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                      color: audioState.loopMode == LoopMode.off
                          ? Colors.white
                          : AppTheme.accentColor(ref),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Icon(
                        audioState.volume == 0
                            ? Icons.volume_mute
                            : Icons.volume_down,
                        size: 28),
                    onTap: () {
                      audioNotifier.adjustVolume(-0.1);
                    },
                  ),
                  Expanded(
                    child: Slider(
                      value: audioState.volume,
                      min: 0,
                      max: 1,
                      activeColor: AppTheme.accentColor(ref),
                      onChanged: (value) {
                        audioNotifier.setVolume(value);
                      },
                    ),
                  ),
                  GestureDetector(
                    child: const Icon(Icons.volume_up),
                    onTap: () {
                      audioNotifier.adjustVolume(0.1);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showLyrics = !_showLyrics;
                      });
                    },
                    child: _showLyrics
                        ? Icon(Icons.lyrics, color: AppTheme.accentColor(ref))
                        : const Icon(Icons.lyrics_outlined,
                            color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite
                            ? offlineFavorites.removeFavorite(currentSong)
                            : offlineFavorites.addFavorite(currentSong);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        customSnackBar(
                            !isFavorite
                                ? 'Added to Favorites ❤️'
                                : 'Removed from Favorites',
                            ref),
                      );
                    },
                    child: isFavorite
                        ? const Icon(Icons.favorite, color: Colors.red)
                        : const Icon(Icons.favorite_border,
                            color: Colors.white),
                  ),
                  (_remainingDuration == null)
                      ? GestureDetector(
                          onTap: () {
                            addTimer(context);
                          },
                          child: const Icon(Icons.bedtime_outlined,
                              color: Colors.white),
                        )
                      : GestureDetector(
                          onTap: () {
                            cancelSleepTimer();
                          },
                          child: Text(
                            "${_remainingDuration!.inMinutes}:${(_remainingDuration!.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: TextStyle(color: AppTheme.accentColor(ref)),
                          ),
                        ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPlayingQueue();
                      });
                    },
                    child: const Icon(Icons.queue_music, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
