import 'dart:async';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/model/offline_song_model.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/offline_audio_player.dart';
import 'package:melodia/provider/songs_notifier.dart';

class OfflineMusicPlayer extends ConsumerStatefulWidget {
  final OfflineSongModel song;
  const OfflineMusicPlayer({
    super.key,
    required this.song,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OfflineMusicPlayerState();
}

class _OfflineMusicPlayerState extends ConsumerState<OfflineMusicPlayer> {
  Timer? _sleepTimer;
  Timer? _countdownTimer;

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    ref.read(remainingTimeProvider.notifier).state = duration;
    _sleepTimer = Timer(duration, () {
      final offlineAudioService =
          ref.read(offlineAudioServiceProvider.notifier);
      offlineAudioService?.pause();
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remainingTime = ref.read(remainingTimeProvider);
      if (remainingTime.inSeconds > 0) {
        ref.read(remainingTimeProvider.notifier).state =
            remainingTime - const Duration(seconds: 1);
      } else {
        timer.cancel();
      }
    });
  }

  void showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final audioService = ref.read(offlineAudioServiceProvider.notifier);
    audioService?.player.playerStateStream.listen(
      (state) {
        if (state.processingState == ProcessingState.completed) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) async {
              if (mounted) {
                final nextSong = audioService.nextPlayback();
                Navigator.pushReplacement(
                  context,
                  PlaybackRoute(
                    builder: (context) => OfflineMusicPlayer(song: nextSong),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offlineAudioPlayer = ref.watch(offlineAudioServiceProvider);
    final index = widget.song.index;
    final name = widget.song.songList
        .elementAt(index)
        .path
        .toString()
        .replaceAll("storage/emulated/0/Music/Melodia/", "")
        .replaceAll(".m4a", "");
    final thumb = widget.song.thumbList.elementAt(index);
    final tag = widget.song.tags.elementAt(index);
    final size = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            height: size.height,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: size.height * 0.5,
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            CupertinoIcons.chevron_down_circle_fill,
                            color: AppPallete().accentColor,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            thumb!,
                            height: size.height * 0.4,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/song_thumb.png',
                                height: 150,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.1),
                  SizedBox(
                    height: size.height * 0.4,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: AppPallete().accentColor,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              tag!.artist!,
                              style: TextStyle(
                                color: AppPallete().accentColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        StreamBuilder<DurationState>(
                          stream: offlineAudioPlayer?.player.positionStream
                              .map((position) {
                            return DurationState(
                              progress: position,
                              buffered:
                                  offlineAudioPlayer.player.bufferedPosition,
                              total: offlineAudioPlayer.player.duration ??
                                  Duration.zero,
                            );
                          }),
                          builder: (context, snapshot) {
                            final durationState = snapshot.data;
                            final progress =
                                durationState?.progress ?? Duration.zero;
                            final total = durationState?.total ?? Duration.zero;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: ProgressBar(
                                progress: progress,
                                buffered:
                                    durationState?.buffered ?? Duration.zero,
                                total: total,
                                onSeek: offlineAudioPlayer?.player.seek,
                                baseBarColor: CupertinoColors.inactiveGray,
                                progressBarColor: AppPallete().accentColor,
                                // bufferedBarColor:
                                //     CupertinoColors.activeBlue.withAlpha(150),
                                thumbColor: AppPallete().accentColor,
                                thumbRadius: 10,
                                timeLabelTextStyle: TextStyle(
                                    color: AppPallete().secondaryColor),
                                timeLabelPadding: 5,
                              ),
                            );
                          },
                        ),
                        PlayerControls(
                          offlineAudioPlayer: offlineAudioPlayer!,
                          song: widget.song,
                        ),
                        // Spacer(),
                        TextButton(
                          onPressed: () => showDialog(
                            Column(
                              children: [
                                CupertinoTimerPicker(
                                  initialTimerDuration:
                                      ref.watch(remainingTimeProvider),
                                  onTimerDurationChanged: (value) {
                                    ref
                                        .read(sleepTimerProvider.notifier)
                                        .state = value;
                                  },
                                ),
                                CupertinoButton(
                                  color: AppPallete().accentColor,
                                  child: const Text("Start Timer"),
                                  onPressed: () {
                                    final duration =
                                        ref.read(sleepTimerProvider);
                                    startSleepTimer(duration);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                          child: SizedBox(
                            width: 110,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sleep Timer',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                Icon(
                                  CupertinoIcons.clock_solid,
                                  color: AppPallete().accentColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration total;

  DurationState({
    required this.progress,
    required this.buffered,
    required this.total,
  });
}

class PlayerControls extends ConsumerStatefulWidget {
  final OfflineAudioPlayer offlineAudioPlayer;
  final OfflineSongModel song;

  const PlayerControls({
    super.key,
    required this.offlineAudioPlayer,
    required this.song,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends ConsumerState<PlayerControls> {
  int _repeatMode = 0;
  late Box settings;

  @override
  void initState() {
    super.initState();
    settings = Hive.box('settings');
  }

  @override
  Widget build(BuildContext context) {
    bool shuffleMode = settings.get('shuffle') == 0 ? false : true;
    bool isPlaying =
        ref.watch(offlineAudioServiceProvider.notifier)!.player.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              shuffleMode = !shuffleMode;
              settings.put('shuffle', shuffleMode == false ? 0 : 1);
            });
          },
          icon: Icon(CupertinoIcons.shuffle,
              color: shuffleMode
                  ? CupertinoColors.activeBlue
                  : AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PlaybackRoute(
                builder: (context) => OfflineMusicPlayer(
                  song: widget.offlineAudioPlayer.previousPlayback(),
                ),
              ),
            );
          },
          icon: Icon(CupertinoIcons.backward_end_fill,
              size: 25, color: AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            isPlaying
                ? widget.offlineAudioPlayer.pause()
                : widget.offlineAudioPlayer.play();
            setState(() {});
          },
          icon: Icon(
              !isPlaying
                  ? CupertinoIcons.play_circle_fill
                  : CupertinoIcons.pause_circle_fill,
              size: 50,
              color: AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  PlaybackRoute(
                    builder: (context) => OfflineMusicPlayer(
                      song: widget.offlineAudioPlayer.nextPlayback(),
                    ),
                  ),
                );
              }
            });
          },
          icon: Icon(
            CupertinoIcons.forward_end_fill,
            size: 25,
            color: AppPallete().secondaryColor,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _repeatMode = (_repeatMode + 1) % 3;
            });
            widget.offlineAudioPlayer.player.setLoopMode(
              _repeatMode == 0
                  ? LoopMode.off
                  : (_repeatMode == 1 ? LoopMode.all : LoopMode.one),
            );
          },
          icon: Icon(
            _repeatMode == 2 ? CupertinoIcons.repeat_1 : CupertinoIcons.repeat,
            color: _repeatMode == 0
                ? AppPallete().secondaryColor
                : CupertinoColors.activeBlue,
          ),
        ),
      ],
    );
  }
}
