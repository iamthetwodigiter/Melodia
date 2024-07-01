import 'dart:async';
import 'dart:math';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/player/model/api_calls.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/songs_notifier.dart';

class CustomPageRoute extends CupertinoPageRoute {
  // ignore: use_super_parameters
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class MusicPlayer extends ConsumerStatefulWidget {
  final SongModel song;
  const MusicPlayer({super.key, required this.song});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

Box settings = Hive.box('settings');
String downloadQuality = settings.get('download_quality');
String streamingQuality = settings.get('streaming_quality');
int shuffle = settings.get('shuffle');
String cache = settings.get('cache_songs');

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  AudioPlayer? player;
  final _durationState = StreamController<DurationState>();
  bool _lyrics = false;
  int _repeatMode = 0;
  int _songsCount = 0;
  bool _shuffle = false;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _shuffle = widget.song.shuffleMode;
    if (cache == 'true') {
      final audioSource = LockCachingAudioSource(
          Uri.parse(widget.song.link.replaceAll('320', streamingQuality)));
      player!.setAudioSource(audioSource);
    } else {
      final audioSource = AudioSource.uri(
          Uri.parse(widget.song.link.replaceAll('320', streamingQuality)));
      player!.setAudioSource(audioSource);
    }

    setState(() {
      _songsCount = widget.song.playlistData!.linkList.length;
      _shuffle = settings.get('shuffle') == 0 ? false : true;
    });

    player!.play();
    _updateDurationState();

    Future(() {
      ref.read(isPlayingProvider.notifier).state = true;
      ref.read(currentSongProvider.notifier).state = widget.song;
    });
  }

  void _updateDurationState() {
    player!.positionStream.listen((position) {
      _durationState.add(
        DurationState(
          progress: position,
          buffered: player!.bufferedPosition,
          total: Duration(seconds: int.parse(widget.song.duration)),
        ),
      );
    });
    isCompleted();
  }

  void isCompleted() {
    player!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _shuffle ? shufflePlayback() : nextPlayback();
      }
    });
  }

  void previousPlayback() {
    player!.seekToPrevious();
    int index = widget.song.index;
    setState(() {
      index = (index - 1) % _songsCount;
    });

    Navigator.of(context).pushReplacement(
      CustomPageRoute(builder: (context) {
        final songmodel = SongModel(
          link: widget.song.playlistData!.linkList.elementAt(index),
          id: widget.song.playlistData!.idList.elementAt(index),
          name:
              widget.song.playlistData!.nameList.elementAt(index).split('(')[0],
          imageUrl: widget.song.playlistData!.imageUrlList.elementAt(index),
          duration: widget.song.playlistData!.durationList.elementAt(index),
          artists: widget.song.playlistData!.artistsList.elementAt(index),
          playlistData: widget.song.playlistData,
          index: index++,
          shuffleMode: _shuffle,
        );
        return MusicPlayer(song: songmodel);
      }),
    );
  }

  void nextPlayback() {
    player!.seekToNext();

    int index = widget.song.index;
    setState(() {
      index = (index + 1) % _songsCount;
    });
    Navigator.of(context).pop();
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext builder) {
          final songmodel = SongModel(
            link: widget.song.playlistData!.linkList.elementAt(index),
            id: widget.song.playlistData!.idList.elementAt(index),
            name: widget.song.playlistData!.nameList
                .elementAt(index)
                .split('(')[0],
            imageUrl: widget.song.playlistData!.imageUrlList.elementAt(index),
            duration: widget.song.playlistData!.durationList.elementAt(index),
            artists: widget.song.playlistData!.artistsList.elementAt(index),
            playlistData: widget.song.playlistData,
            index: index++,
            shuffleMode: _shuffle,
          );
          return MusicPlayer(song: songmodel);
        });
  }

  void shufflePlayback() {
    int index = widget.song.index;
    setState(() {
      var temp = Random();
      index = temp.nextInt(_songsCount);
    });
    player!.seek(Duration.zero, index: index);
    Navigator.of(context).pushReplacement(
      CustomPageRoute(builder: (context) {
        final songmodel = SongModel(
          link: widget.song.playlistData!.linkList.elementAt(index),
          id: widget.song.playlistData!.idList.elementAt(index),
          name:
              widget.song.playlistData!.nameList.elementAt(index).split('(')[0],
          imageUrl: widget.song.playlistData!.imageUrlList.elementAt(index),
          duration: widget.song.playlistData!.durationList.elementAt(index),
          artists: widget.song.playlistData!.artistsList.elementAt(index),
          playlistData: widget.song.playlistData,
          index: index,
          shuffleMode: _shuffle,
        );
        return MusicPlayer(song: songmodel);
      }),
    );
  }

  @override
  void dispose() {
    player!.dispose();
    _durationState.close();
    ref.read(isPlayingProvider.notifier).state = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoPopupSurface(
      child: Container(
        height: size.height * 0.925,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                settings.put('currentSong', widget.song);
                setState(() {
                  
                });
                Navigator.of(context).pop();
                
                // showCupertinoModalPopup(
                //     barrierDismissible: false,
                //     context: context,
                //     builder: (BuildContext builder) {
                //       final song = SongModel(
                //         link: widget.song.link,
                //         id: widget.song.id,
                //         name: widget.song.name,
                //         duration: widget.song.duration,
                //         imageUrl: widget.song.imageUrl,
                //         artists: widget.song.artists,
                //         index: widget.song.index,
                //         shuffleMode: widget.song.shuffleMode,
                //         player: player!,
                //       );
                //       return CupertinoPopupSurface(
                //         child: MiniPlayer(
                //           song: song,
                //         ),
                //       );
                //     });
              },
              icon: const Icon(
                CupertinoIcons.chevron_down,
                color: CupertinoColors.white,
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
                                      maxHeight: 300, minHeight: 300),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: SingleChildScrollView(
                                          child: Scrollable(
                                            viewportBuilder:
                                                (context, viewportOffset) {
                                              return NotificationListener<
                                                  ScrollMetricsNotification>(
                                                child: FutureBuilder(
                                                    future: searchLyrics(
                                                        widget.song.id),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          snapshot.data!,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        );
                                                      } else if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Center(
                                                            child:
                                                                CupertinoActivityIndicator());
                                                      }
                                                      return const Text(
                                                          'No Lyrics Found!');
                                                    }),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 64, 77, 255),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _lyrics = !_lyrics;
                                          });
                                        },
                                        child: const Text(
                                          'Hide Lyrics',
                                          style: TextStyle(
                                              color: CupertinoColors.white),
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
                                      return const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.nosign,
                                            color: CupertinoColors.white,
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
                                    backgroundColor:
                                        const Color.fromARGB(255, 64, 77, 255),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _lyrics = !_lyrics;
                                    });
                                  },
                                  child: const Text(
                                    'Show Lyrics',
                                    style:
                                        TextStyle(color: CupertinoColors.white),
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
                        style: const TextStyle(
                          fontSize: 23,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.song.artists.join(", "),
                        style: const TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.inactiveGray,
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<DurationState>(
                    stream: _durationState.stream,
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
                          onSeek: player!.seek,
                          baseBarColor: CupertinoColors.inactiveGray,
                          progressBarColor: CupertinoColors.white,
                          bufferedBarColor: CupertinoColors.systemGrey,
                          thumbColor: CupertinoColors.white,
                          barHeight: 5.0,
                          thumbRadius: 8.0,
                          timeLabelLocation: TimeLabelLocation.sides,
                          timeLabelTextStyle:
                              const TextStyle(color: CupertinoColors.white),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_repeatMode == 0) {
                            setState(() {
                              _repeatMode = 1;
                            });
                            player!.setLoopMode(LoopMode.off);
                          } else if (_repeatMode == 1) {
                            setState(() {
                              _repeatMode = 2;
                            });
                            player!.setLoopMode(LoopMode.all);
                          } else {
                            setState(() {
                              _repeatMode = 0;
                            });
                            player!.setLoopMode(LoopMode.one);
                          }
                        },
                        icon: Icon(
                          _repeatMode == 0
                              ? CupertinoIcons.repeat
                              : _repeatMode == 1
                                  ? CupertinoIcons.repeat
                                  : CupertinoIcons.repeat_1,
                          color: _repeatMode == 0
                              ? CupertinoColors.white
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      IconButton(
                        onPressed: previousPlayback,
                        icon: const Icon(
                          CupertinoIcons.backward_fill,
                          color: CupertinoColors.white,
                          size: 35,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 64, 77, 255),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            bool isPlaying = ref.read(isPlayingProvider);
                            if (isPlaying) {
                              player!.pause();
                            } else {
                              player!.play();
                            }
                            ref.read(isPlayingProvider.notifier).state =
                                !isPlaying;
                          },
                          icon: Icon(
                            ref.watch(isPlayingProvider)
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                            color: CupertinoColors.white,
                            size: 35,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _shuffle ? shufflePlayback : nextPlayback,
                        icon: const Icon(
                          CupertinoIcons.forward_fill,
                          color: CupertinoColors.white,
                          size: 35,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            settings.put('shuffle', _shuffle == false ? 1 : 0);
                            _shuffle = !_shuffle;
                          });
                        },
                        icon: _shuffle == false
                            ? const Icon(
                                CupertinoIcons.shuffle,
                                color: CupertinoColors.white,
                              )
                            : const Icon(
                                CupertinoIcons.shuffle,
                                color: CupertinoColors.activeBlue,
                              ),
                      ),
                    ],
                  ),
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

  DurationState(
      {required this.progress, required this.buffered, required this.total});
}
