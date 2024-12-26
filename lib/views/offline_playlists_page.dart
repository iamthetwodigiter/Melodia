import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/offline_playlists_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/offline_song_list_item.dart';

class OfflinePlaylistsPage extends ConsumerStatefulWidget {
  final Playlists playlist;
  const OfflinePlaylistsPage({
    super.key,
    required this.playlist,
  });
  @override
  ConsumerState<OfflinePlaylistsPage> createState() =>
      _OfflinePlaylistsPageState();
}

class _OfflinePlaylistsPageState extends ConsumerState<OfflinePlaylistsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    List<Songs> songsList = widget.playlist.songs;
    final offlinePlaylistsNotifier =
        ref.watch(offlinePlaylistsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.playlist.title,
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                offlinePlaylistsNotifier.removePlaylist(widget.playlist);
              });
              ScaffoldMessenger.of(context).showSnackBar(customSnackBar(
                  'Removed Playlist, Please Go Back to Update The List', ref));
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ],
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          color: AppTheme.accentColor(ref),
          onRefresh: () async {
            ref.read(offlinePlaylistsProvider);
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: size.height,
                width: size.width,
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: songsList.length,
                  itemBuilder: (context, index) {
                    Songs song = songsList[index];
                    return OfflineSongsListItem(
                      song: song,
                      songList: songsList,
                      index: index,
                      playlist: widget.playlist,
                      fromPlaylist: true,
                    );
                  },
                ),
              ),
              const MusicSlab()
            ],
          ),
        ),
      ),
    );
  }
}
