import 'package:flutter/material.dart';

class Settings {
  final int downloadQuality;
  final int streamingQuality;
  final int ytDownloadQuality;
  final int ytStreamingQuality;
  final bool shuffleMode;
  final bool separatePlaylistFolder;
  final Color accentColor;

  Settings({
    required this.downloadQuality,
    required this.streamingQuality,
    required this.ytDownloadQuality,
    required this.ytStreamingQuality,
    required this.shuffleMode,
    required this.separatePlaylistFolder,
    required this.accentColor,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'downloadQuality': downloadQuality,
      'streamingQuality': streamingQuality,
      'ytDownloadQuality': ytDownloadQuality,
      'ytStreamingQuality': ytStreamingQuality,
      'shuffleMode': shuffleMode,
      'separatePlaylistFolder': separatePlaylistFolder,
      'accentColor': accentColor,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      downloadQuality: map['downloadQuality'] as int,
      streamingQuality: map['streamingQuality'] as int,
      ytDownloadQuality: map['ytDownloadQuality'] as int,
      ytStreamingQuality: map['ytStreamingQuality'] as int,
      shuffleMode: map['shuffleMode'] as bool,
      separatePlaylistFolder: map['separatePlaylistFolder'] as bool,
      accentColor: map['accentColor'] as Color,
    );
  }
}
