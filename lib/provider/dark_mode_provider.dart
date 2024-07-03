import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier();
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(_getInitialDarkModeSetting()) {
    // Listen to system brightness changes
    WidgetsBinding.instance.addObserver(_SystemBrightnessObserver(this));
  }

  static bool _getInitialDarkModeSetting() {
    final box = Hive.box('settings');
    return box.get('darkMode', defaultValue: WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
  }

  void setDarkMode(bool isDarkMode) {
    state = isDarkMode;
    final box = Hive.box('settings');
    box.put('darkMode', isDarkMode);
  }

  void updateSystemBrightness(Brightness brightness) {
    final box = Hive.box('settings');
    final useSystem = box.get('useSystemDarkMode', defaultValue: true);
    if (useSystem) {
      setDarkMode(brightness == Brightness.dark);
    }
  }
}

class _SystemBrightnessObserver extends WidgetsBindingObserver {
  final DarkModeNotifier notifier;

  _SystemBrightnessObserver(this.notifier);

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    notifier.updateSystemBrightness(brightness);
  }
}
