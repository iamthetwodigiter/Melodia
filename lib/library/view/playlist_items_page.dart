import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/player/view/mini_player.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:melodia/provider/dark_mode_provider.dart';
import 'package:melodia/provider/songs_notifier.dart';

class PlaylistItemsPage extends ConsumerStatefulWidget {
  final String name;
  final Playlist playlistData;
  const PlaylistItemsPage({
    super.key,
    required this.name,
    required this.playlistData,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlaylistItemsPageState();
}

class _PlaylistItemsPageState extends ConsumerState<PlaylistItemsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ref.watch(darkModeProvider);
    bool darkMode = Hive.box('settings').get('darkMode');
    final song = ref.watch(currentSongProvider);
    ref.watch(currentSongProvider);
    Box<Playlist> playlistBox = Hive.box<Playlist>('playlist');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Library',
        middle: Text(
          'Playlist',
          style: TextStyle(
            color: AppPallete().accentColor,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      song != null ? size.height * 0.9 - 65 : (size.height * 0.9),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Image.asset(
                                'assets/playlist_art.png',
                                height: 150,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        color: widget.name == 'Favorites'
                                            ? CupertinoColors.destructiveRed
                                            : darkMode
                                                ? AppPallete.subtitleDarkTextColor
                                                : AppPallete().subtitleTextColor,
                                      ),
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${widget.playlistData.idList.length.toString()} Songs',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: widget.name == 'Favorites'
                                            ? CupertinoColors.destructiveRed
                                            : darkMode
                                                ? AppPallete.subtitleDarkTextColor
                                                : AppPallete().subtitleTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        settings.put('shuffle', 0);
                                        final song = SongModel(
                                          link: widget.playlistData.linkList
                                              .elementAt(0),
                                          id: widget.playlistData.idList
                                              .elementAt(0),
                                          name: widget.playlistData.nameList
                                              .elementAt(0),
                                          imageUrl: widget.playlistData.imageUrlList
                                              .elementAt(0),
                                          duration: widget.playlistData.durationList
                                              .elementAt(0),
                                          artists: widget.playlistData.artistsList
                                              .elementAt(0),
                                          playlistData: widget.playlistData,
                                          index: 0,
                                          shuffleMode: false,
                                          playlistName: widget.name,
                                          isUserCreated: true
                                        );
                                        ref
                                            .read(currentSongProvider.notifier)
                                            .state = song;
                                        ref.watch(audioServiceProvider)!.play();
          
                                        Navigator.of(context).push(
                                          CustomPageRoute(
                                            page: MusicPlayer(song: song),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        CupertinoIcons.play_circle_fill,
                                        color: widget.name == 'Favorites'
                                            ? CupertinoColors.destructiveRed
                                            : AppPallete().accentColor,
                                        size: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Divider(
                      color: AppPallete().accentColor,
                    )),
                    widget.playlistData.idList.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppPallete().accentColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: CupertinoColors.separator,
                                        width: 0.5,
                                      ),
                                    ),
                                    height: 75,
                                    child: TextButton(
                                      onPressed: () async {
                                        final song = SongModel(
                                          link: widget.playlistData.linkList
                                              .elementAt(index),
                                          id: widget.playlistData.idList
                                              .elementAt(index),
                                          name: widget.playlistData.nameList
                                              .elementAt(index),
                                          duration: widget.playlistData.durationList
                                              .elementAt(index),
                                          imageUrl: widget.playlistData.imageUrlList
                                              .elementAt(index),
                                          artists: widget.playlistData.artistsList
                                              .elementAt(index),
                                          index: index,
                                          playlistData: widget.playlistData,
                                          shuffleMode: false,
                                          playlistName: widget.name,
                                          isUserCreated: true
                                        );
                                        ref
                                            .read(currentSongProvider.notifier)
                                            .state = song;
                                        Navigator.push(
                                          context,
                                          CustomPageRoute(
                                            page: MusicPlayer(
                                              song: song,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.6,
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: widget
                                                        .playlistData.imageUrlList
                                                        .elementAt(index),
                                                    width: 60,
                                                    errorWidget:
                                                        (context, url, error) {
                                                      return const Icon(
                                                          Icons.error);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        widget.playlistData.nameList
                                                            .elementAt(index),
                                                        style: TextStyle(
                                                          color: darkMode
                                                              ? AppPallete
                                                                  .subtitleDarkTextColor
                                                              : AppPallete()
                                                                  .subtitleTextColor,
                                                          fontSize: 15,
                                                        ),
                                                        softWrap: true,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        widget.playlistData
                                                            .artistsList
                                                            .elementAt(index)
                                                            .join(", "),
                                                        style: TextStyle(
                                                          color: darkMode
                                                              ? AppPallete
                                                                  .subtitleDarkTextColor
                                                              : AppPallete()
                                                                  .subtitleTextColor,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              setState(() {
                                                widget.playlistData.idList
                                                    .removeAt(index);
                                                widget.playlistData.linkList
                                                    .removeAt(index);
                                                widget.playlistData.imageUrlList
                                                    .removeAt(index);
                                                widget.playlistData.nameList
                                                    .removeAt(index);
                                                widget.playlistData.artistsList
                                                    .removeAt(index);
                                                widget.playlistData.durationList
                                                    .removeAt(index);
                                              });
          
                                              playlistBox.put(
                                                  widget.name, widget.playlistData);
                                            },
                                            icon: const Icon(
                                              CupertinoIcons.delete_solid,
                                              color: CupertinoColors.destructiveRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: widget.playlistData.idList.length,
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: Container(
                              alignment: Alignment.center,
                              height: size.height * 0.78,
                              width: double.infinity,
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 250),
                                child: Text(
                                  'No songs\nTry adding some',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              song != null
                  ? Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.zero,
                      height: 60,
                      child: const MiniPlayer(),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
