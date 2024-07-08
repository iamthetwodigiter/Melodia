import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/songs_notifier.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(currentSongProvider);
    bool isPlaying = ref.watch(audioServiceProvider.notifier)!.player.playing;
    final audioService = ref.watch(audioServiceProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppPallete().accentColor, width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        child: CupertinoListTile(
          onTap: () {
            ref.read(isMinimisedProvider.notifier).state = false;

            Navigator.of(context).push(
              CustomPageRoute(
                page: MusicPlayer(song: song),
              ),
            );
          },
          leading: CachedNetworkImage(
            imageUrl: song!.imageUrl,
            height: 60,
            placeholder: (context, url) {
              return const SizedBox(width: 60);
            },
            errorWidget: (context, url, error) {
              return SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.nosign,
                      color: AppPallete().accentColor,
                    ),
                  ],
                ),
              );
            },
          ),
          backgroundColor: AppPallete().accentColor.withAlpha(20),
          padding: const EdgeInsets.all(10),
          title: Text(
            song.name,
            style: TextStyle(
              color: AppPallete().accentColor,
            ),
            maxLines: 1,
          ),
          subtitle: Text(
            song.artists.join(", "),
            style: TextStyle(
              color: AppPallete().accentColor,
            ),
            maxLines: 1,
          ),
          trailing: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (isPlaying) {
                    audioService!.pause();
                  } else {
                    audioService!.play();
                  }
                },
                icon: Icon(
                  isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  color: AppPallete().accentColor,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  ref.read(currentSongProvider.notifier).state = null;
                },
                icon: Icon(
                  CupertinoIcons.multiply,
                  color: AppPallete().accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
