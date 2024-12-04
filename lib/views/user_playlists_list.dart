import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/providers/user_playlists_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/user_playlists_page.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:melodia/widgets/music_slab.dart';

class UserPlaylistsList extends ConsumerStatefulWidget {
  const UserPlaylistsList({super.key});

  @override
  ConsumerState<UserPlaylistsList> createState() => _UserPlaylistsListState();
}

class _UserPlaylistsListState extends ConsumerState<UserPlaylistsList> {
  late TextEditingController _playlistNameController;

  @override
  void initState() {
    super.initState();
    _playlistNameController = TextEditingController();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final userPlaylists = ref.watch(userPlaylistsProvider);

    final userPlaylistNotifier = ref.watch(userPlaylistsProvider.notifier);

    void playlistNameDialog() {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Create Playlist'),
            content: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CupertinoTextField(
                controller: _playlistNameController,
                placeholder: 'Enter playlist name',
                cursorColor: AppTheme.accentColor(ref),
                style: TextStyle(
                  color: AppTheme.accentColor(ref),
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                  _playlistNameController.clear();
                },
                isDestructiveAction: true,
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  String id = Random().nextInt(1000000000).toString();
                  int year = DateTime.now().year;
                  userPlaylistNotifier.addPlaylist(
                    Playlists(
                      id: id,
                      title: _playlistNameController.text,
                      type: 'User Playlist',
                      year: year,
                      language: '',
                      explicitContent: false,
                      url: '',
                      songCount: 0,
                      artists: [],
                      image: '',
                      songs: [],
                    ),
                  );
                  Navigator.of(context).pop();
                  _playlistNameController.clear();
                },
                child: Text(
                  'Create',
                  style: TextStyle(color: AppTheme.accentColor(ref)),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Playlist",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                playlistNameDialog();
              },
              child: Icon(Icons.add, color: AppTheme.accentColor(ref)),
            ),
          ),
        ],
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          color: AppTheme.accentColor(ref),
          onRefresh: () async {
            ref.read(userPlaylistsProvider);
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: size.height,
                width: size.width,
                child: userPlaylists.isEmpty
                    ? const Center(
                        child: Text(
                          'No playlists added!',
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: userPlaylists.length,
                        itemBuilder: (context, index) {
                          Playlists playlist = userPlaylists.elementAt(index);
              
                          return ListTile(
                            leading: playlist.image.contains('http')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: playlist.image,
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
                                    'assets/playlist_art.png',
                                  ),
                            title: Text(
                              playlist.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle:
                                Text('${playlist.songCount.toString()} Songs'),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                userPlaylistNotifier.removePlaylist(playlist);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  customSnackBar(
                                      'Removed playlist ${playlist.title} from library', ref),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return UserPlaylistsPage(playlist: playlist);
                              }));
                            },
                          );
                        },
                      ),
              ),
              const MusicSlab()
            ],
          ),
        ),
      ),
    );
  }
}
