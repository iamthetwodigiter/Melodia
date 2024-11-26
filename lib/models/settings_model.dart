import 'package:flutter/material.dart';

class Settings {
  final int downloadQuality;
  final int streamingQuality;
  final bool shuffleMode;
  final bool separatePlaylistFolder;
  final Color accentColor;

  Settings({
    required this.downloadQuality,
    required this.streamingQuality,
    required this.shuffleMode,
    required this.separatePlaylistFolder,
    required this.accentColor,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'downloadQuality': downloadQuality,
      'streamingQuality': streamingQuality,
      'shuffleMode': shuffleMode,
      'separatePlaylistFolder': separatePlaylistFolder,
      'accentColor': accentColor,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      downloadQuality: map['downloadQuality'] as int,
      streamingQuality: map['streamingQuality'] as int,
      shuffleMode: map['shuffleMode'] as bool,
      separatePlaylistFolder: map['separatePlaylistFolder'] as bool,
      accentColor: map['accentColor'] as Color,
    );
  }
}
