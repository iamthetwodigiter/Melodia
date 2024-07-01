import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/album/model/api_calls.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/player/view/mini_player.dart';
import 'package:melodia/player/view/player_screen.dart';

Box settings = Hive.box('settings');

class AlbumDetails extends ConsumerStatefulWidget {
  final String albumID;
  final String type;
  const AlbumDetails({super.key, required this.albumID, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlbumDetailsState();
}

class _AlbumDetailsState extends ConsumerState<AlbumDetails> {
  late String id;
  late String name;
  late Playlist playlistData;
  @override
  Widget build(BuildContext context) {
    int year = 0;
    final size = MediaQuery.of(context).size;
    bool shuffleMode = false;
    // SongModel? song = ref.watch(currentSongProvider.notifier).state;
    final song = settings.get('currentSong');
    print(song);

    // Had to use this troublesome method, because the playlist method of just_audio was not working properly in my case
    List<String> idList = [];
    List<String> linkList = [];
    List<String> imageUrlList = [];
    List<String> nameList = [];
    List<List<String>> artistsList = [];
    List<String> durationList = [];

    bool isPlaylist = false;
    return CupertinoPageScaffold(
        child: Column(
      children: [
        SizedBox(
          height: song != null ? size.height * 0.925 : size.height * 1,
          child: CustomScrollView(
            scrollBehavior: const CupertinoScrollBehavior(),
            slivers: [
              SliverToBoxAdapter(
                child: CupertinoNavigationBar(
                  previousPageTitle: 'Home',
                  middle: Text(
                    'Playlist',
                    style: TextStyle(color: AppPallete().accentColor),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Container(
                  margin: EdgeInsets.only(top: Platform.isAndroid ? 20 : 0),
                  width: double.infinity,
                  height: double.infinity,
                  child: FutureBuilder(
                    future: fetchAlbumData(widget.type, widget.albumID),
                    builder: (context, snapshot) {
                      if (snapshot.data?.year == null) {
                        year = year;
                      } else {
                        year = snapshot.data?.year ?? 0;
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                      final data = snapshot.data!;

                      for (var songs in data.songs) {
                        idList.add(songs.id);
                        linkList.add(songs.downloadUrl.last);
                        imageUrlList.add(songs.image);
                        nameList.add(songs.name.replaceAll('&quot;', ''));
                        artistsList.add(songs.artists);
                        durationList.add(songs.duration);
                      }
                      playlistData = Playlist(
                        idList: idList,
                        linkList: linkList,
                        imageUrlList: imageUrlList,
                        nameList: nameList,
                        artistsList: artistsList,
                        durationList: durationList,
                      );
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: data.image,
                                    height: 150,
                                    placeholder: (context, url) {
                                      return const Center(
                                        child: CupertinoActivityIndicator(),
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      return const SizedBox(
                                        height: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error,
                                              color: CupertinoColors.white,
                                            ),
                                            Text('Thumb load error'),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.name,
                                        style: TextStyle(
                                          color: AppPallete().accentColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data.type.toUpperCase(),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          data.year.toString() != '0'
                                              ? Text(
                                                  data.year.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                )
                                              : const Text('--__--'),
                                          Text(
                                            '${data.songsCount.toString()} Song(s)',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 30),
                            // Text(data.description),
                            const SizedBox(height: 10),
                            Text(
                              'Artists',
                              style: TextStyle(
                                color: AppPallete().accentColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: data.artists.length,
                                itemBuilder: ((context, index) {
                                  return Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        height: 60,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: CachedNetworkImageProvider(
                                              data.artists
                                                          .elementAt(index)
                                                          .imageUrl !=
                                                      ""
                                                  ? data.artists
                                                      .elementAt(index)
                                                      .imageUrl
                                                      .replaceAll('50', '500')
                                                  : "https://img.freepik.com/premium-vector/man-avatar-profile-picture-vector-illustration_268834-538.jpg",
                                              errorListener: (p0) {
                                                if (p0.toString().contains(
                                                    'HttpException: Invalid statusCode: 404')) {}
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        data.artists.elementAt(index).name,
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.fade,
                                      ),
                                      Text(
                                        data.artists
                                            .elementAt(index)
                                            .role
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Songs',
                                    style: TextStyle(
                                      color: AppPallete().accentColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              shuffleMode = true;
                                            });
                                            var value = data.songs.first;
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext builder) {
                                                  final song = SongModel(
                                                    link:
                                                        value.downloadUrl.last,
                                                    id: value.id,
                                                    name: value.name
                                                        .split('(')[0],
                                                    imageUrl: value.image,
                                                    duration: value.duration,
                                                    artists: value.artists,
                                                    playlistData: playlistData,
                                                    index: 0,
                                                    shuffleMode: shuffleMode,
                                                  );
                                                  return CupertinoPopupSurface(
                                                    child: MusicPlayer(
                                                      song: song,
                                                    ),
                                                  );
                                                });
                                          },
                                          icon: Icon(
                                            CupertinoIcons.shuffle_medium,
                                            color: AppPallete().accentColor,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            setState(() {
                                              isPlaylist = !isPlaylist;
                                            });
                                            var value = data.songs.first;
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext builder) {
                                                  final song = SongModel(
                                                    link:
                                                        value.downloadUrl.last,
                                                    id: value.id,
                                                    name: value.name
                                                        .split('(')[0],
                                                    imageUrl: value.image,
                                                    duration: value.duration,
                                                    artists: value.artists,
                                                    playlistData: playlistData,
                                                    index: 0,
                                                    shuffleMode: shuffleMode,
                                                  );
                                                  return CupertinoPopupSurface(
                                                    child: MusicPlayer(
                                                      song: song,
                                                    ),
                                                  );
                                                });
                                          },
                                          icon: Icon(
                                            CupertinoIcons.play_circle_fill,
                                            color: AppPallete().accentColor,
                                            size: 45,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: size.height * 0.6,
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: data.songsCount,
                                    itemBuilder: (context, index) {
                                      return CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          var value =
                                              data.songs.elementAt(index);
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext builder) {
                                                final song = SongModel(
                                                  link: value.downloadUrl.last,
                                                  id: value.id,
                                                  name:
                                                      value.name.split('(')[0],
                                                  imageUrl: value.image,
                                                  duration: value.duration,
                                                  artists: value.artists,
                                                  playlistData: playlistData,
                                                  index: 0,
                                                  shuffleMode: shuffleMode,
                                                );
                                                return CupertinoPopupSurface(
                                                  child: MusicPlayer(
                                                    song: song,
                                                  ),
                                                );
                                              });
                                        },
                                        child: CupertinoListTile(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10, left: 10),
                                          leading: CachedNetworkImage(
                                            imageUrl: data.songs
                                                .elementAt(index)
                                                .image,
                                            height: 50,
                                            placeholder: (context, url) {
                                              return const SizedBox(width: 60);
                                            },
                                            errorWidget: (context, url, error) {
                                              return const SizedBox(
                                                height: 50,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.nosign,
                                                      color: AppPallete
                                                          .secondaryColor,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          trailing: IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {},
                                            icon: const Icon(
                                              size: 20,
                                              CupertinoIcons.ellipsis_vertical,
                                              color: AppPallete.secondaryColor,
                                            ),
                                          ),
                                          title: Text(data.songs
                                              .elementAt(index)
                                              .name
                                              .split('(')[0]),
                                          subtitle: Text(
                                            data.songs
                                                .elementAt(index)
                                                .artists
                                                .join(", "),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        song != null
            ? Container(
                padding: EdgeInsets.zero,
                height: size.height * 0.075,
                child: MiniPlayer(
                  song: song,
                  
                ),
              )
            : Container(),
      ],
    ));
  }
}
