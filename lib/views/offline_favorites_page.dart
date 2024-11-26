import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/offline_favorites_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/offline_song_list_item.dart';

class OfflineFavoritesPage extends ConsumerStatefulWidget {
  const OfflineFavoritesPage({
    super.key,
  });

  @override
  ConsumerState<OfflineFavoritesPage> createState() => _OfflineFavoritesPageState();
}

class _OfflineFavoritesPageState extends ConsumerState<OfflineFavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final favorites = ref.watch(offlineFavoritesProvider);
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Offline Favorites',
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
      ),
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(10),
          child: favorites.isEmpty
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
                    return OfflineSongsListItem(
                      playlist: favorites,
                      song: song,
                      index: index,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
