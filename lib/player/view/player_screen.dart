import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/model/api_calls.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/audio_player.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/songs_notifier.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  final SongModel song;
  const MusicPlayer({
    super.key,
    required this.song,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  late Box<SongModel> historyBox = Hive.box<SongModel>('history');
  bool _lyrics = false;

  @override
  void initState() {
    super.initState();
    _addSongToHistory();
  }

  void _addSongToHistory() {
    historyBox.add(widget.song);
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);
    final size = MediaQuery.of(context).size;
    String lyrics = '';

    audioService?.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        bool shuffle = audioService.shuffle();
        Navigator.of(context).pushReplacement(
          CustomPageRoute(
            builder: (context) => MusicPlayer(
              song: shuffle
                  ? audioService.shufflePlayback()
                  : audioService.nextPlayback(),
            ),
          ),
        );
      }
    });

    return CupertinoPageScaffold(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                ref.read(currentSongProvider.notifier).state = widget.song;
                ref.read(isMinimisedProvider.notifier).state = true;
                Navigator.pop(context);
              },
              icon: Icon(
                CupertinoIcons.chevron_down,
                color: AppPallete().accentColor,
              ),
            ),
            SizedBox(
              height: size.height * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _lyrics
                          ? Column(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxHeight: 350, minHeight: 350),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                height: 300,
                                                decoration: BoxDecoration(
                                                  color: CupertinoColors
                                                      .separator
                                                      .withOpacity(0.3),
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Scrollable(
                                                    viewportBuilder: (context,
                                                        viewportOffset) {
                                                      return NotificationListener<
                                                          ScrollMetricsNotification>(
                                                        child: FutureBuilder(
                                                          future: searchLyrics(
                                                              widget.song.id),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              lyrics = snapshot
                                                                  .data!;
                                                              return Text(
                                                                snapshot.data!,
                                                                style:
                                                                    TextStyle(
                                                                  color: AppPallete()
                                                                      .accentColor,
                                                                  fontSize: 15,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              );
                                                            } else if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const Center(
                                                                  child:
                                                                      CupertinoActivityIndicator());
                                                            }
                                                            return Text(
                                                              'No Lyrics Found!',
                                                              style: TextStyle(
                                                                  color: AppPallete()
                                                                      .accentColor),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: lyrics));
                                                },
                                                icon: const Icon(
                                                  Icons.copy_rounded,
                                                  color: AppPallete
                                                      .scaffoldBackgroundColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CupertinoColors.separator,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _lyrics = !_lyrics;
                                          });
                                        },
                                        child: Text(
                                          'Hide Lyrics',
                                          style: TextStyle(
                                              color: AppPallete().accentColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.song.imageUrl,
                                    height: 300,
                                    errorWidget: (context, url, error) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.nosign,
                                            color: AppPallete().accentColor,
                                            size: 40,
                                          ),
                                        ],
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return const CupertinoActivityIndicator();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CupertinoColors.separator,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _lyrics = !_lyrics;
                                    });
                                  },
                                  child: Text(
                                    'Show Lyrics',
                                    style: TextStyle(
                                        color: AppPallete().accentColor),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        widget.song.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 23,
                          color: AppPallete().accentColor,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.song.artists.join(", "),
                        style: TextStyle(
                          fontSize: 15,
                          color: AppPallete().accentColor.withAlpha(200),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  StreamBuilder<DurationState>(
                    stream: audioService?.player.positionStream.map((position) {
                      return DurationState(
                        progress: position,
                        buffered: audioService.player.bufferedPosition,
                        total: audioService.player.duration ?? Duration.zero,
                      );
                    }),
                    builder: (context, snapshot) {
                      final durationState = snapshot.data;
                      final progress = durationState?.progress ?? Duration.zero;
                      final total = durationState?.total ?? Duration.zero;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProgressBar(
                          progress: progress,
                          buffered: durationState?.buffered ?? Duration.zero,
                          total: total,
                          onSeek: audioService?.player.seek,
                          baseBarColor: CupertinoColors.inactiveGray,
                          progressBarColor: AppPallete().accentColor,
                          bufferedBarColor:
                              CupertinoColors.activeBlue.withAlpha(150),
                          thumbColor: AppPallete().accentColor,
                          thumbRadius: 0,
                          timeLabelTextStyle:
                              TextStyle(color: AppPallete().secondaryColor),
                          timeLabelPadding: 5,
                        ),
                      );
                    },
                  ),
                  PlayerControls(
                      audioService: audioService!, song: widget.song),
                ],
              ),
            ),
          ],
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
  final AudioService audioService;
  final SongModel song;

  const PlayerControls({
    super.key,
    required this.audioService,
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
    bool isPlaying = ref.watch(audioServiceProvider.notifier)!.player.playing;

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
                  : AppPallete().accentColor),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                builder: (context) => MusicPlayer(
                  song: widget.audioService.previousPlayback(),
                ),
              ),
            );
          },
          icon: Icon(CupertinoIcons.backward_end_fill,
              size: 30, color: AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            isPlaying
                ? widget.audioService.pause()
                : widget.audioService.play();
            setState(() {});
          },
          icon: Icon(
              !isPlaying
                  ? CupertinoIcons.play_circle_fill
                  : CupertinoIcons.pause_circle_fill,
              size: 60,
              color: AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            shuffleMode
                ? Navigator.pushReplacement(
                    context,
                    CustomPageRoute(
                      builder: (context) => MusicPlayer(
                        song: widget.audioService.shufflePlayback(),
                      ),
                    ),
                  )
                : Navigator.pushReplacement(
                    context,
                    CustomPageRoute(
                      builder: (context) => MusicPlayer(
                        song: widget.audioService.nextPlayback(),
                      ),
                    ),
                  );
          },
          icon: Icon(
            CupertinoIcons.forward_end_fill,
            size: 30,
            color: AppPallete().secondaryColor,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _repeatMode = (_repeatMode + 1) % 3;
            });
            widget.audioService.player.setLoopMode(
              _repeatMode == 0
                  ? LoopMode.off
                  : (_repeatMode == 1 ? LoopMode.all : LoopMode.one),
            );
          },
          icon: Icon(
              _repeatMode == 2
                  ? CupertinoIcons.repeat_1
                  : CupertinoIcons.repeat,
              color: _repeatMode == 0
                  ? AppPallete().secondaryColor
                  : CupertinoColors.activeBlue),
        ),
      ],
    );
  }
}
