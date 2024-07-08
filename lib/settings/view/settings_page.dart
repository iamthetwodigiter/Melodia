import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/about/view/about.dart';
import 'package:melodia/constants/constants.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/core/update_checker.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/dark_mode_provider.dart';
import 'package:melodia/settings/view/theming_card.dart';
import 'package:url_launcher/url_launcher.dart';

const List<String> qualityList = <String>[
  '12',
  '48',
  '96',
  '160',
  '320',
];

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
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
    bool suggestion = settings.get('suggestions');
    String cache = settings.get('cache_songs');
    bool switchValue = (shuffle == 0) ? false : true;
    ref.watch(darkModeProvider);
    bool darkMode = settings.get('darkMode');
    Directory cacheDir = Directory(
        '/data/user/0/com.thetwodigiter.melodia/cache/just_audio_cache/');

    final Uri url = Uri.parse('https://www.github.com/iamthetwodigiter');

    Future<void> launchtheurl() async {
      if (!await launchUrl(url)) {
        throw 'Could not launch $url';
      }
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Back',
        middle: Text(
          'Settings',
          style: TextStyle(
            color: darkMode ? CupertinoColors.white : AppPallete().accentColor,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: CupertinoListSection(
                            backgroundColor: darkMode
                                ? AppPallete.scaffoldDarkBackground
                                : AppPallete.scaffoldBackgroundColor,
                            topMargin: 0,
                            children: [
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const ThemeSettings(),
                                    ),
                                  );
                                },
                                leading: Icon(
                                  CupertinoIcons.app_badge_fill,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Theme',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Make the app your own',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                                trailing: const CupertinoListTileChevron(),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  _showDialog(
                                    CupertinoPicker(
                                      backgroundColor: darkMode
                                          ? AppPallete.scaffoldDarkBackground
                                          : AppPallete.scaffoldBackgroundColor,
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32,
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem: qualityList
                                            .indexOf(downloadQuality),
                                      ),
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                        settings.put('download_quality',
                                            qualityList[selectedItem]);
                                        setState(() {
                                          downloadQuality =
                                              qualityList[selectedItem];
                                        });
                                      },
                                      children: List.generate(
                                        qualityList.length,
                                        (int index) {
                                          return Center(
                                            child: Text(
                                              '${qualityList[index]} kbps',
                                              style: TextStyle(
                                                color: darkMode
                                                    ? CupertinoColors.white
                                                    : AppPallete().accentColor,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                leading: Icon(
                                  CupertinoIcons.cloud_download_fill,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Download',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Choose Download Quality',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                                additionalInfo: Text(
                                  '$downloadQuality kbps',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: AppPallete().accentColor),
                                ),
                                trailing: const CupertinoListTileChevron(),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  _showDialog(
                                    CupertinoPicker(
                                      backgroundColor: darkMode
                                          ? AppPallete.scaffoldDarkBackground
                                          : AppPallete.scaffoldBackgroundColor,
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32,
                                      // This sets the initial item.
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem: qualityList
                                            .indexOf(streamingQuality),
                                      ),
                                      // This is called when selected item is changed.
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                        settings.put(
                                            'streaming_quality',
                                            qualityList[selectedItem]
                                                .toString());
                                        setState(() {
                                          streamingQuality =
                                              qualityList[selectedItem];
                                        });
                                      },
                                      children: List<Widget>.generate(
                                        qualityList.length,
                                        (int index) {
                                          return Center(
                                            child: Text(
                                              '${qualityList[index]} kbps',
                                              style: TextStyle(
                                                color: darkMode
                                                    ? CupertinoColors.white
                                                    : AppPallete().accentColor,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                leading: Icon(
                                  CupertinoIcons.music_note,
                                  color: AppPallete().accentColor,
                                  size: 20,
                                ),
                                title: Text(
                                  'Streaming',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Choose Streaming Quality',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                                additionalInfo: Text(
                                  '$streamingQuality kbps',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: AppPallete().accentColor),
                                ),
                                trailing: const CupertinoListTileChevron(),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                leading: Icon(
                                  CupertinoIcons.shuffle,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Keep Shuffle Mode On',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                trailing: CupertinoSwitch(
                                  value: switchValue,
                                  activeColor: AppPallete().accentColor,
                                  onChanged: (bool value) {
                                    settings.put(
                                        'shuffle', shuffle == 0 ? 1 : 0);
                                    setState(() {
                                      switchValue = !switchValue;
                                    });
                                  },
                                ),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                leading: Icon(
                                  CupertinoIcons.music_note_2,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Play Suggestions?',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Play suggested songs at the end of Playlist',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                                trailing: CupertinoSwitch(
                                  value: suggestion,
                                  activeColor: AppPallete().accentColor,
                                  onChanged: (bool value) {
                                    settings.put('suggestions', !suggestion);
                                    setState(() {
                                      suggestion = !suggestion;
                                    });
                                  },
                                ),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                leading: Icon(
                                  CupertinoIcons.folder_fill,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Cache Songs?',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Will take up storage space  [Experimental]',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                                trailing: CupertinoSwitch(
                                  value: cache == 'false' ? false : true,
                                  activeColor: AppPallete().accentColor,
                                  onChanged: (bool value) {
                                    settings.put('cache_songs',
                                        cache == 'false' ? 'true' : 'false');
                                    setState(() {
                                      cache == 'false' ? true : false;
                                    });
                                  },
                                ),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
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
                                title: Text(
                                  'Clear Songs Cache',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Does the magic silently...  [Experimental]',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  try {
                                    final historyBox =
                                        Hive.box<SongModel>('history');
                                    for (var items in historyBox.keys) {
                                      historyBox.delete(items);
                                    }
                                    Phoenix.rebirth(context);
                                  } catch (e) {
                                    rethrow;
                                  }
                                },
                                leading: Icon(
                                  CupertinoIcons.delete_solid,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Clear Last Played History',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                subtitle: Text(
                                  'Will force restart the app',
                                  style: TextStyle(
                                      color: darkMode
                                          ? AppPallete.subtitleDarkTextColor
                                          : AppPallete().subtitleTextColor),
                                ),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => const AboutPage(),
                                    ),
                                  );
                                },
                                leading: Icon(
                                  CupertinoIcons.question_square_fill,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'About',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                trailing: const CupertinoListTileChevron(),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  UpdateChecker().checkForUpdates(context);
                                },
                                leading: Icon(
                                  CupertinoIcons.app_badge_fill,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Check for Updates',
                                  style: TextStyle(
                                      color: AppPallete().accentColor),
                                ),
                                trailing: const CupertinoListTileChevron(),
                              ),
                              CupertinoListTile(
                                backgroundColor: darkMode
                                    ? AppPallete.scaffoldDarkBackground
                                    : AppPallete.scaffoldBackgroundColor,
                                padding: const EdgeInsets.all(15),
                                onTap: () {
                                  launchUrl(Uri.parse(
                                      'https://t.me/melodia_support_group'));
                                },
                                leading: Icon(
                                  CupertinoIcons.person_2_alt,
                                  color: AppPallete().accentColor,
                                  size: 15,
                                ),
                                title: Text(
                                  'Support Group',
                                  style: TextStyle(
                                    color: AppPallete().accentColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Join the support group to report bugs or request features',
                                  style: TextStyle(
                                    color: AppPallete().accentColor,
                                  ),
                                ),
                                trailing: const CupertinoListTileChevron(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Melodia ${Constants.appVersion}',
                                  style: TextStyle(
                                      color: darkMode
                                          ? CupertinoColors.white
                                          : AppPallete().accentColor),
                                ),
                                TextSpan(
                                  text: ' \nCreated with ',
                                  style: TextStyle(
                                      color: darkMode
                                          ? CupertinoColors.white
                                          : AppPallete().accentColor),
                                ),
                                const WidgetSpan(
                                  child: Icon(
                                    CupertinoIcons.heart_solid,
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                ),
                                TextSpan(
                                  text: ' by ',
                                  style: TextStyle(
                                      color: darkMode
                                          ? CupertinoColors.white
                                          : AppPallete().accentColor),
                                ),
                                TextSpan(
                                  text: 'thetwodigiter',
                                  style: TextStyle(
                                    color: AppPallete().accentColor,
                                    fontSize: 18,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      launchtheurl();
                                    },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100,),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
