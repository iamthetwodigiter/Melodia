import 'package:just_audio/just_audio.dart';
import 'package:melodia/album/model/playlist_model.dart';

class SongModel {
  final String link;
  final String id;
  final String name;
  final String duration;
  final String imageUrl;
  final List<String> artists;
  final Playlist? playlistData;
  final int index;
  final bool shuffleMode;
  final AudioPlayer? player;

  SongModel({
    required this.link,
    required this.id,
    required this.name,
    required this.duration,
    required this.imageUrl,
    required this.artists,
    this.playlistData,
    required this.index,
    required this.shuffleMode,
    this.player,
  });
}
