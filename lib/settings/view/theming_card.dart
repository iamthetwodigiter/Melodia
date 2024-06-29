import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemingCard extends StatelessWidget {
  const ThemingCard({
    super.key,
  });

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: const Text(
          'Select Download Quality',
          style: TextStyle(fontSize: 20),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '96 kbps',
              style: TextStyle(fontSize: 20),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '160 kbps',
              style: TextStyle(fontSize: 20),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
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
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 26, 26),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 60,
      child: TextButton(
        onPressed: () {
          _showActionSheet(context);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Theming',
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
