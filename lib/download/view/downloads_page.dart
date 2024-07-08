import 'dart:io';
import 'dart:typed_data';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/view/offline_music_player.dart';
import 'package:melodia/player/view/offline_music_slab.dart';
import 'package:melodia/player/model/offline_song_model.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/files_provider.dart';
import 'package:melodia/provider/songs_notifier.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  Directory downloadsDir = Directory('storage/emulated/0/Music/Melodia');
  List<File> _files = [];
  List<Uint8List?> thumbList = [];
  final tagger = Audiotagger();
  List<Tag?> tags = [];

  @override
  void initState() {
    super.initState();
    _listFiles();
    for (var items in _files) {
      getArtwork(items.path);
      getMetadata(items.path);
    }
  }

  void _showAlertDialog(BuildContext context, File file) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure to delete?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              file.delete();
              ref
                  .watch(filesProvider.notifier)
                  .state!
                  .removeWhere((element) => element == file);
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void deleteAll(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure to delete all the downloaded songs?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Directory('storage/emulated/0/Music/Melodia')
                  .deleteSync(recursive: true);
                  ref.watch(filesProvider.notifier).state = [];
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void getArtwork(String filePath) async {
    Uint8List? artwork = await tagger.readArtwork(path: filePath);
    if (artwork == null) {
      thumbList.add(Uint8List(1));
    }
    thumbList.add(artwork);
    setState(() {});
  }

  void getMetadata(String filePath) async {
    Tag? tag = await tagger.readTags(path: filePath);
    tags.add(tag);
    setState(() {});
  }

  void _listFiles() async {
    final List<FileSystemEntity> entities = downloadsDir.listSync().toList();
    _files = entities.whereType<File>().toList();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final offlineSong = ref.watch(offlineSongProvider);
    ref.watch(filesProvider);
    Future.delayed(
      const Duration(milliseconds: 100),
      () => ref.read(filesProvider.notifier).state = _files,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Library',
        middle: Text(
          'Downloads',
          style: TextStyle(
            color: darkMode ? CupertinoColors.white : AppPallete().accentColor,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: offlineSong == null
                    ? size.height * 0.9
                    : size.height * 0.9 - 68,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Downloaded Songs',
                              style: TextStyle(
                                fontSize: 25,
                                color: AppPallete().accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteAll(context);
                                setState(() {});
                              },
                              icon: Icon(
                                CupertinoIcons.delete_solid,
                                color: AppPallete().accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _files.isEmpty
                        ? SliverToBoxAdapter(
                            child: Container(
                              height: size.height * 0.7,
                              alignment: Alignment.center,
                              child: Text(
                                'No Downloads',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: AppPallete().accentColor,
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CupertinoListTile(
                                      onTap: () {
                                        ref
                                            .watch(currentSongProvider.notifier)
                                            .state = null;
                                        ref
                                            .watch(isMinimisedProvider.notifier)
                                            .state = false;
                                        final offlineSong = OfflineSongModel(
                                          songList: _files,
                                          thumbList: thumbList,
                                          index: index,
                                          tags: tags,
                                        );
                                        ref
                                            .watch(offlineSongProvider.notifier)
                                            .state = offlineSong;
                                        Navigator.of(context).push(
                                          CustomPageRoute(
                                            page: OfflineMusicPlayer(
                                              song: offlineSong,
                                            ),
                                          ),
                                        );
                                      },
                                      backgroundColor: AppPallete()
                                          .accentColor
                                          .withAlpha(20),
                                      padding: const EdgeInsets.all(20),
                                      leading: Image.memory(
                                        thumbList[index]!,
                                        height: 100,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/song_thumb.png',
                                            height: 150,
                                          );
                                        },
                                      ),
                                      title: Text(
                                        _files[index]
                                            .path
                                            .toString()
                                            .replaceAll(
                                                'storage/emulated/0/Music/Melodia/',
                                                '')
                                            .replaceAll('.m4a', ''),
                                        style: TextStyle(
                                            color: darkMode
                                                ? CupertinoColors.white
                                                : AppPallete().accentColor),
                                      ),
                                      subtitle: Text(
                                        tags[index]!.artist!,
                                        style: TextStyle(
                                          color: darkMode
                                              ? CupertinoColors.white
                                              : AppPallete().accentColor,
                                        ),
                                        maxLines: 1,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {
                                          _showAlertDialog(
                                              context, _files[index]);
                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          CupertinoIcons.delete_solid,
                                          color: CupertinoColors.destructiveRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _files.length,
                            ),
                          ),
                  ],
                ),
              ),
              offlineSong != null
                  ? SizedBox(
                      height: 65,
                      child: OfflineMusicSlab(
                        song: offlineSong,
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
