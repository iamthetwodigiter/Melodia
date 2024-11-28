import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/providers/search_history_provider.dart';
import 'package:melodia/providers/search_result_provider.dart';
import 'package:melodia/providers/search_song_data_provider.dart';
import 'package:melodia/providers/watch_history_provider.dart';
import 'package:melodia/providers/youtube_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/albums_page.dart';
import 'package:melodia/views/player_screen.dart';
import 'package:melodia/views/playlists_page.dart';

class SearchResultPage extends ConsumerStatefulWidget {
  final String query;
  const SearchResultPage({
    super.key,
    required this.query,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  late TextEditingController _searchController;
  List<String> _filteredSearchHistory = [];
  bool isYoutube = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterSearchHistory);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSearchHistory);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSearchHistory() {
    final searchHistory = ref.read(searchHistoryProvider);
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      _filteredSearchHistory = searchHistory.take(5).toList();
    } else {
      _filteredSearchHistory = searchHistory
          .where((history) => history.toLowerCase().contains(query))
          .take(5)
          .toList();
    }
    setState(() {});
  }

  void _addSearchToHistory(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addSearchHistory(query);
    }
  }

  void _onSearch(String query) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultPage(query: query),
      ),
    );
    _addSearchToHistory(query);
    _searchController.clear();
    setState(() {
      _filteredSearchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final searchResult = ref.watch(searchResultProvider(widget.query));
    final history = ref.watch(historyProvider.notifier);
    final youtube = ref.watch(youtubeProvider(widget.query));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Results",
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => setState(() => _filteredSearchHistory.clear()),
          child: Stack(
            children: [
              searchResult.when(
                data: (data) {
                  return SizedBox(
                    height: size.height,
                    width: size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: CupertinoSearchTextField(
                              controller: _searchController,
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.black,
                              placeholder: widget.query,
                              placeholderStyle: TextStyle(
                                fontSize: 22,
                                color: AppTheme.accentColor(ref).withAlpha(150),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 30,
                                color: AppTheme.accentColor(ref).withAlpha(150),
                              ),
                              style: const TextStyle(color: Colors.white),
                              onSubmitted: _onSearch,
                            ),
                          ),
                          CupertinoListSection.insetGrouped(
                            backgroundColor: Colors.transparent,
                            header: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isYoutube ? 'YouTube' : 'Saavn',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                  ),
                                ),
                                CupertinoSwitch(
                                  activeColor: AppTheme.accentColor(ref),
                                  value: isYoutube,
                                  onChanged: (value) {
                                    setState(() {
                                      isYoutube = !isYoutube;
                                    });
                                  },
                                ),
                              ],
                            ),
                            children: isYoutube
                                ? youtube.when(data: (data) {
                                    return data.map((song) {
                                      return CupertinoListTile(
                                          padding: const EdgeInsets.all(15),
                                          leadingSize: 50,
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: song.image,
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) {
                                                return Image.asset(
                                                  'assets/song_thumb.png',
                                                );
                                              },
                                            ),
                                          ),
                                          title: Text(
                                            song.title,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          subtitle: Text(
                                            song.artists.first.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PlayerScreen(
                                                  playlist: data,
                                                  initialIndex:
                                                      data.indexOf(song),
                                                ),
                                              ),
                                            );
                                          });
                                    }).toList();
                                  }, error: (err, stack) {
                                    return [
                                      const Text(
                                          'Error occured while fetching the data')
                                    ];
                                  }, loading: () {
                                    return [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const CircularProgressIndicator
                                            .adaptive(),
                                      )
                                    ];
                                  })
                                : data.searchResultSongs.map((song) {
                                    return CupertinoListTile(
                                      padding: const EdgeInsets.all(15),
                                      leadingSize: 50,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: song.image,
                                          height: 50,
                                          width: 50,
                                          errorWidget: (context, url, error) {
                                            return Image.asset(
                                              'assets/song_thumb.png',
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(
                                        song.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        song.artists,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      onTap: () async {
                                        final playlist = ref.watch(
                                            searchSongDataProvider(song.id));

                                        if (playlist is AsyncData) {
                                          final data = playlist.value;
                                          history.addHistory(data![0]);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PlayerScreen(
                                                playlist: data,
                                                initialIndex: 0,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }).toList(),
                          ),
                          if (!isYoutube)
                            CupertinoListSection.insetGrouped(
                              backgroundColor: Colors.transparent,
                              header: const Text(
                                'Albums',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                ),
                              ),
                              children: data.searchResultAlbums.map((album) {
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(15),
                                  leadingSize: 50,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: album.image,
                                      height: 50,
                                      width: 50,
                                      errorWidget: (context, url, error) {
                                        return Image.asset(
                                            'assets/playlist_art.png');
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    album.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    album.artist,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AlbumsPage(
                                          albumID: album.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          if (!isYoutube)
                            CupertinoListSection.insetGrouped(
                              backgroundColor: Colors.transparent,
                              header: const Text(
                                'Playlists',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                ),
                              ),
                              children:
                                  data.searchResultPlaylists.map((playlist) {
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(15),
                                  leadingSize: 50,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: playlist.image,
                                      height: 50,
                                      width: 50,
                                      errorWidget: (context, url, error) {
                                        return Image.asset(
                                            'assets/playlist_art.png');
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    playlist.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PlaylistsPage(
                                          playlistID: playlist.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) {
                  return Center(
                    child: Text("Error: $error"),
                  );
                },
              ),
              if (_filteredSearchHistory.isNotEmpty)
                Positioned(
                  top: 65, // Adjusted positioning
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 27, 27, 27),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: _filteredSearchHistory.reversed
                          .toList()
                          .sublist(
                              0, _filteredSearchHistory.length > 3 ? 3 : null)
                          .map((history) => ListTile(
                                title: Text(
                                  history,
                                  style: TextStyle(
                                    color: AppTheme.accentColor(ref),
                                  ),
                                ),
                                onTap: () {
                                  _onSearch(history);
                                },
                              ))
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
