import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/search/model/api_calls.dart';
import 'package:melodia/provider/songs_notifier.dart';

class SearchResults extends ConsumerStatefulWidget {
  final String query;

  const SearchResults({
    super.key,
    required this.query,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<SearchResults> {
  final TextEditingController _searchController = TextEditingController();

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
          SliverToBoxAdapter(
            child: CupertinoNavigationBar(
              previousPageTitle: 'Home',
              middle: Text(
                'Search',
                style: TextStyle(color: AppPallete().accentColor),
              ),
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
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: searchResult(widget.query),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CupertinoActivityIndicator());
                        }

                        final songs = snapshot.data!.songs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Songs',
                              style: TextStyle(
                                color: AppPallete().accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.85,
                              child: ListView.builder(
                                itemCount: songs.length,
                                itemBuilder: (context, index) {
                                  final song = songs[index];

                                  return Container(
                                    key: ValueKey(song
                                        .id), // Unique key for each song item
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    margin: const EdgeInsets.only(bottom: 5),
                                    height: 75,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 27, 27, 27),
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
                                                      BorderRadius.circular(5),
                                                  child: CachedNetworkImage(
                                                    imageUrl: song.imageUrl,
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
                                                        song.title,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        softWrap: true,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        maxLines: 2,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        song.album,
                                                        style: const TextStyle(
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
                                            final selectedSong = SongModel(
                                              link: song.downloadUrls.last,
                                              id: song.id,
                                              name: song.title,
                                              imageUrl: song.imageUrl,
                                              duration: song.duration,
                                              artists: song.artist,
                                              playlistData: Playlist(
                                                idList: [song.id],
                                                linkList: [
                                                  song.downloadUrls.last
                                                ],
                                                imageUrlList: [song.imageUrl],
                                                nameList: [song.title],
                                                artistsList: [song.artist],
                                                durationList: [song.duration],
                                              ),
                                              index: 0,
                                              shuffleMode: false,
                                            );
                                           
                                            ref
                                                .read(currentSongProvider
                                                    .notifier)
                                                .state = selectedSong;
                                            ref
                                                .read(audioServiceProvider)!
                                                .play();

                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    MusicPlayer(
                                                        song: selectedSong),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            CupertinoIcons.play_circle,
                                            color: AppPallete().accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
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
