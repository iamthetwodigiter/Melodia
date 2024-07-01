import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/settings/view/theming_card.dart';

const List<String> qualityList = <String>[
  '96',
  '160',
  '320',
];

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  // Future<int> getFolderSize(String directoryPath) async {
  //   final directory = Directory(directoryPath);
  //   int totalSize = 0;

  //   await for (final entity in directory.list(recursive: true)) {
  //     if (entity is File) {
  //       final file = entity;
  //       final fileStat = await file.stat();
  //       totalSize += fileStat.size;
  //     }
  //   }

  //   return totalSize;
  // }

  @override
  Widget build(BuildContext context) {
    Box settings = Hive.box('settings');
    String downloadQuality = settings.get('download_quality');
    String streamingQuality = settings.get('streaming_quality');
    int shuffle = settings.get('shuffle');
    String cache = settings.get('cache_songs');
    bool switchValue = (shuffle == 0) ? false : true;
    Directory cacheDir = Directory(
        '/data/user/0/com.thetwodigiter.melodia/cache/just_audio_cache/');
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CupertinoNavigationBar(
              previousPageTitle: 'Home',
              middle: Text(
                'Settings',
                style: TextStyle(color: AppPallete().accentColor),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: CupertinoListSection(
                children: [
                  CupertinoListTile(
                    padding: const EdgeInsets.all(15),
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => const ThemeSettings()));
                    },
                    leading: Icon(
                      CupertinoIcons.app_badge_fill,
                      color: AppPallete().accentColor,
                      size: 15,
                    ),
                    title: const Text('Theme'),
                    subtitle: const Text('Make the app your own'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    padding: const EdgeInsets.all(15),
                    onTap: () {
                      _showDialog(
                        CupertinoPicker(
                          magnification: 1.22,
                          squeeze: 1.2,
                          useMagnifier: true,
                          itemExtent: 32,
                          // This sets the initial item.
                          scrollController: FixedExtentScrollController(
                            initialItem: qualityList.indexOf(downloadQuality),
                          ),
                          // This is called when selected item is changed.
                          onSelectedItemChanged: (int selectedItem) {
                            settings.put(
                                'download_quality', qualityList[selectedItem]);
                            setState(() {
                              downloadQuality = qualityList[selectedItem];
                            });
                          },
                          children: List<Widget>.generate(qualityList.length,
                              (int index) {
                            return Center(
                                child: Text('${qualityList[index]} kbps'));
                          }),
                        ),
                      );
                    },
                    leading: Icon(
                      CupertinoIcons.cloud_download_fill,
                      color: AppPallete().accentColor,
                      size: 15,
                    ),
                    title: const Text('Download'),
                    subtitle: const Text('Choose Download Quality'),
                    additionalInfo: Text('$downloadQuality kbps'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    padding: const EdgeInsets.all(15),
                    onTap: () {
                      _showDialog(
                        CupertinoPicker(
                          magnification: 1.22,
                          squeeze: 1.2,
                          useMagnifier: true,
                          itemExtent: 32,
                          // This sets the initial item.
                          scrollController: FixedExtentScrollController(
                            initialItem: qualityList.indexOf(streamingQuality),
                          ),
                          // This is called when selected item is changed.
                          onSelectedItemChanged: (int selectedItem) {
                            settings.put('streaming_quality',
                                qualityList[selectedItem].toString());
                            setState(() {
                              streamingQuality = qualityList[selectedItem];
                            });
                          },
                          children: List<Widget>.generate(qualityList.length,
                              (int index) {
                            return Center(
                                child: Text('${qualityList[index]} kbps'));
                          }),
                        ),
                      );
                    },
                    leading: Icon(
                      CupertinoIcons.music_note,
                      color: AppPallete().accentColor,
                      size: 20,
                    ),
                    title: const Text('Streaming'),
                    subtitle: const Text('Choose Streaming Quality'),
                    additionalInfo: Text('$streamingQuality kbps'),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    padding: const EdgeInsets.all(15),
                    leading: Icon(
                      CupertinoIcons.shuffle,
                      color: AppPallete().accentColor,
                      size: 15,
                    ),
                    title: const Text('Keep Shuffle Mode On'),
                    trailing: CupertinoSwitch(
                      value: switchValue,
                      activeColor: AppPallete().accentColor,
                      onChanged: (bool value) {
                        settings.put('shuffle', shuffle == 0 ? 1 : 0);
                        setState(() {
                          switchValue = !switchValue;
                        });
                      },
                    ),
                  ),
                  CupertinoListTile(
                    padding: const EdgeInsets.all(15),
                    leading: Icon(
                      CupertinoIcons.folder_fill,
                      color: AppPallete().accentColor,
                      size: 15,
                    ),
                    title: const Text('Cache Songs?'),
                    subtitle: const Text(
                        'Will take up storage space  [Experimental]'),
                    trailing: CupertinoSwitch(
                      value: cache == 'false' ? false : true,
                      activeColor: AppPallete().accentColor,
                      onChanged: (bool value) {
                        settings.put(
                            'cache_songs', cache == 'false' ? 'true' : 'false');
                        setState(() {
                          cache == 'false' ? true : false;
                        });
                      },
                    ),
                  ),
                  CupertinoListTile(
                    padding: const EdgeInsets.all(15),
                    onTap: () async {
                      // final x = await getFolderSize(cacheDir.path);

                      try {
                        cacheDir.delete();
                        AudioPlayer.clearAssetCache();
                      } catch (e) {
                        rethrow;
                      }
                    },
                    leading: Icon(
                      CupertinoIcons.delete_solid,
                      color: AppPallete().accentColor,
                      size: 15,
                    ),
                    title: const Text('Clear Songs Cache'),
                    subtitle: const Text(
                        'Does the magic silently...  [Experimental]'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
