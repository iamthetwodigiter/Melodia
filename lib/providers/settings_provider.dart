import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/settings_model.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings?>(
  (ref) => SettingsNotifier(),
);

class SettingsNotifier extends StateNotifier<Settings?> {
  final Box _box;

  SettingsNotifier()
      : _box = Hive.box('settings'),
        super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final downloadQuality = _box.get('downloadQuality', defaultValue: 96);
    final streamingQuality = _box.get('streamingQuality', defaultValue: 96);
    final shuffleMode = _box.get('shuffleMode', defaultValue: false);
    final separatePlaylistFolder =
        _box.get('separatePlaylistFolder', defaultValue: false);
    final accentColorValue = _box.get('accentColor',
        defaultValue: Colors.blueAccent); 

    state = Settings(
      downloadQuality: downloadQuality,
      streamingQuality: streamingQuality,
      shuffleMode: shuffleMode,
      separatePlaylistFolder: separatePlaylistFolder,
      accentColor: accentColorValue, 
    );
  }

  void updateDownloadQuality(int quality) {
    _box.put('downloadQuality', quality);
    if (state != null) {
      state = Settings(
        downloadQuality: quality,
        streamingQuality: state!.streamingQuality,
        shuffleMode: state!.shuffleMode,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
      );
    }
  }

  void updateStreamingQuality(int quality) {
    _box.put('streamingQuality', quality);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: quality,
        shuffleMode: state!.shuffleMode,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
      );
    }
  }

  void updateShuffleMode(bool isEnabled) {
    _box.put('shuffleMode', isEnabled);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        shuffleMode: isEnabled,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
      );
    }
  }

  void updateseparatePlaylistFolder(bool isEnabled) {
    _box.put('separatePlaylistFolder', isEnabled);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        shuffleMode: state!.shuffleMode,
        separatePlaylistFolder: isEnabled,
        accentColor: state!.accentColor,
      );
    }
  }

  void updateAccentColor(Color accentColor) {
    _box.put('accentColor', accentColor);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        shuffleMode: state!.shuffleMode,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: accentColor,
      );
    }
  }
}
