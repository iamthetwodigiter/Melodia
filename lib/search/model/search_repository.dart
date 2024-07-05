class SongsResult {
  final String id;
  final String title;
  final String duration;
  final String imageUrl;
  final String album;
  final String url;
  final String type;
  final String? year;
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
    this.year = '',
    required this.artist,
    required this.downloadUrls,
  });
}


class SearchResult {
  final List<SongsResult> songs;
  SearchResult({required this.songs});
}