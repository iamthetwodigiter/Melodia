import 'dart:async';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/player/model/api_calls.dart';

class MusicPlayer extends StatefulWidget {
  final String link;
  final String id;
  final String name;
  final String duration;
  final String imageUrl;
  final List<String> artists;
  final Playlist? playlistData;
  final int index;

  const MusicPlayer({
    super.key,
    required this.link,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.duration,
    required this.artists,
    this.playlistData,
    required this.index,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

Box settings = Hive.box('settings');
String downloadQuality = settings.get('download_quality');
String streamingQuality = settings.get('streaming_quality');

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  final _durationState = StreamController<DurationState>();
  bool _isPlaying = true;
  bool _lyrics = false;
  bool _shuffleMode = false;
  int _repeatMode = 0;

  @override
  void initState() {
    super.initState();
    player.setUrl(widget.link.replaceAll('320', streamingQuality));

    player.play();
    _updateDurationState();
  }

  void _updateDurationState() {
    player.positionStream.listen((position) {
      _durationState.add(
        DurationState(
          progress: position,
          buffered: player.bufferedPosition,
          total: Duration(seconds: int.parse(widget.duration)),
        ),
      );
    });
  }

  @override
  void dispose() {
    player.dispose();
    _durationState.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // navigationBar: CupertinoNavigationBar(
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: const Icon(
      //       Icons.keyboard_double_arrow_down_rounded,
      //       color: CupertinoColors.white,
      //       size: 25,
      //     ),
      //   ),
      //   trailing: Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       IconButton(
      //         onPressed: () {
      //           setState(() {
      //             _lyrics = !_lyrics;
      //           });
      //         },
      //         icon: const Icon(
      //           Icons.lyrics_rounded,
      //           color: CupertinoColors.white,
      //           size: 25,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(20),
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
                            constraints: const BoxConstraints(maxHeight: 300, minHeight: 300),
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
                                              future: searchLyrics(widget.id),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    snapshot.data!,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  );
                                                } else if (snapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
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
                                        255, 129, 127, 255),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _lyrics = !_lyrics;
                                    });
                                  },
                                  child: const Text(
                                    'Hide Lyrics',
                                    style:
                                        TextStyle(color: CupertinoColors.white),
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
                              imageUrl: widget.imageUrl,
                              height: 300,
                              errorWidget: (context, url, error) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.nosign,
                                      color: CupertinoColors.white,
                                      size: 40,
                                    ),
                                    SizedBox(height: 10),
                                    Text('Thumbnail not available!!'),
                                  ],
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 129, 127, 255),
                            ),
                            onPressed: () {
                              setState(() {
                                _lyrics = !_lyrics;
                              });
                            },
                            child: const Text(
                              'Show Lyrics',
                              style: TextStyle(color: CupertinoColors.white),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(
              child: Column(
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.artists.join(', '),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _shuffleMode = !_shuffleMode;
                          });
                          player.setShuffleModeEnabled(_shuffleMode);
                        },
                        icon: Icon(CupertinoIcons.shuffle,
                            color: _shuffleMode
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          player.seekToPrevious();
                        },
                        icon: const Icon(CupertinoIcons.backward_end_fill,
                            size: 30, color: CupertinoColors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          _isPlaying ? player.pause() : player.play();
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                        icon: Icon(
                            !_isPlaying
                                ? CupertinoIcons.play_circle_fill
                                : CupertinoIcons.pause_circle_fill,
                            size: 60,
                            color: CupertinoColors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          player.seekToNext();

                          int index = widget.index;
                          setState(() {
                            index = (index + 1);
                          });

                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => MusicPlayer(
                                link: widget.playlistData!.linkList
                                    .elementAt(index),
                                id: widget.playlistData!.idList
                                    .elementAt(index),
                                name: widget.playlistData!.nameList
                                    .elementAt(index)
                                    .split('(')[0],
                                imageUrl: widget.playlistData!.imageUrlList
                                    .elementAt(index),
                                duration: widget.playlistData!.durationList
                                    .elementAt(index),
                                artists: widget.playlistData!.artistsList
                                    .elementAt(index),
                                playlistData: widget.playlistData,
                                index: index++,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          CupertinoIcons.forward_end_fill,
                          size: 30,
                          color: CupertinoColors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _repeatMode = (_repeatMode + 1) % 3;
                          });
                          player.setLoopMode(
                            _repeatMode == 0
                                ? LoopMode.off
                                : (_repeatMode == 1
                                    ? LoopMode.all
                                    : LoopMode.one),
                          );
                        },
                        icon: Icon(
                            _repeatMode == 2
                                ? CupertinoIcons.repeat_1
                                : CupertinoIcons.repeat,
                            color: _repeatMode == 0
                                ? CupertinoColors.white
                                : CupertinoColors.activeBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder(
                    stream: _durationState.stream,
                    builder: (context, snapshot) {
                      final durationState = snapshot.data;
                      final progress = durationState?.progress ?? Duration.zero;
                      final buffered = durationState?.buffered ?? Duration.zero;
                      final total =
                          Duration(seconds: int.parse(widget.duration));

                      return ProgressBar(
                        progress: progress,
                        buffered: buffered,
                        total: total,
                        onSeek: (duration) {
                          player.seek(duration);
                        },
                        timeLabelType: TimeLabelType.totalTime,
                        timeLabelTextStyle:
                            const TextStyle(color: CupertinoColors.white),
                        timeLabelPadding: 5,
                        progressBarColor: CupertinoColors.white,
                        baseBarColor:
                            CupertinoColors.lightBackgroundGray.withAlpha(120),
                        bufferedBarColor: CupertinoColors.activeBlue,
                        thumbRadius: 0,
                      );
                    },
                  ),
                  // const Spacer(),
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
  const DurationState({
    required this.progress,
    required this.buffered,
    required this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
