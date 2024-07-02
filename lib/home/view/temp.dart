import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:melodia/album/view/albums_details_page.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/home/model/api_calls.dart';
import 'package:melodia/player/view/mini_player.dart';
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
  Box historyBox = Hive.box('history');
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

    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight:
                      song != null ? size.height * 0.9 : size.height * 1),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Platform.isAndroid ? 20 : 0),
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 0.175,
                                  color: AppPallete().accentColor,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => const Settings(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  CupertinoIcons.bars,
                                  color: AppPallete().accentColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            Text(
                              'Melodia',
                              style: TextStyle(
                                color: AppPallete().accentColor,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Image.asset('assets/logo.png', height: 30),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      CupertinoTextField(
                        controller: _searchController,
                        onSubmitted: (value) {
                          value = value.trimRight();
                          if (value.isNotEmpty) {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    SearchResults(query: value),
                              ),
                            );
                          }
                          _searchController.clear();
                        },
                        padding: const EdgeInsets.all(10),
                        placeholder: 'Search',
                        placeholderStyle: TextStyle(
                          color: AppPallete().accentColor.withOpacity(0.4),
                        ),
                        clearButtonMode: OverlayVisibilityMode.editing,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    AppPallete().accentColor.withOpacity(0.4))),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'New Albums',
                        style: TextStyle(
                          color: AppPallete().accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Consumer(
                        builder: (context, watch, child) {
                          final newAlbumsAsyncValue =
                              ref.watch(newAlbumsProvider);

                          return newAlbumsAsyncValue.when(
                            data: (newAlbums) => SizedBox(
                              height: 175,
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
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.zero)),
                                          onPressed: () => Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  AlbumDetails(
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
                                                          CupertinoActivityIndicator());
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
                                          style: const TextStyle(
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
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(
                                  radius: 20.0,
                                  color: CupertinoColors.activeBlue),
                            ),
                            error: (error, stack) => Center(
                              child: Text(error.toString()),
                            ),
                          );
                        },
                      ),
                      historyBox.isNotEmpty
                          ? Container(height: 25)
                          : const SizedBox(),
                      historyBox.isNotEmpty
                          ? Container(
                              height: 200,
                              color: Colors.red,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: historyBox.length > 10
                                      ? 5
                                      : historyBox.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: historyBox.values
                                              .elementAt(index)[4]
                                              .toString(),
                                          height: 150,
                                        ),
                                        Text(historyBox.values
                                              .elementAt(index)[2]
                                              .toString(),)
                                      ],
                                    );
                                  })

                              // child: ListView.builder(
                              //     itemCount: historyBox.length > 10
                              //         ? 5
                              //         : ((historyBox.length) ~/ 2),
                              //     itemBuilder: (context, index) {

                              //       return Container(
                              //         height: 200,
                              //         color: Colors.red,
                              //         child: Text(historyBox.length.toString()),
                              //       );
                              //     }),
                              )
                          : Container(),
                      const SizedBox(height: 25),
                      Text(
                        'Featured Playlists',
                        style: TextStyle(
                          color: AppPallete().accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Consumer(
                        builder: (context, watch, child) {
                          final featuredPlaylistAsyncValue =
                              ref.watch(featuredPlaylistProvider);

                          return featuredPlaylistAsyncValue.when(
                            data: (featuredPlaylists) => SizedBox(
                              height: 200,
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
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.zero)),
                                          onPressed: () => Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  AlbumDetails(
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
                                          style: const TextStyle(
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
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(
                                radius: 20.0,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Text(error.toString()),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Other Playlists',
                        style: TextStyle(
                          color: AppPallete().accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Consumer(
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
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.zero)),
                                          onPressed: () => Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  AlbumDetails(
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
                                                imageUrl: historyBox.values
                                              .elementAt(index)[4]
                                              .toString(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          historyBox.values
                                              .elementAt(index)[2]
                                              .toString(),
                                          style: const TextStyle(
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
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(
                                  radius: 20.0,
                                  color: CupertinoColors.activeBlue),
                            ),
                            error: (error, stack) => Center(
                              child: Text(error.toString()),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            song != null
                ? Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.zero,
                    height: size.height * 0.1,
                    child: const MiniPlayer(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
