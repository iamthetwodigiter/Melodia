import 'package:flutter/material.dart';

class Settings {
  final int downloadQuality;
  final int streamingQuality;
  final int ytDownloadQuality;
  final int ytStreamingQuality;
  final bool shuffleMode;
  final bool repeatMode;
  final bool suggestions;
  final bool separatePlaylistFolder;
  final Color accentColor;
  final List<String> bottomTabSelection;
  final bool isHistoryCardVisible;

  Settings({
    required this.downloadQuality,
    required this.streamingQuality,
    required this.ytDownloadQuality,
    required this.ytStreamingQuality,
    required this.shuffleMode,
    required this.repeatMode,
    required this.suggestions,
    required this.separatePlaylistFolder,
    required this.accentColor,
    required this.bottomTabSelection,
    required this.isHistoryCardVisible,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'downloadQuality': downloadQuality,
      'streamingQuality': streamingQuality,
      'ytDownloadQuality': ytDownloadQuality,
      'ytStreamingQuality': ytStreamingQuality,
      'shuffleMode': shuffleMode,
      'repeatMode': repeatMode,
      'suggestions': suggestions,
      'separatePlaylistFolder': separatePlaylistFolder,
      'accentColor': accentColor,
      'bottomTabSelection': bottomTabSelection,
      'isHistoryCardVisible': isHistoryCardVisible,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      downloadQuality: map['downloadQuality'] as int,
      streamingQuality: map['streamingQuality'] as int,
      ytDownloadQuality: map['ytDownloadQuality'] as int,
      ytStreamingQuality: map['ytStreamingQuality'] as int,
      shuffleMode: map['shuffleMode'] as bool,
      repeatMode: map['repeatMode'] as bool,
      suggestions: map['suggestions'] as bool,
      separatePlaylistFolder: map['separatePlaylistFolder'] as bool,
      accentColor: map['accentColor'] as Color,
      bottomTabSelection: map['bottomTabSelection'] as List<String>,
      isHistoryCardVisible: map['isHistoryCardVisible'] as bool,
    );
  }
}
