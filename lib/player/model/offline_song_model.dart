import 'dart:io';
import 'dart:typed_data';
import 'package:audiotagger/models/tag.dart';

class OfflineSongModel {
  final List<File> songList;
  final List<Uint8List?> thumbList;
  final List<Tag?> tags;
  final int index;
  OfflineSongModel({
    required this.songList,
    required this.thumbList,
    required this.index,
    required this.tags,
  });
}