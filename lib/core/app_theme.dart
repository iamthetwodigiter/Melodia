import 'package:flutter/cupertino.dart';
import 'package:melodia/core/color_pallete.dart';

class AppTheme {
  static final darkTheme = CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
    primaryColor: AppPallete().accentColor,
  )).copyWith(
    scaffoldBackgroundColor: AppPallete.scaffoldDarkBackground,
    barBackgroundColor: AppPallete.scaffoldDarkBackground
  );
  static final lightTheme = CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
    primaryColor: AppPallete().accentColor,
  )).copyWith(
    scaffoldBackgroundColor: AppPallete.scaffoldBackgroundColor,
    barBackgroundColor: AppPallete.scaffoldBackgroundColor
  );
}
