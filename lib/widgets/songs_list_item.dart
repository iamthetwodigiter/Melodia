import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:melodia/models/playlists_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/audio_provider.dart';
import 'package:melodia/providers/favorites_provider.dart';
import 'package:melodia/providers/offline_files_provider.dart';
import 'package:melodia/providers/playing_queue_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/providers/user_playlists_provider.dart';
import 'package:melodia/providers/watch_history_provider.dart';
import 'package:melodia/services/download.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/player_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/widgets/custom_snackbar.dart';

class SongsListItem extends ConsumerStatefulWidget {
  final List<Songs> songsList;
  final Songs song;
  final int index;
  final bool fromPlayingQueue;
  final Playlists? playlist;
  final bool fromPlayMe;
  final bool fromPlaylist;
  const SongsListItem({
    super.key,
    required this.songsList,
    required this.song,
    required this.index,
    this.fromPlayingQueue = false,
    this.playlist,
    this.fromPlayMe = false,
    this.fromPlaylist = false,
  });

  @override
  ConsumerState<SongsListItem> createState() => _SongsListItemState();
}

class _SongsListItemState extends ConsumerState<SongsListItem> {
  late TextEditingController _playlistNameController;
  Box<Songs> playMeBox = Hive.box('playMe');

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
    final favoritesNotifier = ref.watch(favoritesProvider.notifier);
    bool isFavorite = favoritesNotifier.isFavorite(widget.song);
    final userPlaylist = ref.watch(userPlaylistsProvider);
    final userPlaylistNotifier = ref.watch(userPlaylistsProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final history = ref.watch(historyProvider.notifier);
    ref.watch(filesProvider);
    final files = ref.watch(filesProvider.notifier);
    bool isDownloaded = files.isDownloaded(widget.song.title);
    final audioNotifier = ref.watch(audioPlayerProvider.notifier);
    final playingQueue = ref.watch(playingQueueProvider.notifier);

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
              for (final playlist in userPlaylist)
                CupertinoActionSheetAction(
                  onPressed: () {
                    bool isAdded = userPlaylistNotifier.addSongToPlaylist(
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

    void removeFromPlaylist(Playlists playlist, Songs song) {
      userPlaylistNotifier.removeSongFromPlaylist(playlist, song);
    }

    return ListTile(
      splashColor: Colors.white.withAlpha(50),
      enableFeedback: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CachedNetworkImage(
              imageUrl: widget.song.image,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              memCacheHeight: 50,
              memCacheWidth: 50,
              errorWidget: (context, url, error) {
                return Center(
                  child: Image.asset('assets/song_thumb.png'),
                );
              },
            ),
            if (isDownloaded)
              Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.green),
                child: const Icon(
                  Icons.download_done_outlined,
                  color: Colors.white,
                  size: 15,
                ),
              ),
          ],
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
                            if (widget.fromPlaylist) {
                              if (widget.playlist != null) {
                                try {
                                  removeFromPlaylist(
                                      widget.playlist!, widget.song);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    customSnackBar(
                                        '${widget.song.title} removed from playlist ${widget.playlist!.title}\nRefresh the page to update the list',
                                        ref),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    customSnackBar(
                                        'Unable to remove song from playlist',
                                        ref),
                                  );
                                  throw Exception(e);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  customSnackBar(
                                    'Error occured while removing the song from playlist',
                                    ref,
                                  ),
                                );
                              }
                            } else {
                              addToPlaylist();
                            }
                          },
                          child: Text(
                            widget.fromPlaylist
                                ? 'Remove from Playlist'
                                : 'Add to Playlist',
                            style: TextStyle(color: AppTheme.accentColor(ref)),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            if (isDownloaded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(
                                    '"${widget.song.title}" is Already Downloaded',
                                    ref),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  customSnackBar(
                                      '"${widget.song.title}" Downloading Started',
                                      ref));
                              downloadSong(
                                [widget.song],
                                settings?.downloadQuality.toString() ?? '96',
                                ref,
                              );
                            }
                          },
                          child: Text(
                            'Download',
                            style: TextStyle(color: AppTheme.accentColor(ref)),
                          ),
                        ),
                        if (!widget.fromPlayMe)
                          CupertinoActionSheetAction(
                            onPressed: () {
                              playMeBox.add(widget.song);

                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(
                                  '${widget.song.title} added to PlayMe\nVisit Library to find out more',
                                  ref,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Add to PlayMe',
                              style:
                                  TextStyle(color: AppTheme.accentColor(ref)),
                            ),
                          ),
                        if (widget.fromPlayMe)
                          CupertinoActionSheetAction(
                            onPressed: () {
                              setState(() {
                                playMeBox.deleteAt(widget.index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(
                                  '${widget.song.title} removed from PlayMe\nGo back to update the list',
                                  ref,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Remove from PlayMe',
                              style:
                                  TextStyle(color: AppTheme.accentColor(ref)),
                            ),
                          ),
                        if (widget.fromPlayingQueue)
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              playingQueue.remove(widget.song);
                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(
                                  '${widget.song.title} removed from playing queue',
                                  ref,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Remove from Playing Queue',
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
        history.addHistory(widget.song);
        if (widget.fromPlayingQueue) {
          setState(() {
            Navigator.pop(context);
            audioNotifier.seek(Duration.zero, index: widget.index);
            audioNotifier.play();
          });
        } else {
          ref.read(playingQueueProvider.notifier).clear();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(
                playlist: widget.songsList,
                initialIndex: widget.index,
                fromPlayMe: widget.fromPlayMe,
              ),
            ),
          );
        }
      },
    );
  }
}
