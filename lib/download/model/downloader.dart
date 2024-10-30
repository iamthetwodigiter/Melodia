import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:melodia/core/cupertino_popup_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final dio = Dio();
final tagger = Audiotagger();
final downloadQuality = Hive.box('settings').get('download_quality');

void setTags(String filePath, List metadata, String imagePath) async {
  final path = filePath;
  final tag = Tag(
      title: metadata.elementAt(0),
      artist: metadata.elementAt(1).join(", "),
      album: metadata.elementAt(2),
      genre: null,
      trackNumber: (metadata.elementAt(5) + 1).toString(),
      albumArtist: metadata.elementAt(1).join(", "),
      artwork: imagePath,
      year: metadata.elementAt(6));

  await tagger.writeTags(
    path: path,
    tag: tag,
  );
}

Future download(
    String url, String savePath, List metadata, BuildContext context,
    {Function(double)? onProgress}) async {
  try {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        Permission.manageExternalStorage.request();
        await getExternalStorageDirectory();
      }
    }
    if (!Directory("storage/emulated/0/Music/Melodia").existsSync()) {
      Directory("storage/emulated/0/Music/Melodia").createSync(recursive: true);
    }
    Response songresponse = await dio.get(
      url.replaceAll('320', downloadQuality),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          double progress = received / total;
          if (onProgress != null) onProgress(progress);
        }
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    File file =
        File('storage/emulated/0/Music/Melodia/${savePath.trimRight().replaceAll("/", "_")}');
    var song = file.openSync(mode: FileMode.write);
    song.writeFromSync(songresponse.data);
    await song.close();

    Response imageresponse = await dio.get(
      metadata.elementAt(4),
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    File imagefile = File(
        'storage/emulated/0/Android/data/com.thetwodigiter.melodia/files/${savePath.replaceAll('.m4a', '.png').replaceAll(" ", "_").replaceAll("/", "_").trimRight()}');
    var image = imagefile.openSync(mode: FileMode.write);
    image.writeFromSync(imageresponse.data);
    await image.close();

    setTags('storage/emulated/0/Music/Melodia/${savePath.replaceAll("/", "_")}', metadata,
        'storage/emulated/0/Android/data/com.thetwodigiter.melodia/files/${savePath.replaceAll('.m4a', '.png').replaceAll("/", "_").replaceAll(" ", "_")}');
    
    showCupertinoCenterPopup(
        context,
        '${savePath.replaceAll('m4a', '')} Downloaded',
        Icons.download_done_rounded);
  } catch (e) {
    rethrow;
  }
}
