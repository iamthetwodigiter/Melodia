import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/library/view/playlist_screen.dart';
import 'package:melodia/provider/songs_notifier.dart';
import 'package:melodia/search/model/api_calls.dart';
import 'package:melodia/search/model/search_repository.dart';
import 'package:melodia/search/model/suggestions.dart';

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
  Box<Playlist> playlistBox = Hive.box<Playlist>('playlist');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Playlist> fetchAndCreatePlaylist(String songId) async {
    final suggestionResults = await getSuggestions(songId);

    List<String> idList = [];
    List<String> linkList = [];
    List<String> imageUrlList = [];
    List<String> nameList = [];
    List<List<String>> artistList = [];
    List<String> durationList = [];

    for (var item in suggestionResults) {
      idList.add(item.id);
      linkList.add(item.downloadUrls.last);
      imageUrlList.add(item.imageUrl);
      nameList.add(item.title);
      artistList.add(item.artist);
      durationList.add(item.duration);
    }

    return Playlist(
      idList: idList,
      linkList: linkList,
      imageUrlList: imageUrlList,
      nameList: nameList,
      artistsList: artistList,
      durationList: durationList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CupertinoNavigationBar(
              previousPageTitle: 'Search',
              middle: Text(
                'Search Results',
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
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: CupertinoColors.separator, width: 2)),
                      padding: const EdgeInsets.all(10),
                      controller: _searchController,
                      placeholder: 'Search',
                      clearButtonMode: OverlayVisibilityMode.editing,
                      onSubmitted: (value) {
                        value = value.trimRight();
                        if (value.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => SearchResults(query: value),
                            ),
                          );
                        }
                        _searchController.clear();
                      },
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

                        final List<SongsResult> songs = snapshot.data!.songs;
                        return SizedBox(
                          height: size.height * 0.8,
                          child: ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final favorites = playlistBox.get('Favorites');
                              bool songExists = favorites!.idList
                                  .contains(songs.elementAt(index).id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CupertinoListTile(
                                    onTap: () async {
                                      // Show a loading indicator while fetching data
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) => const Center(
                                          child: CupertinoActivityIndicator(),
                                        ),
                                      );

                                      try {
                                        final updatedPlaylist =
                                            await fetchAndCreatePlaylist(
                                                songs.elementAt(index).id);

                                        final song = SongModel(
                                          link: songs
                                              .elementAt(index)
                                              .downloadUrls
                                              .last,
                                          id: songs.elementAt(index).id,
                                          name: songs
                                              .elementAt(index)
                                              .title
                                              .split('(')[0],
                                          imageUrl:
                                              songs.elementAt(index).imageUrl,
                                          duration:
                                              songs.elementAt(index).duration,
                                          artists:
                                              songs.elementAt(index).artist,
                                          index: index,
                                          playlistData: updatedPlaylist,
                                          shuffleMode: false,
                                          playlistName: songs.elementAt(index).album,
                                          year: songs.elementAt(index).year,
                                          isUserCreated: false
                                        );

                                        ref
                                            .read(currentSongProvider.notifier)
                                            .state = song;
                                        ref.watch(audioServiceProvider)!.play();

                                        // Close the loading indicator and then navigate
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          CustomPageRoute(
                                            page: MusicPlayer(song: song),
                                          ),
                                        );
                                      } catch (e) {
                                        Navigator.of(context)
                                            .pop(); // Close the loading indicator in case of error
                                      }
                                    },
                                    backgroundColor:
                                        AppPallete().accentColor.withAlpha(20),
                                    padding: const EdgeInsets.all(15),
                                    leading: CachedNetworkImage(
                                      imageUrl: songs.elementAt(index).imageUrl,
                                      height: 50,
                                      placeholder: (context, url) {
                                        return const SizedBox(width: 60);
                                      },
                                      errorWidget: (context, url, error) {
                                        return SizedBox(
                                          height: 50,
                                          child: Image.asset(
                                            'assets/song_thumb.png',
                                            height: 50,
                                          ),
                                        );
                                      },
                                    ),
                                    title: Text(
                                      songs.elementAt(index).title,
                                      style: TextStyle(
                                        color: darkMode
                                            ? AppPallete.subtitleDarkTextColor
                                            : AppPallete().subtitleTextColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      songs.elementAt(index).artist.join(", "),
                                      style: TextStyle(
                                        color: darkMode
                                            ? AppPallete.subtitleDarkTextColor
                                            : AppPallete().subtitleTextColor,
                                      ),
                                    ),
                                    trailing: Row(
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            if (!songExists) {
                                              final updatedPlaylist = Playlist(
                                                idList:
                                                    List.from(favorites.idList)
                                                      ..add(songs
                                                          .elementAt(index)
                                                          .id),
                                                linkList: List.from(
                                                    favorites.linkList)
                                                  ..add(songs
                                                      .elementAt(index)
                                                      .downloadUrls
                                                      .last),
                                                imageUrlList: List.from(
                                                    favorites.imageUrlList)
                                                  ..add(songs
                                                      .elementAt(index)
                                                      .imageUrl),
                                                nameList: List.from(
                                                    favorites.nameList)
                                                  ..add(songs
                                                      .elementAt(index)
                                                      .title
                                                      .split('(')[0]),
                                                artistsList: List.from(
                                                    favorites.artistsList)
                                                  ..add(songs
                                                      .elementAt(index)
                                                      .artist),
                                                durationList: List.from(
                                                    favorites.durationList)
                                                  ..add(songs
                                                      .elementAt(index)
                                                      .duration),
                                              );
                                              playlistBox.put(
                                                  'Favorites', updatedPlaylist);
                                            } else {
                                              final updatedPlaylist = Playlist(
                                                idList:
                                                    List.from(favorites.idList)
                                                      ..remove(songs
                                                          .elementAt(index)
                                                          .id),
                                                linkList: List.from(
                                                    favorites.linkList)
                                                  ..remove(songs
                                                      .elementAt(index)
                                                      .downloadUrls
                                                      .last),
                                                imageUrlList: List.from(
                                                    favorites.imageUrlList)
                                                  ..remove(songs
                                                      .elementAt(index)
                                                      .title),
                                                nameList: List.from(
                                                    favorites.nameList)
                                                  ..remove(songs
                                                      .elementAt(index)
                                                      .title
                                                      .split('(')[0]),
                                                artistsList: List.from(
                                                    favorites.artistsList)
                                                  ..remove(songs
                                                      .elementAt(index)
                                                      .artist),
                                                durationList: List.from(
                                                    favorites.durationList)
                                                  ..remove(songs
                                                      .elementAt(index)
                                                      .duration),
                                              );
                                              playlistBox.put(
                                                  'Favorites', updatedPlaylist);
                                            }
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            songExists
                                                ? CupertinoIcons.heart_fill
                                                : CupertinoIcons.heart,
                                            color:
                                                CupertinoColors.destructiveRed,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) {
                                                if (playlistBox.length != 0) {
                                                  return CupertinoActionSheet(
                                                    actions: [
                                                      CupertinoActionSheetAction(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          showCupertinoModalPopup(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              if (playlistBox
                                                                      .length !=
                                                                  0) {
                                                                final playlists =
                                                                    playlistBox
                                                                        .keys
                                                                        .toList();
                                                                return CupertinoActionSheet(
                                                                  actions: playlists
                                                                      .map(
                                                                          (name) {
                                                                    final currentPlaylist =
                                                                        playlistBox
                                                                            .get(name);
                                                                    if (currentPlaylist !=
                                                                        null) {
                                                                      return CupertinoActionSheetAction(
                                                                        onPressed:
                                                                            () {
                                                                          bool
                                                                              songExists =
                                                                              currentPlaylist.idList.contains(songs.elementAt(index).id);

                                                                          if (!songExists) {
                                                                            final updatedPlaylist =
                                                                                Playlist(
                                                                              idList: List.from(currentPlaylist.idList)..add(songs.elementAt(index).id),
                                                                              linkList: List.from(currentPlaylist.linkList)..add(songs.elementAt(index).downloadUrls.last),
                                                                              imageUrlList: List.from(currentPlaylist.imageUrlList)..add(songs.elementAt(index).imageUrl),
                                                                              nameList: List.from(currentPlaylist.nameList)..add(songs.elementAt(index).title.split('(')[0]),
                                                                              artistsList: List.from(currentPlaylist.artistsList)..add(songs.elementAt(index).artist),
                                                                              durationList: List.from(currentPlaylist.durationList)..add(songs.elementAt(index).duration),
                                                                            );
                                                                            playlistBox.put(name,
                                                                                updatedPlaylist);
                                                                          }

                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                            name),
                                                                      );
                                                                    } else {
                                                                      return CupertinoActionSheetAction(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Error: Playlist not found'),
                                                                      );
                                                                    }
                                                                  }).toList(),
                                                                  cancelButton:
                                                                      CupertinoActionSheetAction(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    isDestructiveAction:
                                                                        true,
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                  ),
                                                                );
                                                              } else {
                                                                return CupertinoActionSheet(
                                                                  actions: [
                                                                    CupertinoActionSheetAction(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          'Create Playlist'),
                                                                    ),
                                                                  ],
                                                                  cancelButton:
                                                                      CupertinoActionSheetAction(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    isDestructiveAction:
                                                                        true,
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          );
                                                        },
                                                        child: Text(
                                                          'Add to Playlist',
                                                          style: TextStyle(
                                                              color: AppPallete()
                                                                  .subtitleTextColor),
                                                        ),
                                                      ),
                                                    ],
                                                    cancelButton:
                                                        CupertinoActionSheetAction(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      isDestructiveAction: true,
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                  );
                                                }
                                                return CupertinoActionSheet(
                                                  actions: [
                                                    CupertinoActionSheetAction(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
                                                                const LibraryScreen(),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          'Please Create Playlist First'),
                                                    ),
                                                  ],
                                                  cancelButton:
                                                      CupertinoActionSheetAction(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    isDestructiveAction: true,
                                                    child: const Text('Cancel'),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            CupertinoIcons.ellipsis_vertical,
                                            size: 20,
                                            color: AppPallete().accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}
