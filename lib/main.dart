import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:melodia/core/app_theme.dart';
import 'package:melodia/home/view/homepage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Box settings = await Hive.openBox('settings');
  if (Hive.box('settings').isEmpty) {
    settings.put('download_quality', '320');
    settings.put('streaming_quality', '320');
    settings.put('shuffle', 0);
    settings.put('cache_songs', 'false');
    settings.put('playing', 'false');
    settings.put('darkMode', 'false');
    settings.put('accent_color', [255,255,255,255]);
    settings.put('download_path',
        '${(await getExternalStorageDirectory())!.path}/Melodia');
  }
  if (Platform.isAndroid) {
    if (await Permission.storage.request().isDenied) {
      Permission.manageExternalStorage.request();
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: const HomePage(),
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
