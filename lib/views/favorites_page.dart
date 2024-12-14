import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/favorites_provider.dart';
import 'package:melodia/providers/offline_favorites_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/offline_song_list_item.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({
    super.key,
  });

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  bool isOnline = true;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final favorites = ref.watch(favoritesProvider);
    final offlineFavorites = ref.watch(offlineFavoritesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${isOnline ? "Online" : "Offline"} Favorites',
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        toolbarHeight: 50,
        actions: [
          CupertinoSwitch(
            activeTrackColor: AppTheme.accentColor(ref),
            value: isOnline,
            onChanged: (value) => setState(
              () {
                isOnline = value;
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          color: AppTheme.accentColor(ref),
          onRefresh: () async {
            ref.read(favoritesProvider);
            ref.read(offlineFavoritesProvider);
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: size.height,
                width: size.width,
                padding: const EdgeInsets.all(10),
                child: isOnline
                    ? favorites.isEmpty
                        ? const Center(
                            child: Text(
                              'No favorites added!',
                              style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              Songs song = favorites.elementAt(index);
                              return SongsListItem(
                                songsList: favorites,
                                song: song,
                                index: index,
                              );
                            },
                          )
                    : (offlineFavorites.isEmpty
                        ? const Center(
                            child: Text(
                              'No favorites added!',
                              style: TextStyle(fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: offlineFavorites.length,
                            itemBuilder: (context, index) {
                              Songs song = offlineFavorites.elementAt(index);
                              return OfflineSongsListItem(
                                songList: offlineFavorites,
                                song: song,
                                index: index,
                              );
                            },
                          )),
              ),
              const MusicSlab()
            ],
          ),
        ),
      ),
    );
  }
}
