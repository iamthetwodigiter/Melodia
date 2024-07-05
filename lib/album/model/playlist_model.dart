import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final List<String> idList;
  @HiveField(1)
  final List<String> linkList;
  @HiveField(2)
  final List<String> imageUrlList;
  @HiveField(3)
  final List<String> nameList;
  @HiveField(4)
  final List<List<String>> artistsList;
  @HiveField(5)
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
