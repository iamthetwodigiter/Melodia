import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/downloads_page.dart';
import 'package:melodia/offline_music_slab.dart';
import 'package:melodia/player/view/mini_player.dart';
import 'package:melodia/playlist_items_page.dart';
import 'package:melodia/provider/dark_mode_provider.dart';
import 'package:melodia/provider/songs_notifier.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final playlistBox = Hive.box<Playlist>('playlist');
  late TextEditingController _playlistNameController;

  @override
  void initState() {
    super.initState();
    _playlistNameController = TextEditingController();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ref.watch(darkModeProvider);
    bool darkMode = Hive.box('settings').get('darkMode');
    final song = ref.watch(currentSongProvider);
    ref.watch(currentSongProvider);
    ref.watch(offlineSongProvider);
    final offlineSong = ref.watch(offlineSongProvider.notifier).state;

    return CupertinoPageScaffold(
        // backgroundColor: darkMode ? AppPallete.scaffoldDarkBackground : AppPallete.scaffoldBackgroundColor,
        navigationBar: const CupertinoNavigationBar(
          previousPageTitle: 'Playlist',
          middle: Text(
            'Library',
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  height: song == null && offlineSong == null
                      ? size.height * 0.852
                      : (size.height * 0.875) - 85,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Playlist',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: AppPallete().accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: const Text('New Playlist'),
                                        content: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            CupertinoTextField(
                                              controller:
                                                  _playlistNameController,
                                              placeholder:
                                                  'Enter playlist name',
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: CupertinoColors
                                                      .destructiveRed),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: const Text('Create'),
                                            onPressed: () {
                                              if (_playlistNameController
                                                      .text.isNotEmpty &&
                                                  !playlistBox.keys.contains(
                                                      _playlistNameController
                                                          .text)) {
                                                playlistBox.put(
                                                  _playlistNameController.text,
                                                  Playlist(
                                                    idList: [],
                                                    linkList: [],
                                                    imageUrlList: [],
                                                    nameList: [],
                                                    artistsList: [],
                                                    durationList: [],
                                                  ),
                                                );
                                                setState(() {});
                                                _playlistNameController.clear();
                                                Navigator.of(context).pop();
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  CupertinoIcons.add_circled_solid,
                                  color: AppPallete().accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: CupertinoColors.destructiveRed,
                                width: 0.5,
                              ),
                            ),
                            height: 75,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => const DownloadsPage(),
                                  ),
                                );
                              },
                              child: const CupertinoListTile(
                                  padding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.download_rounded,
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                  title: Text(
                                    'Downloads',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.destructiveRed,
                                      fontSize: 20,
                                    ),
                                  ),
                                  subtitle: Text('Offline Songs')),
                            ),
                          ),
                        ),
                        playlistBox.isNotEmpty
                            ? SizedBox(
                                height: size.height * 0.78,
                                child: CustomScrollView(
                                  slivers: [
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: playlistBox.keys
                                                              .elementAt(
                                                                  index) ==
                                                          'Favorites'
                                                      ? CupertinoColors
                                                          .destructiveRed
                                                      : AppPallete()
                                                          .accentColor,
                                                  width: 0.5,
                                                ),
                                              ),
                                              height: 75,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          PlaylistItemsPage(
                                                        name: playlistBox.keys
                                                            .elementAt(index),
                                                        playlistData:
                                                            playlistBox.values
                                                                .elementAt(
                                                                    index),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: CupertinoListTile(
                                                  padding: EdgeInsets.zero,
                                                  leading: Icon(
                                                    playlistBox.keys.elementAt(
                                                                index) ==
                                                            'Favorites'
                                                        ? CupertinoIcons
                                                            .heart_fill
                                                        : CupertinoIcons
                                                            .music_note_list,
                                                    color: playlistBox.keys
                                                                .elementAt(
                                                                    index) ==
                                                            'Favorites'
                                                        ? CupertinoColors
                                                            .destructiveRed
                                                        : AppPallete()
                                                            .accentColor,
                                                  ),
                                                  title: Text(
                                                    playlistBox.keys
                                                        .elementAt(index),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: playlistBox.keys
                                                                  .elementAt(
                                                                      index) ==
                                                              'Favorites'
                                                          ? CupertinoColors
                                                              .destructiveRed
                                                          : darkMode
                                                              ? AppPallete
                                                                  .subtitleDarkTextColor
                                                              : AppPallete()
                                                                  .subtitleTextColor,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  // subtitle: Text('Melodia Playlist'),
                                                  subtitle: Text(
                                                      '${playlistBox.values.elementAt(index).idList.length} Songs'),
                                                  trailing: playlistBox.keys
                                                              .elementAt(
                                                                  index) ==
                                                          'Favorites'
                                                      ? const Text('')
                                                      : IconButton(
                                                          onPressed: () {
                                                            playlistBox.delete(
                                                                playlistBox.keys
                                                                    .elementAt(
                                                                        index));
                                                            setState(() {});
                                                          },
                                                          icon: Icon(
                                                            CupertinoIcons
                                                                .delete_solid,
                                                            color: AppPallete()
                                                                .accentColor,
                                                          )),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: playlistBox
                                            .length, // Update this with your actual item count
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: size.height * 0.78,
                                child: Center(
                                  child: Text(
                                    'No Playlist exists\nTry Creating One',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: AppPallete().subtitleTextColor,
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ),
              song != null
                  ? Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.zero,
                      height: size.height * 0.075,
                      child: const MiniPlayer(),
                    )
                  : offlineSong != null
                      ? SizedBox(
                          height: 65,
                          child: OfflineMusicSlab(
                            song: ref.watch(offlineSongProvider)!,
                          ),
                        )
                      : const SizedBox(),
            ],
          ),
        ));
  }
}
