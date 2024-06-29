class Playlist {
  final List<String> idList;
  final List<String> linkList;
  final List<String> imageUrlList;
  final List<String> nameList;
  final List<List<String>> artistsList;
  final List<String> durationList;

  Playlist({
    required this.idList,
    required this.linkList,
    required this.imageUrlList,
    required this.nameList,
    required this.artistsList,
    required this.durationList,
  });
}
