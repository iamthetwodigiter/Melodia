import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/core/app_theme.dart';
import 'package:melodia/home/view/homepage.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/dark_mode_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.thetwodigiter.melodia.bgplayback',
    androidNotificationChannelName: 'Background Playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(SongModelAdapter());
  Box settings = await Hive.openBox('settings');
  await Hive.deleteBoxFromDisk('history');
  await Hive.openBox<SongModel>('history');
  if (Hive.box('settings').isEmpty) {
    settings.put('download_quality', '320');
    settings.put('streaming_quality', '320');
    settings.put('shuffle', 0);
    settings.put('cache_songs', 'false');
    settings.put('darkMode', true);
    settings.put('accent_color', [255, 255, 255, 255]);
    settings.put('currentSong', null);
    settings.put('download_path',
        '${(await getExternalStorageDirectory())!.path}/Melodia');
  }

  if (Platform.isAndroid) {
    if (await Permission.storage.request().isDenied) {
      Permission.manageExternalStorage.request();
    }
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool darkMode = ref.watch(darkModeProvider);
    return CupertinoApp(
      home: const HomePage(),
      theme: darkMode
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
