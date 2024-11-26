import 'package:hive_flutter/hive_flutter.dart';

part 'artists_model.g.dart';

@HiveType(typeId: 3)
class Artists {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? role;
  @HiveField(3)
  final List<Map<String, dynamic>> images;
  @HiveField(4)
  final String type;
  @HiveField(5)
  final String url;

  Artists({
    required this.id,
    required this.name,
    required this.role,
    required this.images,
    required this.type,
    required this.url,
  });

  String get image => images.isNotEmpty ? images.last['url'] as String : '';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'role': role,
      'images': images,
      'type': type,
      'url': url,
    };
  }

  factory Artists.fromMap(Map<String, dynamic> map) {
    return Artists(
      id: map['id'] as String,
      name: map['name'].replaceAll("&amp;", "&") as String,
      role: map['role'] != null ? map['role'] as String : null,
      images: List<Map<String, dynamic>>.from(
        map['image'] as List<dynamic>,
      ),
      type: map['type'] as String,
      url: map['url'] as String,
    );
  }
}
