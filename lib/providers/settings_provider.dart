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
    final ytDownloadQuality = _box.get('ytDownloadQuality', defaultValue: 48);
    final ytStreamingQuality = _box.get('ytStreamingQuality', defaultValue: 48);
    final shuffleMode = _box.get('shuffleMode', defaultValue: false);
    final repeatMode = _box.get('repeatMode', defaultValue: false);
    final separatePlaylistFolder =
        _box.get('separatePlaylistFolder', defaultValue: true);
    final accentColorValue =
        _box.get('accentColor', defaultValue: Colors.blueAccent);
    final bottomTabSelection = _box.get('bottomTabSelection',
        defaultValue: ['favorites', 'playlists', 'settings', 'profile']);
    final suggestions = _box.get('suggestions', defaultValue: true);
    final isHistoryCardVisible =
        _box.get('historyBoxVisible', defaultValue: false);

    state = Settings(
      downloadQuality: downloadQuality,
      streamingQuality: streamingQuality,
      ytDownloadQuality: ytDownloadQuality,
      ytStreamingQuality: ytStreamingQuality,
      shuffleMode: shuffleMode,
      repeatMode: repeatMode,
      suggestions: suggestions,
      separatePlaylistFolder: separatePlaylistFolder,
      accentColor: accentColorValue,
      bottomTabSelection: bottomTabSelection,
      isHistoryCardVisible: isHistoryCardVisible,
    );
  }

  void updateDownloadQuality(int quality) {
    _box.put('downloadQuality', quality);
    if (state != null) {
      state = Settings(
        downloadQuality: quality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateStreamingQuality(int quality) {
    _box.put('streamingQuality', quality);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: quality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateShuffleMode(bool isEnabled) {
    _box.put('shuffleMode', isEnabled);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: isEnabled,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateRepeatMode(bool isEnabled) {
    _box.put('repeatMode', isEnabled);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: isEnabled,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateseparatePlaylistFolder(bool isEnabled) {
    _box.put('separatePlaylistFolder', isEnabled);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: isEnabled,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateAccentColor(Color accentColor) {
    _box.put('accentColor', accentColor);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateYTDownloadQuality(int quality) {
    _box.put('ytDownloadQuality', quality);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: quality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateYTStreamingQuality(int quality) {
    _box.put('ytStreamingQuality', quality);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: quality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateBottomTabSelection(List<String> updateList) {
    _box.put('bottomTabSelection', updateList);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: updateList,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateSuggestions(bool isEnabled) {
    _box.put('suggestions', isEnabled);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: isEnabled,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: state!.isHistoryCardVisible,
      );
    }
  }

  void updateisHistoryCardVisible(bool isVisible) {
    _box.put('isHistoryCardVisible', isVisible);
    if (state != null) {
      state = Settings(
        downloadQuality: state!.downloadQuality,
        streamingQuality: state!.streamingQuality,
        ytDownloadQuality: state!.ytDownloadQuality,
        ytStreamingQuality: state!.ytStreamingQuality,
        shuffleMode: state!.shuffleMode,
        repeatMode: state!.repeatMode,
        suggestions: state!.suggestions,
        separatePlaylistFolder: state!.separatePlaylistFolder,
        accentColor: state!.accentColor,
        bottomTabSelection: state!.bottomTabSelection,
        isHistoryCardVisible: isVisible,
      );
    }
  }
}
