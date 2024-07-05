import 'dart:io';
import 'dart:typed_data';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/offline_music_player.dart';
import 'package:melodia/offline_music_slab.dart';
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
  List<Uint8List?> _thumbList = [];
  final tagger = Audiotagger();
  List<Tag?> _tags = [];

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

  void getArtwork(String filePath) async {
    Uint8List? artwork = await tagger.readArtwork(path: filePath);
    if (artwork == null) {
      _thumbList.add(Uint8List(1));
    }
    _thumbList.add(artwork);
    setState(() {});
  }

  void getMetadata(String filePath) async {
    Tag? tag = await tagger.readTags(path: filePath);
    _tags.add(tag);
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
      child: Column(
        children: [
          Container(
            height:
                offlineSong == null ? size.height * 0.9 : size.height * 0.82,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Downloaded Songs',
                      style: TextStyle(
                        fontSize: 25,
                        color: AppPallete().accentColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                                    final offlineSong = OfflineSongModel(
                                        songList: _files,
                                        thumbList: _thumbList,
                                        index: index,
                                        tags: _tags);
                                    ref
                                        .watch(offlineSongProvider.notifier)
                                        .state = offlineSong;
                                    Navigator.of(context).push(
                                      CustomPageRoute(
                                        page: OfflineMusicPlayer(
                                            song: offlineSong),
                                      ),
                                    );
                                  },
                                  backgroundColor:
                                      AppPallete().accentColor.withAlpha(20),
                                  padding: const EdgeInsets.all(20),
                                  leading: Image.memory(
                                    _thumbList[index]!,
                                    height: 100,
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
                                  trailing: IconButton(
                                    onPressed: () {
                                      _showAlertDialog(context, _files[index]);
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
    );
  }
}
