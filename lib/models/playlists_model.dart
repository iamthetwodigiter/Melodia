import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/artists_model.dart';
import 'package:melodia/models/songs_model.dart';

part 'playlists_model.g.dart';

@HiveType(typeId: 2)
class Playlists {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final int? year;
  @HiveField(4)
  final String? language;
  @HiveField(5)
  final bool explicitContent;
  @HiveField(6)
  final String url;
  @HiveField(7)
  final int? songCount;
  @HiveField(8)
  final List<Artists> artists;
  @HiveField(9)
  final String image;
  @HiveField(10)
  final List<Songs> songs;

  Playlists({
    required this.id,
    required this.title,
    required this.type,
    required this.year,
    required this.language,
    required this.explicitContent,
    required this.url,
    required this.songCount,
    required this.artists,
    required this.image,
    required this.songs,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type,
      'year': year,
      'language': language,
      'explicitContent': explicitContent,
      'url': url,
      'songCount': songCount,
      'artists': artists.map((x) => x.toMap()).toList(),
      'image': image,
      'songs': songs.map((x) => x.toMap()).toList(),
    };
  }

  factory Playlists.fromMap(Map<String, dynamic> map) {
    return Playlists(
      id: map['id'] as String,
      title: map['name'] as String,
      type: map['type'] as String,
      year: map['year'] != null ? map['year'] as int : null,
      language: map['language'] != null ? map['language'] as String : null,
      explicitContent: map['explicitContent'] as bool,
      url: map['url'] as String,
      songCount: map['songCount'] != null ? map['songCount'] as int : null,
      artists: List<Artists>.from(
        (map['artists'] as List<dynamic>).map<Artists>(
          (x) => Artists.fromMap(x as Map<String, dynamic>),
        ),
      ),
      image: map['image'] != null && (map['image'] as List).isNotEmpty
          ? (map['image'] as List).last['url'] as String
          : 'null',
      songs: List<Songs>.from(
        (map['songs'] as List<dynamic>).map<Songs>(
          (x) => Songs.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  Playlists copyWith({
    String? id,
    String? title,
    String? type,
    int? year,
    String? language,
    bool? explicitContent,
    String? url,
    int? songCount,
    List<Artists>? artists,
    String? image,
    List<Songs>? songs,
  }) {
    return Playlists(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      year: year ?? this.year,
      language: language ?? this.language,
      explicitContent: explicitContent ?? this.explicitContent,
      url: url ?? this.url,
      songCount: songCount ?? this.songCount,
      artists: artists ?? this.artists,
      image: image ?? this.image,
      songs: songs ?? this.songs,
    );
  }
}
