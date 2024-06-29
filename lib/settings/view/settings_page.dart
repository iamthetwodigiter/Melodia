import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodia/settings/view/downloads_card.dart';
import 'package:melodia/settings/view/streaming_card.dart';
import 'package:melodia/settings/view/theming_card.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
            size: 20,
          ),
        ),
        middle: const Text('Settings'),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemingCard(),
            SizedBox(height: 10),
            DownloadsCard(),
            SizedBox(height: 10),
            StreamingCard(),
          ],
        ),
      ),
    );
  }
}
