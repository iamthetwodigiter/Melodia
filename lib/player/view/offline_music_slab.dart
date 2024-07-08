import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/view/offline_music_player.dart';
import 'package:melodia/player/model/offline_song_model.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/songs_notifier.dart';

class OfflineMusicSlab extends ConsumerStatefulWidget {
  final OfflineSongModel song;
  const OfflineMusicSlab({super.key, required this.song});

  @override
  ConsumerState<OfflineMusicSlab> createState() => _OfflineMusicSlabState();
}

class _OfflineMusicSlabState extends ConsumerState<OfflineMusicSlab> {
  @override
  Widget build(BuildContext context) {
    final index = widget.song.index;
    final name = widget.song.songList
        .elementAt(index)
        .path
        .toString()
        .replaceAll("storage/emulated/0/Music/Melodia/", "")
        .replaceAll(".m4a", "");
    final thumb = widget.song.thumbList.elementAt(index);
    final tag = widget.song.tags.elementAt(index);
    bool isPlaying = ref.watch(offlineAudioServiceProvider)!.player.playing;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppPallete().accentColor, width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        child: CupertinoListTile(
          onTap: () {
            Navigator.push(
              context,
              CustomPageRoute(
                page: OfflineMusicPlayer(
                  song: widget.song,
                ),
              ),
            );
          },
          backgroundColor: AppPallete().accentColor.withAlpha(20),
          padding: const EdgeInsets.all(10),
          leading: Image.memory(
            thumb!,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/song_thumb.png',
              );
            },
          ),
          title: Text(
            name,
            style: TextStyle(
              color: AppPallete().accentColor,
            ),
            maxLines: 1,
          ),
          subtitle: Text(
            tag!.artist!,
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
                  isPlaying
                      ? ref.watch(offlineAudioServiceProvider)!.pause()
                      : ref.watch(offlineAudioServiceProvider)!.play();
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
                  ref.watch(offlineSongProvider.notifier).state = null;
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
