import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/models/artists_model.dart';

part 'songs_model.g.dart';

@HiveType(typeId: 4)
class Songs {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final String year;
  @HiveField(4)
  final int duration;
  @HiveField(5)
  final bool explicitContent;
  @HiveField(6)
  final String language;
  @HiveField(7)
  final bool hasLyrics;
  @HiveField(8)
  final String image;
  @HiveField(9)
  final String downloadUrl;
  @HiveField(10)
  final List<Artists> artists;
  @HiveField(11)
  final String? albumTitle;

  Songs({
    required this.id,
    required this.title,
    required this.type,
    required this.year,
    required this.duration,
    required this.explicitContent,
    required this.language,
    required this.hasLyrics,
    required this.image,
    required this.downloadUrl,
    required this.artists,
    required this.albumTitle,
  });
  Songs copyWith({
    String? id,
    String? title,
    String? type,
    String? year,
    int? duration,
    bool? explicitContent,
    String? language,
    bool? hasLyrics,
    String? image,
    String? downloadUrl,
    List<Artists>? artists,
    String? albumTitle,
  }) {
    return Songs(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      explicitContent: explicitContent ?? this.explicitContent,
      language: language ?? this.language,
      hasLyrics: hasLyrics ?? this.hasLyrics,
      image: image ?? this.image,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      artists: artists ?? this.artists,
      albumTitle: albumTitle ?? this.albumTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type,
      'year': year,
      'duration': duration,
      'explicitContent': explicitContent,
      'language': language,
      'hasLyrics': hasLyrics,
      'image': image,
      'downloadUrl': downloadUrl,
      'artists': artists.map((x) => x.toMap()).toList(),
      'albumTitle': albumTitle,
    };
  }

  factory Songs.fromMap(Map<String, dynamic> map) {
    return Songs(
      id: map['id'] as String,
      title: map['name'].replaceAll("&quot;", "\"")
          .replaceAll("&amp;", "&") as String,
      type: map['type'] as String,
      year: map['year'] as String,
      duration: map['duration'] as int,
      explicitContent: map['explicitContent'] as bool,
      language: map['language'] as String,
      hasLyrics: map['hasLyrics'] ?? false,
      image: (map['image'] as List).last['url'] as String,
      downloadUrl: (map['downloadUrl'] as List).last['url'] as String,
      artists: List<Artists>.from(
        (map['artists']['all'] as List<dynamic>).map<Artists>(
          (x) => Artists.fromMap(x as Map<String, dynamic>),
        ),
      ),
      albumTitle: map['album']['name'] as String? ?? '',
    );
  }
}
