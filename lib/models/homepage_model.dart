class NewAlbums {
  final String title;
  final String year;
  final String image;
  final String albumID;
  final String language;

  NewAlbums({
    required this.title,
    required this.year,
    required this.image,
    required this.albumID,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'year': year,
      'image': image,
      'albumID': albumID,
      'language': language,
    };
  }

  factory NewAlbums.fromMap(Map<String, dynamic> map) {
    return NewAlbums(
      title: map['title'] as String,
      year: map['year'] as String,
      image: map['image'] as String,
      albumID: map['albumid'] as String,
      language: map['language'] as String,
    );
  }
}

class FeaturedPlaylists {
  final String listID;
  final String firstName;
  final String listName;
  final String dataType;
  final int count;
  final String image;
  final bool sponsored;
  final String permaUrl;
  final String followerCount;
  final int lastUpdated;

  FeaturedPlaylists(
      {required this.listID,
      required this.firstName,
      required this.listName,
      required this.dataType,
      required this.count,
      required this.image,
      required this.sponsored,
      required this.permaUrl,
      required this.followerCount,
      required this.lastUpdated});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'listID': listID,
      'firstName': firstName,
      'listName': listName,
      'dataType': dataType,
      'count': count,
      'image': image,
      'sponsored': sponsored,
      'permaUrl': permaUrl,
      'followerCount': followerCount,
      'lastUpdated': lastUpdated,
    };
  }

  factory FeaturedPlaylists.fromMap(Map<String, dynamic> map) {
    return FeaturedPlaylists(
      listID: map['listid'] as String,
      firstName: map['firstname'] as String,
      listName: map['listname'] as String,
      dataType: map['data_type'] as String,
      count: map['count'] as int,
      image: map['image'] as String,
      sponsored: map['sponsored'] as bool,
      permaUrl: map['perma_url'] as String,
      followerCount: map['follower_count'] as String,
      lastUpdated: map['last_updated'] as int,
    );
  }
}

class Charts {
  final String listID;
  final String title;
  final String image;
  final String permaUrl;

  Charts(
      {required this.listID,
      required this.title,
      required this.image,
      required this.permaUrl});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'listID': listID,
      'title': title,
      'image': image,
      'permaUrl': permaUrl,
    };
  }

  factory Charts.fromMap(Map<String, dynamic> map) {
    return Charts(
      listID: map['listid'] as String,
      title: map['listname'] as String,
      image: map['image'] as String,
      permaUrl: map['perma_url'] as String,
    );
  }
}


class HomePageModel {
  final List<NewAlbums> newAlbums;
  final List<FeaturedPlaylists> featuredPlaylists;
  final List<Charts> charts;

  HomePageModel({
    required this.newAlbums,
    required this.featuredPlaylists,
    required this.charts,
  });

  
  factory HomePageModel.fromMap(Map<String, dynamic> map) {
    return HomePageModel(
      newAlbums: (map['new_albums'] as List<dynamic>)
          .map((album) => NewAlbums.fromMap(album as Map<String, dynamic>))
          .toList(),
      featuredPlaylists: (map['featured_playlists'] as List<dynamic>)
          .map((playlist) => FeaturedPlaylists.fromMap(playlist as Map<String, dynamic>))
          .toList(),
      charts: (map['charts'] as List<dynamic>)
          .map((chart) => Charts.fromMap(chart as Map<String, dynamic>))
          .toList(),
    );
  }
}
