import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/artists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/albums_data_provider.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/providers/user_albums_provider.dart';
import 'package:melodia/services/download.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/player_screen.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class AlbumsPage extends ConsumerStatefulWidget {
  final String albumID;
  const AlbumsPage({
    super.key,
    required this.albumID,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends ConsumerState<AlbumsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final albumsData = ref.watch(albumsDataProvider(widget.albumID));
    final userAlbumsNotifier = ref.watch(userAlbumsProvider.notifier);
    final audioProvider = ref.watch(audioPlayerProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Albums",
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
          alignment: Alignment.bottomCenter,
          children: [
            albumsData.when(
              data: (data) {
                List<Songs> songsList = data.songs;
                List<Artists> artistsList = data.artists;
                bool isAlbumAdded = userAlbumsNotifier.isAlbumAdded(data);
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
                            child: CachedNetworkImage(
                              imageUrl: data.image,
                              height: 175,
                              width: 175,
                              maxHeightDiskCache: 175,
                              maxWidthDiskCache: 175,
                              memCacheHeight: 175,
                              memCacheWidth: 175,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${data.type.toUpperCase()} • ${data.year}'),
                              Text((data.language ?? '').toUpperCase()),
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
                                              Color.fromARGB(255, 59, 59, 59)),
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
                                        if (isAlbumAdded) {
                                          userAlbumsNotifier.removeAlbum(data);
                                        } else {
                                          userAlbumsNotifier.addAlbum(data);
                                        }
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        customSnackBar(
                                          isAlbumAdded
                                              ? 'Removed Album'
                                              : 'Added Album',ref
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                              Color.fromARGB(255, 59, 59, 59)),
                                      foregroundColor: WidgetStatePropertyAll(
                                          AppTheme.accentColor(ref)),
                                      padding: const WidgetStatePropertyAll(
                                          EdgeInsets.zero),
                                    ),
                                    child: Icon(isAlbumAdded
                                        ? Icons.playlist_add_check
                                        : Icons.playlist_add),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    customSnackBar(
                                      'Downloading "${data.title}" Album Started',ref
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
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Color.fromARGB(255, 59, 59, 59)),
                                  foregroundColor: WidgetStatePropertyAll(
                                      AppTheme.accentColor(ref)),
                                ),
                                child: const Text('Download All'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: songsList.length + 1,
                          itemBuilder: (context, index) {
                            if (index < songsList.length) {
                              Songs song = songsList[index];

                              return SongsListItem(
                                song: song,
                                playlist: songsList,
                                index: index,
                              );
                            } else {
                              return Container(
                                height: 100,
                                width: size.width,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: artistsList.length,
                                  itemBuilder: (context, index) {
                                    Artists artist =
                                        artistsList.elementAt(index);
                                    return Column(
                                      children: [
                                        Container(
                                          height: 75,
                                          width: 75,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            image: DecorationImage(
                                              image: artist.image.isNotEmpty
                                                  ? CachedNetworkImageProvider(
                                                      artist.image,
                                                    )
                                                  : const AssetImage(
                                                      'assets/user.png'),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          artist.name,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            }
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
