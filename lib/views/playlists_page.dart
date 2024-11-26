import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/playlists_data_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/providers/user_playlists_provider.dart';
import 'package:melodia/services/download.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/player_screen.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class PlaylistsPage extends ConsumerStatefulWidget {
  final String playlistID;
  const PlaylistsPage({
    super.key,
    required this.playlistID,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends ConsumerState<PlaylistsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final playlistsData = ref.watch(playlistsProvider(widget.playlistID));
    final userPlaylistsNotifier = ref.watch(userPlaylistsProvider.notifier);
    final audioProvider = ref.watch(audioPlayerProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Playlist",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            playlistsData.when(
              data: (data) {
                List<Songs> songsList = data.songs;
                bool isPlaylistAdded =
                    userPlaylistsNotifier.isPlaylistAdded(data);

                return Container(
                  height: size.height,
                  width: size.width,
                  padding: const EdgeInsets.all(10).copyWith(bottom: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: data.image.contains('https')
                                ? CachedNetworkImage(
                                    imageUrl: data.image,
                                    height: 175,
                                    width: 175,
                                    maxHeightDiskCache: 175,
                                    maxWidthDiskCache: 175,
                                    memCacheHeight: 175,
                                    memCacheWidth: 175,
                                    placeholder: (context, url) {
                                      return const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      return Center(
                                        child: Image.asset(
                                            'assets/song_thumb.png'),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/playlist_art.png',
                                    height: 175,
                                    width: 175,
                                  ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: size.width - 205,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.title,
                                  style: TextStyle(
                                    color: AppTheme.accentColor(ref),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                                Text(data.type.toUpperCase()),
                                Text('${data.songCount.toString()} Songs'),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PlayerScreen(
                                              playlist: songsList,
                                              initialIndex: 0,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                Color.fromARGB(
                                                    255, 59, 59, 59)),
                                        foregroundColor: WidgetStatePropertyAll(
                                            AppTheme.accentColor(ref)),
                                        padding: const WidgetStatePropertyAll(
                                            EdgeInsets.zero),
                                      ),
                                      child: const Icon(Icons.play_arrow),
                                    ),
                                    const SizedBox(width: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (isPlaylistAdded) {
                                            userPlaylistsNotifier
                                                .removePlaylist(data);
                                          } else {
                                            userPlaylistsNotifier
                                                .addPlaylist(data);
                                          }
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          customSnackBar(
                                            isPlaylistAdded
                                                ? 'Removed Playlist'
                                                : 'Added Playlist',ref
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                Color.fromARGB(
                                                    255, 59, 59, 59)),
                                        foregroundColor: WidgetStatePropertyAll(
                                            AppTheme.accentColor(ref)),
                                        padding: const WidgetStatePropertyAll(
                                            EdgeInsets.zero),
                                      ),
                                      child: Icon(isPlaylistAdded
                                          ? Icons.playlist_add_check
                                          : Icons.playlist_add),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      customSnackBar(
                                        'Downloading "${data.title}" Playlist Started',ref
                                      ),
                                    );
                                    downloadSong(
                                      songsList,
                                      settings?.downloadQuality.toString() ??
                                          '96',
                                      ref,
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            Color.fromARGB(255, 59, 59, 59)),
                                    foregroundColor: WidgetStatePropertyAll(
                                        AppTheme.accentColor(ref)),
                                  ),
                                  child: const Text('Download All'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: songsList.length,
                          itemBuilder: (context, index) {
                            Songs song = songsList[index];
                            return SongsListItem(
                              song: song,
                              playlist: songsList,
                              index: index,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: audioProvider.isSlabShown ? 60 : 0),
                    ],
                  ),
                );
              },
              error: (err, stack) {
                return const Center(
                  child: Icon(Icons.error_outline),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            ),
            const MusicSlab()
          ],
        ),
      ),
    );
  }
}
