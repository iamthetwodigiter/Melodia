import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/homepage_model.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/homepage_provider.dart';
import 'package:melodia/providers/offline_audio_provider.dart';
import 'package:melodia/providers/search_history_provider.dart';
import 'package:melodia/providers/watch_history_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/menu_page.dart';
import 'package:melodia/views/search_result_page.dart';
import 'package:melodia/widgets/charts_cards.dart';
import 'package:melodia/widgets/freatured_playlists_cards.dart';
import 'package:melodia/widgets/history_cards.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/new_albums_cards.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late TextEditingController _searchController;
  List<String> _filteredSearchHistory = [];

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
    final searchHistory = ref.watch(searchHistoryProvider.notifier);
    if (query.trim().isNotEmpty) {
      searchHistory.addSearchHistory(query);
    }
  }

  void _onSearch(String query) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultPage(query: query),
      ),
    );
    _addSearchToHistory(query);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final homePageState = ref.watch(homePageProvider);
    final history = ref.watch(historyProvider);
    final audioProvider = ref.watch(audioPlayerProvider);
    final offlineAudioProvider = ref.watch(offlineAudioPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.menu),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MenuPage(),
              ),
            );
          },
        ),
        title: Text(
          "Melodia",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [Image.asset('assets/logo.png')],
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              _filteredSearchHistory.clear();
            });
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  homePageState.when(
                    data: (HomePageModel homePageData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 55),
                            NewAlbumsCards(
                              newAlbumData: homePageData.newAlbums,
                            ),
                            if (history.isNotEmpty)
                              HistoryCards(history: history),
                            FeaturedPlaylistsCards(
                              featuredPlaylistsData:
                                  homePageData.featuredPlaylists,
                            ),
                            ChartsCards(
                              chartsData: homePageData.charts,
                            ),
                            SizedBox(
                                height: audioProvider.isSlabShown ||
                                        offlineAudioProvider.isSlabShown
                                    ? 60
                                    : 0),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) {
                      return const Center(
                        child: Text(
                          "Error occured!!\nPlease check your internet connection and try again later!!",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  const MusicSlab(),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  children: [
                    CupertinoSearchTextField(
                      controller: _searchController,
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.black,
                      placeholder: 'Search',
                      placeholderStyle: TextStyle(
                          fontSize: 22,
                          color: AppTheme.accentColor(ref).withAlpha(150)),
                      prefixIcon: Icon(Icons.search,
                          size: 30,
                          color: AppTheme.accentColor(ref).withAlpha(150)),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: _onSearch,
                    ),
                    if (_filteredSearchHistory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 27, 27, 27),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _filteredSearchHistory
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
