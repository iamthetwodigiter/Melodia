import 'dart:async';
import 'dart:math';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/models/audio_player_state_model.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/current_songs_provider.dart';
import 'package:melodia/providers/favorites_provider.dart';
import 'package:melodia/providers/offline_audio_provider.dart';
import 'package:melodia/providers/offline_files_provider.dart';
import 'package:melodia/providers/playing_queue_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/providers/user_playlists_provider.dart';
import 'package:melodia/services/api_calls.dart';
import 'package:melodia/services/download.dart';
import 'package:melodia/services/youtube_download.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/sleep_timer.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final List<Songs> playlist;
  final int initialIndex;

  const PlayerScreen({
    super.key,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late TextEditingController _playlistNameController;

  late final AudioPlayerState audioProvider;
  late final AudioPlayerNotifier audioNotifier;
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
        ref.read(audioPlayerProvider.notifier).stop();
        setState(() {
          _remainingDuration = null;
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

  Future<void> initializeData() async {
    try {
      audioProvider = ref.read(audioPlayerProvider);
      audioNotifier = ref.read(audioPlayerProvider.notifier);
      final offlineAudioNotifier =
          ref.read(offlineAudioPlayerProvider.notifier);
      offlineAudioNotifier.stop();
      final playingQueue = ref.read(playingQueueProvider);

      final audioSources =
          await ref.read(currentSongsProvider(widget.playlist));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!audioNotifier.isPlaylistSet ||
            !(audioNotifier.songsList == playingQueue)) {
          audioNotifier.setPlaylist(
            audioSources,
            playingQueue,
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
        audioNotifier.changeSlabShowStatus();
        audioNotifier.play();
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    _playlistNameController = TextEditingController();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);
    final favorites = ref.watch(favoritesProvider.notifier);
    final streamingQuality = ref.watch(settingsProvider)?.streamingQuality;
    final settings = ref.watch(settingsProvider);
    ref.watch(filesProvider);
    final files = ref.watch(filesProvider.notifier);
    final userPlaylist = ref.watch(userPlaylistsProvider);
    final userPlaylistNotifier = ref.watch(userPlaylistsProvider.notifier);
    final playingQueue = ref.watch(playingQueueProvider);
    final size = MediaQuery.of(context).size;

    if (playingQueue.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    final tempSong = (audioState.currentIndex != null &&
            audioState.currentIndex! < playingQueue.length)
        ? playingQueue[audioState.currentIndex!]
        : playingQueue[widget.initialIndex];

    final currentSong = tempSong.copyWith(
      downloadUrl:
          tempSong.downloadUrl.replaceAll("_320", "_$streamingQuality"),
    );

    final isFavorite = favorites.isFavorite(currentSong);
    bool isDownloaded = files.isDownloaded(currentSong.title);

    if (currentSong.hasLyrics) {
      fetchLyrics(currentSong.id).then((data) {
        setState(() {
          lyrics = data;
        });
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
                itemCount: playingQueue.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const ListTile(
                      title: Text(
                        'Playing Queue',
                        style: TextStyle(fontSize: 25),
                      ),
                    );
                  }
                  final song = playingQueue.elementAt(index - 1);

                  return InkWell(
                    onTap: () {
                      audioNotifier.seek(Duration.zero, index: index - 1);
                      audioNotifier.play();
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: index - 1 == audioState.currentIndex
                          ? AppTheme.accentColor(ref).withAlpha(50)
                          : null,
                      child: SongsListItem(
                        songsList: playingQueue,
                        song: song,
                        index: index - 1,
                        fromPlayingQueue: true,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    void addToPlaylist() {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            message: Text('Add "${currentSong.title}" to Playlist',
                style: const TextStyle(fontSize: 18)),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            actions: [
              for (final playlist in userPlaylist)
                CupertinoActionSheetAction(
                  onPressed: () {
                    bool isAdded = userPlaylistNotifier.addSongToPlaylist(
                        playlist, currentSong);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      customSnackBar(
                          isAdded
                              ? '${currentSong.title} added to Playlist ${playlist.title}'
                              : 'Song already exists in Playlist',
                          ref),
                    );
                  },
                  child: Text(
                    playlist.title,
                    style: TextStyle(color: AppTheme.accentColor(ref)),
                  ),
                ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text('Create Playlist'),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CupertinoTextField(
                            controller: _playlistNameController,
                            placeholder: 'Enter playlist name',
                            cursorColor: AppTheme.accentColor(ref),
                            style: TextStyle(
                              color: AppTheme.accentColor(ref),
                            ),
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.pop(context);
                              _playlistNameController.clear();
                            },
                            isDestructiveAction: true,
                            child: const Text('Cancel'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () {
                              String id =
                                  Random().nextInt(1000000000).toString();
                              int year = DateTime.now().year;
                              userPlaylistNotifier.addPlaylist(
                                Playlists(
                                  id: id,
                                  title: _playlistNameController.text,
                                  type: 'User Playlist',
                                  year: year,
                                  language: '',
                                  explicitContent: false,
                                  url: '',
                                  songCount: 0,
                                  artists: [],
                                  image: '',
                                  songs: [],
                                ),
                              );
                              Navigator.of(context).pop();
                              _playlistNameController.clear();
                            },
                            child: Text(
                              'Create',
                              style:
                                  TextStyle(color: AppTheme.accentColor(ref)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Create Playlist',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }

    void moreOptions() {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            title: Text(
              currentSong.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  addToPlaylist();
                },
                child: Text(
                  'Add to Playlist',
                  style: TextStyle(color: AppTheme.accentColor(ref)),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  if (isDownloaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      customSnackBar(
                          '"${currentSong.title}" is Already Downloaded', ref),
                    );
                  } else {
                    if (currentSong.type == "YouTube") {
                      // Download stops abruptly at around 97% and speed is way too slow, will be fixed in the next build
                      // ytDownload(currentSong);
                      // ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
                      //     'YouTube download is broken and will be fixed in the next update',
                      //     ref));

                      ytDownload(currentSong, ref);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
                          '"${currentSong.title}" Downloading Started', ref));
                      downloadSong(
                        [currentSong],
                        settings?.downloadQuality.toString() ?? '96',
                        ref,
                      );
                    }
                  }
                },
                child: Text(
                  'Download',
                  style: TextStyle(color: AppTheme.accentColor(ref)),
                ),
              ),
            ],
          );
        },
      );
    }

    if (playingQueue.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Error playing songs...\nPlease try again..."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              moreOptions();
            },
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
                        height: size.height * 0.45,
                        width: size.height * 0.45,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Text(
                            lyrics,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: currentSong.image,
                        height: size.height * 0.45,
                        width: size.height * 0.45,
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
                            ? favorites.removeFavorite(currentSong)
                            : favorites.addFavorite(currentSong);
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
                  if (isDownloaded)
                    const Icon(Icons.download_done, color: Colors.green),
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
