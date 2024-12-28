import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/providers/play_me_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/player_screen.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class PlayMePage extends ConsumerStatefulWidget {
  const PlayMePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayMePageState();
}

class _PlayMePageState extends ConsumerState<PlayMePage> {
  @override
  Widget build(BuildContext context) {
    final playMe = ref.watch(playMeProvider);
    final playMeNotifier = ref.watch(playMeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "PlayMe",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              playMeNotifier.clearPlayMe();
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            playMe.isEmpty
                ? const Center(
                    child: Text(
                      'Go add something first',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/playlist_art.png',
                                height: 175,
                                width: 175,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${playMe.length.toString()} Songs\nAdded by user',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PlayerScreen(
                                              playlist: playMe,
                                              initialIndex: 0,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        iconColor: WidgetStatePropertyAll(
                                            AppTheme.accentColor(ref)),
                                        iconSize:
                                            const WidgetStatePropertyAll(25),
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                Color.fromARGB(
                                                    255, 35, 35, 35)),
                                        foregroundColor: WidgetStatePropertyAll(
                                            AppTheme.accentColor(ref)),
                                      ),
                                      child: const Text(
                                        'Play All',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: playMe.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: SongsListItem(
                                songsList: playMe,
                                song: playMe.elementAt(index),
                                index: index,
                                fromPlayMe: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            const MusicSlab()
          ],
        ),
      ),
    );
  }
}
