class Albums {
  final String id;
  final String name;
  final String description;
  final String type;
  final int? year;
  final String url;
  final int songsCount;
  final List<Artist> artists;
  final String image;
  final List<Songs> songs;

  Albums({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.year,
    required this.url,
    required this.songsCount,
    required this.artists,
    required this.image,
    required this.songs,
  });
}

class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final String role;
  final String url;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
    required this.url,
  });
}

class Songs {
  final String id;
  final String name;
  final String type;
  final String duration;
  final String label;
  final String url;
  final String image;
  final List<String> downloadUrl;
  final List<String> artists;

  Songs({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.label,
    required this.url,
    required this.image,
    required this.downloadUrl,
    required this.artists,
  });
}
