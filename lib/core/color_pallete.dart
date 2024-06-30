import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

Box settings = Hive.box('settings');
List<int> x = settings.get('accent_color');

class AppPallete {
  static const scaffoldBackgroundColor = CupertinoColors.black;
  static const primaryColor = CupertinoColors.activeBlue;
  static const secondaryColor = CupertinoColors.white;
  final accentColor = Color.fromARGB(x.first, x.elementAt(1), x.elementAt(2), x.last);
}