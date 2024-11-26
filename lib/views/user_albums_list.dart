import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/albums_model.dart';
import 'package:melodia/providers/user_albums_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/user_albums_page.dart';
import 'package:melodia/widgets/custom_snackbar.dart';

class UserAlbumsList extends ConsumerStatefulWidget {
  const UserAlbumsList({super.key});

  @override
  ConsumerState<UserAlbumsList> createState() => _UserAlbumsListState();
}

class _UserAlbumsListState extends ConsumerState<UserAlbumsList> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final userAlbums = ref.watch(userAlbumsProvider);
    final userAlbumsNotifier = ref.watch(userAlbumsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Album",
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
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: userAlbums.isEmpty
              ? const Center(
                  child: Text(
                    'No albums added!',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: userAlbums.length,
                  itemBuilder: (context, index) {
                    Albums album = userAlbums.elementAt(index);

                    return ListTile(
                      leading: album.image.contains('http')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: album.image,
                                height: 50,
                                width: 50,
                                errorWidget: (context, url, error) {
                                  return Image.asset(
                                    'assets/playlist_art.png',
                                  );
                                },
                              ),
                            )
                          : Image.asset(
                              'assets/Album_art.png',
                            ),
                      title: Text(
                        album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${album.songCount.toString()} Songs'),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          userAlbumsNotifier.removeAlbum(album);
                          ScaffoldMessenger.of(context).showSnackBar(
                            customSnackBar('Removed album from library',ref),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return UserAlbumsPage(album: album);
                        }));
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
