import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/favorites_page.dart';
import 'package:melodia/views/history_page.dart';
import 'package:melodia/views/menu_page.dart';
import 'package:melodia/views/music_page.dart';
import 'package:melodia/views/offline_playlists_list.dart';
import 'package:melodia/views/play_me_page.dart';
import 'package:melodia/views/user_albums_list.dart';
import 'package:melodia/views/user_playlists_list.dart';
import 'package:melodia/widgets/music_slab.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.menu),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MenuPage(),
              ),
            );
          },
        ),
        title: Text(
          "Library",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SizedBox(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              children: [
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading: Icon(Icons.album, color: AppTheme.accentColor(ref)),
                  title: const Text('Albums'),
                  subtitle: const Text('All your favorite albums are here'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UserAlbumsList(),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading: Icon(Icons.playlist_play,
                      color: AppTheme.accentColor(ref)),
                  title: const Text('Playlists'),
                  subtitle: const Text('All your favorite playlists are here'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UserPlaylistsList(),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading: Icon(Ionicons.musical_notes,
                      color: AppTheme.accentColor(ref)),
                  title: const Text('Offline Playlist'),
                  subtitle: const Text('All your playlists for offline songs'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OfflinePlaylistsList(),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading:
                      Icon(Icons.favorite, color: AppTheme.accentColor(ref)),
                  title: const Text('Favorites'),
                  subtitle: const Text('All your favorite songs are here'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading: Icon(Icons.library_music,
                      color: AppTheme.accentColor(ref)),
                  title: const Text('All Songs'),
                  subtitle: const Text('Browse all the music on device'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const MusicPage(isDownloadsFolder: false),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading: Icon(Icons.download_done,
                      color: AppTheme.accentColor(ref)),
                  title: const Text('Downloads'),
                  subtitle: const Text('Browse all Melodia downloads'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const MusicPage(isDownloadsFolder: true),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading:
                      Icon(Icons.queue_music, color: AppTheme.accentColor(ref)),
                  title: const Text('PlayMe'),
                  subtitle: const Text('Your own custom playing queue'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlayMePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                  leading:
                      Icon(Icons.history, color: AppTheme.accentColor(ref)),
                  title: const Text('History'),
                  subtitle: const Text('All the songs you played are here'),
                  titleTextStyle: TextStyle(
                    color: AppTheme.accentColor(ref),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HistoryPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const MusicSlab()
          ],
        ),
      ),
    );
  }
}
