import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/constants/constants.dart';
import 'package:melodia/core/app_theme.dart';
import 'package:melodia/core/landing_screen.dart';
import 'package:melodia/notifications/notification.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/provider/dark_mode_provider.dart';
import 'package:melodia/core/setup_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    bool isNewUpdateAvailable = await checkForUpdates();

    if (isNewUpdateAvailable) {
      await sendNotificationToUsers('New update available! Check it out.');
    }

    return Future.value(true);
  });
}

Future<bool> checkForUpdates() async {
  const githubRepoApiUrl =
      'https://api.github.com/repos/iamthetwodigiter/melodia/releases/latest';

  try {
    final response = await http.get(Uri.parse(githubRepoApiUrl));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String latestVersion = jsonResponse['tag_name'];
      if (latestVersion != Constants.appVersion) {
        return true;
      }
    }
  } catch (e) {
    print('Error checking GitHub releases: $e');
  }

  return false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  OneSignal.initialize(Constants.oneSignalAppID);
  OneSignal.Notifications.requestPermission(true);
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'checkForUpdatesTask',
    'checkForUpdates',
    frequency: const Duration(hours: 24),
  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.thetwodigiter.melodia.bgplayback',
    androidNotificationChannelName: 'Background Playback',
    androidNotificationOngoing: true,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Box settings = await Hive.openBox('settings');
  await Hive.openBox<SongModel>('history');
  Box<Playlist> playlistBox = await Hive.openBox<Playlist>('playlist');
  if (playlistBox.isEmpty) {
    playlistBox.put(
      'Favorites',
      Playlist(
        idList: ['YocwhRar'],
        linkList: [
          'https://aac.saavncdn.com/473/25c0567685e233487df2a9050478a3f8_320.mp4'
        ],
        imageUrlList: [
          'https://c.saavncdn.com/artists/Lord_Huron_20200218144732_500x500.jpg'
        ],
        nameList: ["The Night We Met"],
        artistsList: [
          ["Lord Huron"]
        ],
        durationList: ['208'],
      ),
    );
  }
  await Hive.openBox<String>('search_history');

  if (Hive.box('settings').isEmpty) {
    settings.put('download_quality', '320');
    settings.put('streaming_quality', '320');
    settings.put('shuffle', 0);
    settings.put('cache_songs', 'false');
    settings.put('darkMode',
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    settings.put('accent_color', [255, 0, 122, 255]);
    settings.put('suggestions', false);
    settings.put('currentSong', null);
    settings.put('download_path', 'storage/emulated/0/Music/Melodia');
    settings.put('setup', true);
  }

  runApp(ProviderScope(child: Phoenix(child: const MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool darkMode = ref.watch(darkModeProvider);
    return CupertinoApp(
      home: Hive.box('settings').get('setup')
          ? const SetupScreen()
          : const LandingScreen(),
      theme: darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
