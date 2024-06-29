import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DownloadsCard extends StatefulWidget {
  const DownloadsCard({
    super.key,
  });

  @override
  State<DownloadsCard> createState() => _DownloadsCardState();
}

class _DownloadsCardState extends State<DownloadsCard> {
  void _showActionSheet(String quality, Box box, BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Select Download Quality',
          style: TextStyle(fontSize: 20),
        ),
        message: Text('Currently selected $quality kbps'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              box.put('download_quality', '96');
              setState(() {
                
              });
              Navigator.pop(context);
            },
            child: const Text(
              '96 kbps',
              style: TextStyle(fontSize: 20),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              box.put('download_quality', '160');
              setState(() {
                
              });
              Navigator.pop(context);
            },
            child: const Text(
              '160 kbps',
              style: TextStyle(fontSize: 20),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              box.put('download_quality', '320');
              setState(() {
                
              });
              Navigator.pop(context);
            },
            child: const Text(
              '320 kbps',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
        cancelButton: CupertinoButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Box settings = Hive.box('settings');
    String downloadQuality = settings.get('download_quality');
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 26, 26),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 60,
      child: TextButton(
        onPressed: () {
          _showActionSheet(downloadQuality, settings, context);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Downloads',
              style:  TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white),
            ),
             Icon(
              CupertinoIcons.down_arrow,
              color: CupertinoColors.white,
            )
          ],
        ),
      ),
    );
  }
}
