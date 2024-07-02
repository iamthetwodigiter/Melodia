import 'package:flutter/cupertino.dart';
import 'package:melodia/core/color_pallete.dart';

class AppTheme {
  static final appTheme = const CupertinoThemeData().copyWith(
    scaffoldBackgroundColor: AppPallete.scaffoldBackgroundColor,
    textTheme: CupertinoTextThemeData(primaryColor: AppPallete().accentColor,
    ),
    
  );
}
