import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/favorites_page.dart';
import 'package:melodia/views/homepage.dart';
import 'package:melodia/views/library_page.dart';
import 'package:melodia/views/settings_page.dart';
import 'package:melodia/views/user_playlists_list.dart';
import 'package:melodia/widgets/changelog_dialog.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  int _currentIndex = 0;
  Box version = Hive.box('version');

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    List<String> bottomTabIndices = settings!.bottomTabSelection;
    final String last = version.get('last');
    final String latest = version.get('latest');

    final pages = <Widget>[
      const HomePage(),
      if (bottomTabIndices.contains('favorites')) const FavoritesPage(),
      if (bottomTabIndices.contains('playlists')) const UserPlaylistsList(),
      const LibraryPage(),
      if (bottomTabIndices.contains('settings')) const SettingsPage(),
    ];

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }
    
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          if (latest != last)
            ElevatedButton(
              style: ButtonStyle(
                  shadowColor:
                      WidgetStatePropertyAll(AppTheme.accentColor(ref))),
              onPressed: () {
                setState(() {
                  version.put('last', latest);
                });
                ChangelogDialog.show(context, ref);
              },
              child: Text(
                'Show Changelog',
                style: TextStyle(
                  color: AppTheme.accentColor(ref),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: AppTheme.accentColor(ref),
          ),
          if (bottomTabIndices.contains('favorites'))
            SalomonBottomBarItem(
              icon: const Icon(Icons.favorite_border),
              title: const Text("Favorite"),
              selectedColor: Colors.pink,
            ),
          if (bottomTabIndices.contains('playlists'))
            SalomonBottomBarItem(
              icon: const Icon(Icons.playlist_play),
              title: const Text("Playlist"),
              selectedColor: Colors.orange,
            ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.library_music),
            title: const Text("Library"),
            selectedColor: Colors.blueAccent,
          ),
          if (bottomTabIndices.contains('settings'))
            SalomonBottomBarItem(
              icon: const Icon(Icons.settings),
              title: const Text("Setting"),
              selectedColor: Colors.deepPurpleAccent,
            ),
        ],
      ),
    );
  }
}
