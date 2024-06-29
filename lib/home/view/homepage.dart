import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodia/album/view/albums_details_page.dart';
import 'package:melodia/home/model/api_calls.dart';
import 'package:melodia/home/model/homepage_repository.dart';
import 'package:melodia/search/view/search_page.dart';
import 'package:melodia/settings/view/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

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
    return CupertinoPageScaffold(
      child: SingleChildScrollView(
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
                    // padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 0.175,
                        color: CupertinoColors.white,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const Settings()));
                      },
                      icon: const Icon(
                        CupertinoIcons.bars,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Melodia',
                    style: TextStyle(
                      fontSize: 18,
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
                          builder: (context) => SearchResults(query: value)));
                }
                _searchController.clear();
              },
              padding: const EdgeInsets.all(10),
              placeholder: 'Search',
              placeholderStyle: TextStyle(
                color: CupertinoColors.white.withOpacity(
                  0.4,
                ),
              ),
              clearButtonMode: OverlayVisibilityMode.editing,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 27, 27, 27),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'New Albums',
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            const SizedBox(height: 25),
            FutureBuilder<List<NewAlbums>>(
              future: getHomePage(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0, color: CupertinoColors.activeBlue),
                  );
                }
                return SizedBox(
                  height: 175,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.elementAt(index);
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 150),
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero)),
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
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 150,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        data.image.replaceAll('150', '500'),
                                    placeholder: (context, url) {
                                      return const SizedBox(width: 150, child: CupertinoActivityIndicator());
                                    },
                                    errorWidget: (context, url, error) {
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
                );
              },
            ),
            const SizedBox(height: 25),
            const Text(
              'Featured Playlists',
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            const SizedBox(height: 25),
            FutureBuilder<List<FeaturedPlaylist>>(
              future: featuredPlaylist(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0, color: CupertinoColors.activeBlue),
                  );
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.elementAt(index);
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 175),
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero)),
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
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 175,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        data.image.replaceAll('150', '500'),
                                    errorWidget: (context, url, error) {
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
                );
              },
            ),
            const SizedBox(height: 25),
            const Text(
              'Other Playlists',
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            const SizedBox(height: 25),
            FutureBuilder<List<OtherPlaylists>>(
              future: getOtherPlaylists(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0, color: CupertinoColors.activeBlue),
                  );
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.elementAt(index);
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 175),
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero)),
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
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 175,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        data.imageUrl.replaceAll('150', '500'),
                                    errorWidget: (context, url, error) {
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
