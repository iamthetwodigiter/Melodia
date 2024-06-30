import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/search/model/api_calls.dart';

class SearchResults extends StatefulWidget {
  final String query;
  const SearchResults({
    super.key,
    required this.query,
  });

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
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
    final size = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CupertinoNavigationBar(
              previousPageTitle: 'Home',
              middle: Text('Search'),
            ),
          ),
          SliverFillRemaining(
            child: SizedBox(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    CupertinoTextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        value = value.trimRight();
                        if (value.isNotEmpty) {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => SearchResults(query: value),
                            ),
                          );
                          _searchController.clear();
                        }
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
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: searchResult(widget.query),
                      builder: ((context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CupertinoActivityIndicator());
                        }
                        final data = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Songs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.85,
                              child: ListView.builder(
                                  itemCount: data.songs.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25),
                                      margin: const EdgeInsets.only(bottom: 5),
                                      height: 75,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 27, 27, 27),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: SizedBox(
                                              height: 85,
                                              width: size.width,
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: CachedNetworkImage(
                                                      imageUrl: data.songs
                                                          .elementAt(index)
                                                          .imageUrl,
                                                      height: 60,
                                                      placeholder:
                                                          (context, url) {
                                                        return const SizedBox(
                                                          height: 85,
                                                          width: 60,
                                                          child: Center(
                                                            child:
                                                                CupertinoActivityIndicator(),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Flexible(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data.songs
                                                              .elementAt(index)
                                                              .title,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          softWrap: true,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          maxLines: 2,
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          data.songs
                                                              .elementAt(index)
                                                              .album,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10),
                                                          softWrap: true,
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow.fade,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              var value =
                                                  data.songs.elementAt(index);

                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      MusicPlayer(
                                                    link:
                                                        value.downloadUrls.last,
                                                    id: value.id,
                                                    name: value.title,
                                                    imageUrl: value.imageUrl,
                                                    duration: value.duration,
                                                    artists: value.artist,
                                                    playlistData:
                                                        Playlist(idList: [
                                                      value.id
                                                    ], linkList: [
                                                      value.downloadUrls.last
                                                    ], imageUrlList: [
                                                      value.imageUrl
                                                    ], nameList: [
                                                      value.title
                                                    ], artistsList: [
                                                      value.artist
                                                    ], durationList: [
                                                      value.duration
                                                    ]),
                                                    index: 0,
                                                    shuffleMode: false,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              CupertinoIcons.play_circle,
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                            // const SizedBox(height: 10),
                            // const Text(
                            //   'Albums',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 30,
                            //   ),
                            // ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
