class SongsResult {
  final String id;
  final String title;
  final String duration;
  final String imageUrl;
  final String album;
  final String url;
  final String type;
  final List<String> artist;
  final List<String> downloadUrls;

  SongsResult({
    required this.id,
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.album,
    required this.url,
    required this.type,
    required this.artist,
    required this.downloadUrls,
  });
}

// class AlbumResult {
//   final String id;
//   final String title;
//   final String imageUrl;
//   final String url;
//   final String type;
//   final String artist;

//   AlbumResult({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     required this.url,
//     required this.type,
//     required this.artist,
//   });
// }

class SearchResult {
  final List<SongsResult> songs;
  // final List<AlbumResult> albums;

  SearchResult({required this.songs});
}