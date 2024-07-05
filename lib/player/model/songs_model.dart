import 'package:hive/hive.dart';
import 'package:melodia/album/model/playlist_model.dart';

part 'songs_model.g.dart';

@HiveType(typeId: 0)
class SongModel extends HiveObject {
  @HiveField(0)
  final String link;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String duration;
  @HiveField(4)
  final String imageUrl;
  @HiveField(5)
  final List<String> artists;
  @HiveField(6)
  final Playlist? playlistData;
  @HiveField(7)
  final int index;
  @HiveField(8)
  final bool shuffleMode;
  @HiveField(9)
  final String playlistName;
  @HiveField(10)
  final String? year;

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
    required this.playlistName,
    this.year = '',
  });
}

// Define Playlist adapter similarly if needed
