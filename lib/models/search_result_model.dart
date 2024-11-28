class SearchResultSongs {
  final String id;
  final String title;
  final String image;
  final String albumTitle;
  final String url;
  final String type;
  final String artists;
  final String singers;

  SearchResultSongs({
    required this.id,
    required this.title,
    required this.image,
    required this.albumTitle,
    required this.url,
    required this.type,
    required this.artists,
    required this.singers,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'image': image,
      'albumTitle': albumTitle,
      'url': url,
      'type': type,
      'artists': artists,
      'singers': singers,
    };
  }

  factory SearchResultSongs.fromMap(Map<String, dynamic> map) {
    return SearchResultSongs(
      id: map['id'] as String,
      title: map['title'] as String,
      image: (map['image'] as List).last['url'] as String,
      albumTitle: map['album'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      artists: map['primaryArtists'].replaceAll("&amp;", "&") as String,
      singers: map['singers'] as String,
    );
  }
}

class SearchResultAlbums {
  final String id;
  final String title;
  final String image;
  final String artist;
  final String url;
  final String type;
  final String year;

  SearchResultAlbums({
    required this.id,
    required this.title,
    required this.image,
    required this.artist,
    required this.url,
    required this.type,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'image': image,
      'artist': artist,
      'url': url,
      'type': type,
      'year': year,
    };
  }

  factory SearchResultAlbums.fromMap(Map<String, dynamic> map) {
    return SearchResultAlbums(
      id: map['id'] as String,
      title: map['title'] as String,
      image: (map['image'] as List).last['url'] as String,
      artist: map['artist'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      year: map['year'] as String,
    );
  }
}

class SearchResultPlaylists {
  final String id;
  final String title;
  final String image;
  final String url;
  final String type;

  SearchResultPlaylists({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'image': image,
      'url': url,
      'type': type,
    };
  }

  factory SearchResultPlaylists.fromMap(Map<String, dynamic> map) {
    return SearchResultPlaylists(
      id: map['id'] as String,
      title: map['title'] as String,
      image: (map['image'] as List).last['url'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
    );
  }
}

class SearchResult {
  final List<SearchResultSongs> searchResultSongs;
  final List<SearchResultAlbums> searchResultAlbums;
  final List<SearchResultPlaylists> searchResultPlaylists;

  SearchResult({
    required this.searchResultSongs,
    required this.searchResultAlbums,
    required this.searchResultPlaylists,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'searchResultSongs': searchResultSongs.map((x) => x.toMap()).toList(),
      'searchResultAlbums': searchResultAlbums.map((x) => x.toMap()).toList(),
      'searchResultPlaylists':
          searchResultPlaylists.map((x) => x.toMap()).toList(),
    };
  }

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      searchResultSongs: List<SearchResultSongs>.from(
        (map['songs']['results'] as List<dynamic>).map<SearchResultSongs>(
          (x) => SearchResultSongs.fromMap(x as Map<String, dynamic>),
        ),
      ),
      searchResultAlbums: List<SearchResultAlbums>.from(
        (map['albums']['results'] as List<dynamic>).map<SearchResultAlbums>(
          (x) => SearchResultAlbums.fromMap(x as Map<String, dynamic>),
        ),
      ),
      searchResultPlaylists: List<SearchResultPlaylists>.from(
        (map['playlists']['results'] as List<dynamic>)
            .map<SearchResultPlaylists>(
          (x) => SearchResultPlaylists.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
