import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

Box settings = Hive.box('settings');
bool darkMode = settings.get('darkMode') == 'false' ? false : true;
List<int> x = settings.get('accent_color');

class AppPallete {
  static const scaffoldBackgroundColor = CupertinoColors.systemBackground;
  static const primaryColor = CupertinoColors.activeBlue;
  // final secondaryColor = darkMode == true ? CupertinoColors.white : CupertinoColors.secondaryLabel ;
  final secondaryColor = CupertinoColors.white;
  final accentColor = Color.fromARGB(x.first, x.elementAt(1), x.elementAt(2), x.last);
}