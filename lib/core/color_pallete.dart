import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

Box settings = Hive.box('settings');

bool darkMode = settings.get('darkMode');

List<int> x = settings.get('accent_color');
final accent = Color.fromARGB(x.first, x.elementAt(1), x.elementAt(2), x.last);

class AppPallete {
  static const scaffoldBackgroundColor = CupertinoColors.white;
  static const scaffoldDarkBackground = CupertinoColors.darkBackgroundGray;
  static const primaryColor = CupertinoColors.activeBlue;
  final secondaryColor = accent;
  static const secondaryDarkColor = CupertinoColors.white;
  final accentColor = accent;
  final subtitleTextColor = accent.withAlpha(200);
  static const subtitleDarkTextColor = CupertinoColors.white;
}
