import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/songs_notifier.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  final SongModel? song;
  const MiniPlayer({
    super.key,
    this.song,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    Box settings = Hive.box('settings');
    final song = settings.get('currentSong');
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: widget.song!.imageUrl,
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
                  widget.song!.name,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.song!.artists.join(", "),
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
                  bool isPlaying = ref.read(isPlayingProvider);
                  if (isPlaying) {
                    widget.song!.player!.pause();
                  } else {
                    widget.song!.player!.play();
                  }
                  ref.read(isPlayingProvider.notifier).state = !isPlaying;
                },
                icon: Icon(
                  ref.watch(isPlayingProvider)
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  color: CupertinoColors.white,
                  size: 35,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.song!.player!.stop();
                  settings.put('currentSong', null);
                },
                icon: const Icon(
                  Icons.close,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
