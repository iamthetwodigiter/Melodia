// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// Box settings = Hive.box('settings');
// Color defaultAccentColor = settings.get('accentColor');

// class AppTheme {
//   final accentColor = defaultAccentColor;
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/providers/settings_provider.dart';

class AppTheme {
  static Color accentColor(WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return settings?.accentColor ?? Colors.blueAccent;
  }
}
