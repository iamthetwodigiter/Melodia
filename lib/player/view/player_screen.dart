import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/core/cupertino_popup_message.dart';
import 'package:melodia/download/model/downloader.dart';
import 'package:melodia/library/view/playlist_screen.dart';
import 'package:melodia/player/model/api_calls.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/audio_player.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/download_progress_provider.dart';
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
  Box<SongModel> historyBox = Hive.box<SongModel>('history');
  Box<Playlist> playlistBox = Hive.box<Playlist>('playlist');
  bool isSongInPlaylist = false;
  bool _lyrics = false;
  Timer? _sleepTimer;
  Timer? _countdownTimer;

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    ref.read(remainingTimeProvider.notifier).state = duration;
    _sleepTimer = Timer(duration, () {
      final audioService = ref.read(audioServiceProvider.notifier);
      audioService?.pause();
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
    final audioService = ref.read(audioServiceProvider.notifier);
    audioService?.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            final nextSong = await audioService.nextPlayback();
            Navigator.pushReplacement(
              context,
              PlaybackRoute(
                builder: (context) => MusicPlayer(song: nextSong),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider);
    final size = MediaQuery.of(context).size;
    String lyrics = '';
    ref.watch(currentSongProvider);
    double downloadProgress = ref.watch(downloadProgressProvider);

    void updateProgress(double progress) {
      if ((progress * 100).toStringAsFixed(0) == 100.toString()) {
        ref.read(downloadDoneProvider.notifier).state = true;
      }
      setState(() {
        ref.watch(downloadProgressProvider.notifier).state = progress;
      });
    }

    if (!historyBox.values.any((song) => song.id == widget.song.id)) {
      historyBox.add(
        SongModel(
          link: widget.song.link,
          id: widget.song.id,
          name: widget.song.name.split('(')[0],
          duration: widget.song.duration,
          imageUrl: widget.song.imageUrl,
          artists: widget.song.artists,
          index: widget.song.index,
          shuffleMode: widget.song.shuffleMode,
          playlistName: widget.song.playlistName,
          year: widget.song.year,
          isUserCreated: Hive.box<Playlist>('playlist')
              .containsKey(widget.song.playlistName),
        ),
      );
    }

    return CupertinoPageScaffold(
      // backgroundColor: AppPallete.scaffoldDarkBackground,
      child: SafeArea(
        child: Container(
          height: size.height,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(currentSongProvider.notifier).state = widget.song;
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.chevron_down,
                    color: AppPallete().accentColor,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _lyrics
                            ? Column(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight: size.height * 0.5,
                                        minHeight: size.height * 0.5),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
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
                                                            future:
                                                                searchLyrics(
                                                                    widget.song
                                                                        .id),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                lyrics =
                                                                    snapshot
                                                                        .data!;
                                                                return Text(
                                                                  snapshot
                                                                      .data!,
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppPallete()
                                                                        .accentColor,
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                style:
                                                                    TextStyle(
                                                                  color: AppPallete()
                                                                      .secondaryColor,
                                                                ),
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
                                                  Colors.transparent,
                                              elevation: 0),
                                          onPressed: () {
                                            setState(() {
                                              _lyrics = !_lyrics;
                                            });
                                          },
                                          child: Text(
                                            'Hide Lyrics',
                                            style: TextStyle(
                                                color:
                                                    AppPallete().accentColor),
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
                                      height: size.height * 0.4,
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
                                        backgroundColor: Colors.transparent,
                                        elevation: 0),
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
                    SizedBox(
                      height: size.height * 0.1,
                    ),
                    SizedBox(
                      height: size.height * 0.4,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.song.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: AppPallete().accentColor,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 7),
                              Text(
                                widget.song.artists.join(", "),
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      AppPallete().accentColor.withAlpha(200),
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          StreamBuilder<DurationState>(
                            stream: audioService?.player.positionStream
                                .map((position) {
                              return DurationState(
                                progress: position,
                                buffered: audioService.player.bufferedPosition,
                                total: audioService.player.duration ??
                                    Duration.zero,
                              );
                            }),
                            builder: (context, snapshot) {
                              final durationState = snapshot.data;
                              final progress =
                                  durationState?.progress ?? Duration.zero;
                              final total =
                                  durationState?.total ?? Duration.zero;
          
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ProgressBar(
                                  progress: progress,
                                  buffered:
                                      durationState?.buffered ?? Duration.zero,
                                  total: total,
                                  onSeek: audioService?.player.seek,
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
                            audioService: audioService!,
                            song: widget.song,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                child: Text(
                                  'Playing Next',
                                  style: TextStyle(
                                    color: AppPallete().accentColor,
                                  ),
                                ),
                                onPressed: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) =>
                                          CupertinoPopupSurface(
                                            child: SizedBox(
                                              height: size.height * 0.5,
                                              child: ListView.builder(
                                                itemCount: widget
                                                    .song
                                                    .playlistData!
                                                    .idList
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  Duration(
                                                    minutes: int.parse(
                                                      widget.song.playlistData!
                                                          .durationList
                                                          .elementAt(index),
                                                    ),
                                                  );
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10)
                                                        .copyWith(bottom: 5),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CupertinoListTile(
                                                        backgroundColor:
                                                            AppPallete()
                                                                .accentColor
                                                                .withAlpha(75),
                                                        onTap: () {
                                                          final songToGo = SongModel(
                                                              link: widget
                                                                  .song
                                                                  .playlistData!
                                                                  .linkList
                                                                  .elementAt(
                                                                      index),
                                                              id: widget.song.playlistData!.idList.elementAt(
                                                                  index),
                                                              name: widget
                                                                  .song
                                                                  .playlistData!
                                                                  .nameList
                                                                  .elementAt(
                                                                      index),
                                                              duration: widget
                                                                  .song
                                                                  .playlistData!
                                                                  .durationList
                                                                  .elementAt(
                                                                      index),
                                                              imageUrl: widget
                                                                  .song
                                                                  .playlistData!
                                                                  .imageUrlList
                                                                  .elementAt(index),
                                                              artists: widget.song.playlistData!.artistsList.elementAt(index),
                                                              playlistData: widget.song.playlistData,
                                                              index: index,
                                                              shuffleMode: settings.get('shuffle') == 1,
                                                              playlistName: widget.song.playlistName,
                                                              year: widget.song.year,
                                                              isUserCreated: Hive.box<Playlist>('playlist').containsKey(widget.song.playlistName));
                                                          ref
                                                              .watch(
                                                                  currentSongProvider
                                                                      .notifier)
                                                              .state = songToGo;
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                            CustomPageRoute(
                                                              page: MusicPlayer(
                                                                song: songToGo,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 30),
                                                        leading:
                                                            CachedNetworkImage(
                                                          imageUrl: widget
                                                              .song
                                                              .playlistData!
                                                              .imageUrlList
                                                              .elementAt(index),
                                                          errorWidget: (context,
                                                              url, error) {
                                                            return Image.asset(
                                                                'assets/song_thumb.png');
                                                          },
                                                        ),
                                                        title: Text(
                                                          widget
                                                              .song
                                                              .playlistData!
                                                              .nameList
                                                              .elementAt(index),
                                                          style: TextStyle(
                                                            color: darkMode
                                                                ? CupertinoColors
                                                                    .white
                                                                : AppPallete()
                                                                    .accentColor,
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                        subtitle: Text(
                                                          widget
                                                              .song
                                                              .playlistData!
                                                              .artistsList
                                                              .elementAt(index)
                                                              .join(", "),
                                                          style: TextStyle(
                                                              color: darkMode
                                                                  ? CupertinoColors
                                                                      .white
                                                                  : AppPallete()
                                                                      .accentColor),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ));
                                },
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      List metadata = [
                                        widget.song.name,
                                        widget.song.artists,
                                        widget.song.playlistName,
                                        widget.song.duration,
                                        widget.song.imageUrl,
                                        widget.song.index,
                                        widget.song.year,
                                      ];
                                      download(
                                        widget.song.link,
                                        '${widget.song.name.trimRight()}.m4a',
                                        metadata,
                                        context,
                                        updateProgress,
                                      );
                                      setState(() {});
                                    },
                                    icon: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          File('storage/emulated/0/Music/Melodia/${widget.song.name.trimRight()}.m4a')
                                                      .existsSync() ||
                                                  ref.watch(
                                                      downloadDoneProvider)
                                              ? Icons.download_done_rounded
                                              : Icons.download_rounded,
                                          color: AppPallete().accentColor,
                                        ),
                                        if (downloadProgress > 0 &&
                                            downloadProgress < 1)
                                          CircularProgressIndicator(
                                            value: downloadProgress,
                                            backgroundColor: Colors.white,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppPallete().accentColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        Column(
                                          children: [
                                            CupertinoTimerPicker(
                                              initialTimerDuration: ref
                                                  .watch(remainingTimeProvider),
                                              onTimerDurationChanged: (value) {
                                                ref
                                                    .read(sleepTimerProvider
                                                        .notifier)
                                                    .state = value;
                                              },
                                            ),
                                            CupertinoButton(
                                              // padding: EdgeInsets.zero,
                                              color: AppPallete().accentColor,
                                              child: const Text("Start Timer"),
                                              onPressed: () {
                                                final duration = ref
                                                    .read(sleepTimerProvider);
                                                startSleepTimer(duration);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      CupertinoIcons.clock_solid,
                                      color: AppPallete().accentColor,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext context) {
                                          if (playlistBox.length != 0) {
                                            return CupertinoActionSheet(
                                              actions: [
                                                CupertinoActionSheetAction(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        if (playlistBox
                                                                .length !=
                                                            0) {
                                                          final playlists =
                                                              playlistBox.keys
                                                                  .toList();
                                                          return CupertinoActionSheet(
                                                            actions: playlists
                                                                .map((name) {
                                                              final currentPlaylist =
                                                                  playlistBox
                                                                      .get(
                                                                          name);
                                                              if (currentPlaylist !=
                                                                  null) {
                                                                return CupertinoActionSheetAction(
                                                                  onPressed:
                                                                      () {
                                                                    bool songExists = currentPlaylist
                                                                        .idList
                                                                        .contains(widget
                                                                            .song
                                                                            .id);
                                                                    setState(
                                                                        () {
                                                                      isSongInPlaylist =
                                                                          songExists;
                                                                    });
                                                                    if (!songExists) {
                                                                      final updatedPlaylist =
                                                                          Playlist(
                                                                        idList: List.from(currentPlaylist
                                                                            .idList)
                                                                          ..add(widget
                                                                              .song
                                                                              .id),
                                                                        linkList: List.from(currentPlaylist
                                                                            .linkList)
                                                                          ..add(widget
                                                                              .song
                                                                              .link),
                                                                        imageUrlList: List.from(currentPlaylist
                                                                            .imageUrlList)
                                                                          ..add(widget
                                                                              .song
                                                                              .imageUrl),
                                                                        nameList: List.from(currentPlaylist
                                                                            .nameList)
                                                                          ..add(widget
                                                                              .song
                                                                              .name
                                                                              .split('(')[0]),
                                                                        artistsList: List.from(currentPlaylist
                                                                            .artistsList)
                                                                          ..add(widget
                                                                              .song
                                                                              .artists),
                                                                        durationList: List.from(currentPlaylist
                                                                            .durationList)
                                                                          ..add(widget
                                                                              .song
                                                                              .duration),
                                                                      );
                                                                      playlistBox.put(
                                                                          name,
                                                                          updatedPlaylist);
                                                                    }
                                                                    showCupertinoCenterPopup(
                                                                        context,
                                                                        '${widget.song.name.split('(')[0]} Added to Playlist $name',
                                                                        Icons
                                                                            .download_done_rounded);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                      name),
                                                                );
                                                              } else {
                                                                return CupertinoActionSheetAction(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Error: Playlist not found'),
                                                                );
                                                              }
                                                            }).toList(),
                                                            cancelButton:
                                                                CupertinoActionSheetAction(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              isDestructiveAction:
                                                                  true,
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                          );
                                                        } else {
                                                          return CupertinoActionSheet(
                                                            actions: [
                                                              CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    'Create Playlist'),
                                                              ),
                                                            ],
                                                            cancelButton:
                                                                CupertinoActionSheetAction(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              isDestructiveAction:
                                                                  true,
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                  child: const Text(
                                                      'Add to Playlist'),
                                                ),
                                              ],
                                              cancelButton:
                                                  CupertinoActionSheetAction(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                isDestructiveAction: true,
                                                child: const Text('Cancel'),
                                              ),
                                            );
                                          }
                                          return CupertinoActionSheet(
                                            actions: [
                                              CupertinoActionSheetAction(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          const LibraryScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                    'Please Create Playlist First'),
                                              ),
                                            ],
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              isDestructiveAction: true,
                                              child: const Text('Cancel'),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      CupertinoIcons.add_circled,
                                      size: 20,
                                      color: AppPallete().accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
                  : AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted) {
                final previousSong =
                    await widget.audioService.previousPlayback();
                Navigator.pushReplacement(
                  context,
                  PlaybackRoute(
                    builder: (context) => MusicPlayer(song: previousSong),
                  ),
                );
              }
            });
          },
          icon: Icon(CupertinoIcons.backward_end_fill,
              size: 25, color: AppPallete().secondaryColor),
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
              size: 50,
              color: AppPallete().secondaryColor),
        ),
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted) {
                final nextSong = await widget.audioService.nextPlayback();
                Navigator.pushReplacement(
                  context,
                  PlaybackRoute(
                    builder: (context) => MusicPlayer(song: nextSong),
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
