import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/models/albums_model.dart';
import 'package:melodia/models/artists_model.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/secrets/secrets.dart';
import 'package:melodia/services/notification_service.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/landing_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.initialize(oneSignalAppID);
  OneSignal.Notifications.requestPermission(true);

  await NotificationService.init();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.thetwodigiter.melodia.bgaudio',
    androidNotificationChannelName: 'Background Playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();

  Hive.registerAdapter(AlbumsAdapter());
  Hive.registerAdapter(PlaylistsAdapter());
  Hive.registerAdapter(ArtistsAdapter());
  Hive.registerAdapter(SongsAdapter());
  Hive.registerAdapter(ColorAdapter());

  await Hive.openBox('settings');
  await Hive.openBox('albums');
  await Hive.openBox('playlists');
  await Hive.openBox('favorites');
  await Hive.openBox('history');
  await Hive.openBox('offlinePlaylists');
  await Hive.openBox('offlineFavorites');
  await Hive.openBox('searchHistory');
  await Hive.openBox('version');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  void getStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        Permission.manageExternalStorage.request();
      }
      await getExternalStorageDirectory();
      if (!Directory("storage/emulated/0/Music/Melodia").existsSync()) {
        Directory("storage/emulated/0/Music/Melodia")
            .createSync(recursive: true);
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final melodiaPath = Directory('${directory.path}/Melodia');
      if (!melodiaPath.existsSync()) {
        melodiaPath.createSync(recursive: true);
      }
    }

    if (await Permission.manageExternalStorage.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    getStoragePermission();
    Box settings = Hive.box('settings');
    Box version = Hive.box('version');

    if (!settings.keys.contains('accentColor')) {
      settings.put('accentColor', Colors.blueAccent);
    }

    if (!version.keys.contains('last')) {
      version.put('last', 'v4.2.0');
    }

    if (!version.keys.contains('latest')) {
      version.put('latest', 'v4.3.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        indicatorColor: AppTheme.accentColor(ref),
        primaryColor: AppTheme.accentColor(ref),
        iconTheme: IconThemeData(color: AppTheme.accentColor(ref)),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            iconColor: WidgetStatePropertyAll(AppTheme.accentColor(ref)),
          ),
        ),
        brightness: Brightness.dark,
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(color: Colors.white),
        //   displayMedium: TextStyle(color: Colors.white),
        //   displaySmall: TextStyle(color: Colors.white),
        //   headlineLarge: TextStyle(color: Colors.white),
        //   headlineMedium: TextStyle(color: Colors.white),
        //   headlineSmall: TextStyle(color: Colors.white),
        //   titleLarge: TextStyle(color: Colors.white),
        //   titleMedium: TextStyle(color: Colors.white),
        //   titleSmall: TextStyle(color: Colors.white),
        //   bodyLarge: TextStyle(color: Colors.white),
        //   bodyMedium: TextStyle(color: Colors.white),
        //   bodySmall: TextStyle(color: Colors.white),
        //   labelLarge: TextStyle(color: Colors.white),
        //   labelMedium: TextStyle(color: Colors.white),
        //   labelSmall: TextStyle(color: Colors.white),
        // ),
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
