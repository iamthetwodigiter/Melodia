import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/albums_model.dart';
import 'package:melodia/models/artists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/user_albums_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class UserAlbumsPage extends ConsumerStatefulWidget {
  final Albums album;
  const UserAlbumsPage({
    super.key,
    required this.album,
  });

  @override
  ConsumerState<UserAlbumsPage> createState() => _UserAlbumsPageState();
}

class _UserAlbumsPageState extends ConsumerState<UserAlbumsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    List<Songs> songsList = widget.album.songs;
    List<Artists> artistsList = widget.album.artists;

    final userAlbumsNotifier = ref.watch(userAlbumsProvider.notifier);
    bool isAlbumAdded = userAlbumsNotifier.isAlbumAdded(widget.album);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.album.title,
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
                userAlbumsNotifier.removeAlbum(widget.album);
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(customSnackBar('Removed Album',ref));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isAlbumAdded ? Icons.favorite : Icons.favorite_outline,
                color: isAlbumAdded ? Colors.red : null,
              ),
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
            ref.read(userAlbumsProvider);
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: size.height,
                width: size.width,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: widget.album.image,
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
                            Text(
                                '${widget.album.type.toUpperCase()} • ${widget.album.year}'),
                            Text((widget.album.language ?? '').toUpperCase()),
                            Text('${widget.album.songCount.toString()} Songs'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    backgroundColor: const WidgetStatePropertyAll(
                                        Color.fromARGB(255, 59, 59, 59)),
                                    foregroundColor: WidgetStatePropertyAll(
                                        AppTheme.accentColor(ref)),
                                    padding: const WidgetStatePropertyAll(
                                        EdgeInsets.zero),
                                  ),
                                  child: const Icon(Icons.play_arrow),
                                ),
                                const SizedBox(width: 5),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: songsList.length + 1,
                        itemBuilder: (context, index) {
                          if (index < songsList.length) {
                            Songs song = songsList[index];
                            return SongsListItem(
                              song: song,
                              songsList: songsList,
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
                                  Artists artist = artistsList.elementAt(index);
                                  return Column(
                                    children: [
                                      Container(
                                        height: 75,
                                        width: 75,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          image: DecorationImage(
                                            image: artist.image.isNotEmpty
                                                ? CachedNetworkImageProvider(
                                                    artist.image,
                                                  )
                                                : const AssetImage('assets/user.png'),
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
                  ],
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
