import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:melodia/album/view/albums_details_page.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/home/model/api_calls.dart';
import 'package:melodia/core/offline_music_slab.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/player/view/mini_player.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/songs_notifier.dart';
import 'package:melodia/search/view/search_page.dart';
import 'package:melodia/settings/view/settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Box<SongModel> historyBox = Hive.box<SongModel>('history');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final song = ref.watch(currentSongProvider.notifier).state;
    ref.watch(currentSongProvider);
    ref.watch(audioServiceProvider.notifier)?.player.playing;
    ref.watch(offlineSongProvider);
    final offlineSong = ref.watch(offlineSongProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: IconButton(
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => const Settings(),
            ),
          ),
          icon: const Icon(
            CupertinoIcons.settings_solid,
            size: 20,
          ),
          color: AppPallete().accentColor,
        ),
        middle: Text(
          'Melodia',
          style: TextStyle(fontSize: 25, color: AppPallete().accentColor),
        ),
        leading: Image.asset('assets/logo.png'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: song == null && offlineSong == null
                  ? size.height * 0.845
                  : size.height * 0.763,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CupertinoColors.separator,
                              width: 3,
                            ),
                          ),
                          margin: EdgeInsets.zero,
                          height: 50,
                          width: double.infinity,
                          child: Text(
                            'Click to Search',
                            style: TextStyle(color: AppPallete().accentColor),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 25),
                    ),
                    SliverToBoxAdapter(
                      child: Text(
                        'New Albums',
                        style: TextStyle(
                          color: AppPallete().accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 25),
                    ),
                    SliverToBoxAdapter(
                      child: Consumer(
                        builder: (context, watch, child) {
                          final newAlbumsAsyncValue =
                              ref.watch(newAlbumsProvider);
        
                          return newAlbumsAsyncValue.when(
                            data: (newAlbums) => SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: newAlbums.length,
                                itemBuilder: (context, index) {
                                  final data = newAlbums[index];
                                  return Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                              EdgeInsets.zero,
                                            ),
                                          ),
                                          onPressed: () => Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => AlbumDetails(
                                                type: 'album',
                                                albumID: data.id,
                                              ),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: SizedBox(
                                              width: 150,
                                              child: CachedNetworkImage(
                                                imageUrl: data.image
                                                    .replaceAll('150', '500'),
                                                placeholder: (context, url) {
                                                  return const SizedBox(
                                                    width: 150,
                                                    child:
                                                        CupertinoActivityIndicator(),
                                                  );
                                                },
                                                errorWidget:
                                                    (context, url, error) {
                                                  return CachedNetworkImage(
                                                    imageUrl: data.image,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.title,
                                          style: TextStyle(
                                            color: AppPallete().subtitleTextColor,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(
                                  radius: 20.0,
                                  color: CupertinoColors.activeBlue),
                            ),
                            error: (error, stack) => const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text('Error occured!!'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (historyBox.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Container(height: 10),
                      ),
                      SliverToBoxAdapter(
                        child: Text(
                          'Last Played',
                          style: TextStyle(
                            color: AppPallete().accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(height: 25),
                      ),
                    ],
                    if (historyBox.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                historyBox.length > 10 ? 10 : historyBox.length,
                            itemBuilder: (context, index) {
                              int i = historyBox.length - index - 1;
                              SongModel song = historyBox.values.elementAt(i);
                              return Container(
                                constraints: const BoxConstraints(maxWidth: 150),
                                padding: const EdgeInsets.only(right: 10),
                                child: Column(
                                  children: [
                                    TextButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero),
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(currentSongProvider.notifier)
                                            .state = song;
                                        Navigator.push(
                                          context,
                                          CustomPageRoute(
                                            page: MusicPlayer(song: song),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 175,
                                          child: CachedNetworkImage(
                                            imageUrl: song.imageUrl,
                                            errorWidget: (context, url, error) {
                                              return SizedBox(
                                                height: 141,
                                                child: Image.asset(
                                                    'assets/song_thumb.png'),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      song.name,
                                      style: TextStyle(
                                        color: AppPallete().accentColor,
                                        fontSize: 12,
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // SliverToBoxAdapter(
                    //   child: const SizedBox(height: 25),
                    // ),
                    SliverToBoxAdapter(
                      child: Text(
                        'Featured Playlists',
                        style: TextStyle(
                          color: AppPallete().accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 25),
                    ),
                    SliverToBoxAdapter(
                      child: Consumer(
                        builder: (context, watch, child) {
                          final featuredPlaylistAsyncValue =
                              ref.watch(featuredPlaylistProvider);
        
                          return featuredPlaylistAsyncValue.when(
                            data: (featuredPlaylists) => SizedBox(
                              height: 225,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredPlaylists.length,
                                itemBuilder: (context, index) {
                                  final data = featuredPlaylists[index];
                                  return Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 175),
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.zero),
                                          ),
                                          onPressed: () => Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => AlbumDetails(
                                                type: 'playlist',
                                                albumID: data.listID,
                                              ),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: SizedBox(
                                              width: 175,
                                              child: CachedNetworkImage(
                                                imageUrl: data.image
                                                    .replaceAll('150', '500'),
                                                placeholder: (context, url) {
                                                  return const Center(
                                                    child: SizedBox(
                                                      height: 150,
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    ),
                                                  );
                                                },
                                                errorWidget:
                                                    (context, url, error) {
                                                  return CachedNetworkImage(
                                                    imageUrl: data.image,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.listname,
                                          style: TextStyle(
                                            color: AppPallete().subtitleTextColor,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(
                                  radius: 20.0,
                                  color: CupertinoColors.activeBlue),
                            ),
                            error: (error, stack) => const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text('Error occured!!'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        
                    SliverToBoxAdapter(
                      child: Text(
                        'Other Playlists',
                        style: TextStyle(
                          color: AppPallete().accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 25),
                    ),
                    SliverToBoxAdapter(
                      child: Consumer(
                        builder: (context, watch, child) {
                          final otherPlaylistsAsyncValue =
                              ref.watch(otherPlaylistsProvider);
        
                          return otherPlaylistsAsyncValue.when(
                            data: (otherPlaylists) => SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: otherPlaylists.length,
                                itemBuilder: (context, index) {
                                  final data = otherPlaylists[index];
                                  return Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 175),
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.zero),
                                          ),
                                          onPressed: () => Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => AlbumDetails(
                                                type: 'playlist',
                                                albumID: data.id,
                                              ),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: SizedBox(
                                              width: 175,
                                              child: CachedNetworkImage(
                                                imageUrl: data.imageUrl
                                                    .replaceAll('150', '500'),
                                                errorWidget:
                                                    (context, url, error) {
                                                  return CachedNetworkImage(
                                                    imageUrl: data.imageUrl,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.name,
                                          style: TextStyle(
                                            color: AppPallete().subtitleTextColor,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(
                                  radius: 20.0,
                                  color: CupertinoColors.activeBlue),
                            ),
                            error: (error, stack) => const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text('Error occured!!'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            song != null
                ? Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.zero,
                    height: size.height * 0.075,
                    child: const MiniPlayer(),
                  )
                : offlineSong != null
                    ? SizedBox(
                        height: 65,
                        child: OfflineMusicSlab(
                          song: ref.watch(offlineSongProvider)!,
                        ),
                      )
                    : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
