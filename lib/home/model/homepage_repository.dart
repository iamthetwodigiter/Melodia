class NewAlbums {
  final String id;
  final String title;
  final String image;
  final String language;
  final String year;
  final List<dynamic> artists;

  NewAlbums({
    required this.id,
    required this.title,
    required this.image,
    required this.language,
    required this.year,
    required this.artists,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'language': language,
      'year': year,
      'artists': [...artists],
    };
  }
}

class FeaturedPlaylist {
  final String listID;
  final String listname;
  final int count;
  final String image;
  final String permaUrl;

  FeaturedPlaylist({
    required this.listID,
    required this.listname,
    required this.count,
    required this.image,
    required this.permaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': listID,
      'title': listname,
      'image': image,
      'count': count,
      'url': permaUrl,
    };
  }
}

class OtherPlaylists {
  final String id;
  final String name;
  final String imageUrl;

  OtherPlaylists({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': name,
      'image': imageUrl,
    };
  }
}
