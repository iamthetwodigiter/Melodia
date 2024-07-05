import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/home/view/homepage.dart';
import 'package:melodia/library/view/playlist_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    LibraryScreen(),
    // Settings()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        Permission.manageExternalStorage.request();
      }
    }
    await getExternalStorageDirectory();
    if (!Directory("storage/emulated/0/Music/Melodia").existsSync()) {
      Directory("storage/emulated/0/Music/Melodia").createSync(recursive: true);
    }
  }

  @override
  void initState() {
    super.initState();
    getStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Scaffold(
        backgroundColor: Hive.box('settings').get('darkMode')
            ? AppPallete.scaffoldDarkBackground
            : AppPallete.scaffoldBackgroundColor,
        body: _pages[_selectedIndex],
        bottomNavigationBar: CupertinoTabBar(
          height: 45,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          activeColor: AppPallete().accentColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.music_note_list),
              label: 'Library',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(CupertinoIcons.settings_solid),
            //   label: 'Settings',
            // ),
          ],
        ),
      ),
    );
  }
}
