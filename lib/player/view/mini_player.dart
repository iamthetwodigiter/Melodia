import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/album/model/playlist_model.dart';

class MiniPlayer extends StatefulWidget {
  final String link;
  final String id;
  final String name;
  final String duration;
  final String imageUrl;
  final List<String> artists;
  final Playlist? playlistData;
  final int index;
  final bool shuffleMode;
  final AudioPlayer player;

  const MiniPlayer({
    super.key,
    required this.link,
    required this.id,
    required this.name,
    required this.duration,
    required this.imageUrl,
    required this.artists,
    this.playlistData,
    required this.index,
    required this.shuffleMode,
    required this.player,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    Box settings = Hive.box('settings');
    String playing = settings.get('playing');
    bool isPlaying = playing == 'false' ? false : true;
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              height: 60,
              placeholder: (context, url) {
                return const SizedBox(width: 60);
              },
              errorWidget: (context, url, error) {
                return const SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.nosign,
                        color: CupertinoColors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.artists.join(", "),
                  style: const TextStyle(fontSize: 13),
                  softWrap: true,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  isPlaying ? widget.player.pause() : widget.player.play();
                  setState(() {
                    isPlaying = !isPlaying;
                    settings.put('playing', isPlaying.toString());
                  });
                },
                icon: Icon(
                  isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  color: CupertinoColors.white,
                ),
              ),
              // IconButton(
              //   onPressed: () {
              //     ();
              //   },
              //   icon: Icon(
              //     CupertinoIcons.forward_end_fill,
              //     color: CupertinoColors.white,
              //   ),
              // ),
              IconButton(
                  onPressed: () {
                    widget.player.stop();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: CupertinoColors.white,
                  ))
            ],
          )
        ],
      ),
    );
  }
}
