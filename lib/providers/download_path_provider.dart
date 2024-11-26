import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final downloadPathProvider = Provider((ref) async {
  if (Platform.isAndroid) {
    return Directory('storage/emulated/0/Music/Melodia');
  } else if (Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    final melodiaPath = Directory('${directory.path}/Melodia');
    return melodiaPath;
  }
});
