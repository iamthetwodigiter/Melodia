import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/user_playlists_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class UserPlaylistsPage extends ConsumerStatefulWidget {
  final Playlists playlist;
  const UserPlaylistsPage({
    super.key,
    required this.playlist,
  });
  @override
  ConsumerState<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends ConsumerState<UserPlaylistsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    List<Songs> songsList = widget.playlist.songs;
    final userPlaylistsNotifier = ref.watch(userPlaylistsProvider.notifier);
    bool isPlaylistAdded =
        userPlaylistsNotifier.isPlaylistAdded(widget.playlist);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.playlist.title,
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                userPlaylistsNotifier.removePlaylist(widget.playlist);
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(customSnackBar('Removed Playlist, Please Go Back to Update The List',ref));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.playlist.type == 'playlist'
                  ? Icon(
                      isPlaylistAdded ? Icons.favorite : Icons.favorite_outline,
                      color: isPlaylistAdded ? Colors.red : null,
                    )
                  : const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ],
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: songsList.length,
            itemBuilder: (context, index) {
              Songs song = songsList[index];
              return SongsListItem(
                song: song,
                playlist: songsList,
                index: index,
              );
            },
          ),
        ),
      ),
    );
  }
}
