class OfflineFiles {
  final String title;
  final String path;
  final bool isDownloaded;
  final String? image;
  final String size;

  OfflineFiles({
    required this.title,
    required this.path,
    required this.isDownloaded,
    required this.image,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'path': path,
      'isDownloaded': isDownloaded,
      'image': image,
      'size': size,
    };
  }

  factory OfflineFiles.fromMap(Map<String, dynamic> map) {
    return OfflineFiles(
      title: map['title'] as String,
      path: map['path'] as String,
      isDownloaded: map['isDownloaded'] as bool,
      image: map['image'] != null ? map['image'] as String : null,
      size: map['size'] as String,
    );
  }
}
