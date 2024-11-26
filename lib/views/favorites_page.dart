import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/favorites_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({
    super.key,
  });

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Favorites',
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
                    return SongsListItem(
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
