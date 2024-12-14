import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/offline_audio_provider.dart';
import 'package:melodia/providers/offline_favorites_provider.dart';
import 'package:melodia/providers/offline_files_provider.dart';
import 'package:melodia/providers/offline_playlists_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/offline_player_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:swipe_to/swipe_to.dart';

class OfflineSongsListItem extends ConsumerStatefulWidget {
  final List<Songs> songList;
  final Songs song;
  final int index;
  final bool fromPlayingQueue;
  final Playlists? playlist;
  const OfflineSongsListItem({
    super.key,
    required this.songList,
    required this.song,
    required this.index,
    this.fromPlayingQueue = false,
    this.playlist,
  });

  @override
  ConsumerState<OfflineSongsListItem> createState() =>
      _OfflineSongsListItemState();
}

class _OfflineSongsListItemState extends ConsumerState<OfflineSongsListItem> {
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
    final favoritesNotifier = ref.watch(offlineFavoritesProvider.notifier);
    bool isFavorite = favoritesNotifier.isFavorite(widget.song);
    final offlinePlaylist = ref.watch(offlinePlaylistsProvider);
    final offlinePlaylistNotifier =
        ref.watch(offlinePlaylistsProvider.notifier);
    final filesNotifier = ref.watch(filesProvider.notifier);
    final audioNotifier = ref.watch(offlineAudioPlayerProvider.notifier);

    void addToPlaylist() {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            message: Text('Add "${widget.song.title}" to Playlist',
                style: const TextStyle(fontSize: 18)),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            actions: [
              for (final playlist in offlinePlaylist)
                CupertinoActionSheetAction(
                  onPressed: () {
                    bool isAdded = offlinePlaylistNotifier.addSongToPlaylist(
                        playlist, widget.song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      customSnackBar(
                          isAdded
                              ? '${widget.song.title} added to Playlist ${playlist.title}'
                              : 'Song already exists in Playlist',
                          ref),
                    );
                  },
                  child: Text(
                    playlist.title,
                    style: TextStyle(color: AppTheme.accentColor(ref)),
                  ),
                ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
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
                              String id =
                                  Random().nextInt(1000000000).toString();
                              int year = DateTime.now().year;
                              offlinePlaylistNotifier.addPlaylist(
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
                              style:
                                  TextStyle(color: AppTheme.accentColor(ref)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Create Playlist',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }

    return SwipeTo(
      iconOnLeftSwipe: Icons.delete,
      iconColor: Colors.red,
      onLeftSwipe: widget.playlist != null
          ? (details) {
              if (widget.playlist != null) {
                try {
                  offlinePlaylistNotifier.removeSongFromPlaylist(
                      widget.playlist!, widget.song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    customSnackBar(
                        '${widget.song.title} removed from playlist ${widget.playlist!.title}\nRefresh the page to update the list',
                        ref),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    customSnackBar('Unable to remove song from playlist', ref),
                  );
                  throw Exception(e);
                }
              }
            }
          : null,
      child: ListTile(
        splashColor: Colors.white.withAlpha(50),
        enableFeedback: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(widget.song.image),
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/song_thumb.png',
                  height: 50, width: 50);
            },
          ),
        ),
        trailing: SizedBox(
          width: 68,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFavorite) {
                      favoritesNotifier.removeFavorite(widget.song);
                    } else {
                      favoritesNotifier.addFavorite(widget.song);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    customSnackBar(
                        isFavorite
                            ? '${widget.song.title} removed from Favorites'
                            : '${widget.song.title} added to Favorites',
                        ref),
                  );
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(Icons.more_vert, color: AppTheme.accentColor(ref)),
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoActionSheet(
                        cancelButton: CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        title: Text(
                          widget.song.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              addToPlaylist();
                            },
                            child: Text(
                              'Add to Playlist',
                              style:
                                  TextStyle(color: AppTheme.accentColor(ref)),
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              filesNotifier
                                  .deleteSong([widget.song.downloadUrl]);
                              filesNotifier.refreshFiles;
                            },
                            child: Text(
                              'Delete',
                              style:
                                  TextStyle(color: AppTheme.accentColor(ref)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        title: Text(
          widget.song.title,
          style: const TextStyle(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          widget.song.artists.map((artist) => artist.name).toSet().join(', '),
          style: const TextStyle(color: Colors.grey, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          if (widget.fromPlayingQueue) {
            setState(() {
              Navigator.pop(context);
              audioNotifier.seek(Duration.zero, index: widget.index);
              audioNotifier.play();
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfflinePlayerScreen(
                  playlist: widget.songList,
                  initialIndex: widget.index,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
