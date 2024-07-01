import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:melodia/album/model/api_calls.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/player/view/player_screen.dart';

class AlbumDetails extends StatefulWidget {
  final String albumID;
  final String type;
  const AlbumDetails({super.key, required this.albumID, required this.type});

  @override
  State<AlbumDetails> createState() => _AlbumDetailsState();
}

class _AlbumDetailsState extends State<AlbumDetails> {
  late String id;
  late String name;
  late Playlist playlistData;
  @override
  Widget build(BuildContext context) {
    int year = 0;
    final size = MediaQuery.of(context).size;
    bool _shuffleMode = false;

    // Had to use this troublesome method, because the playlist method of just_audio was not working properly in my case
    List<String> idList = [];
    List<String> linkList = [];
    List<String> imageUrlList = [];
    List<String> nameList = [];
    List<List<String>> artistsList = [];
    List<String> durationList = [];

    bool isPlaylist = false;
    return CupertinoPageScaffold(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.type.toUpperCase(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    data.year.toString() != '0'
                                        ? Text(
                                            data.year.toString(),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          )
                                        : const Text('--__--'),
                                    Text(
                                      '${data.songsCount.toString()} Song(s)',
                                      style: const TextStyle(fontSize: 12),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        _shuffleMode = true;
                                      });
                                      var value = data.songs.first;
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext builder) {
                                            return CupertinoPopupSurface(
                                              child: MusicPlayer(
                                                link: value.downloadUrl.last,
                                                id: value.id,
                                                name: value.name.split('(')[0],
                                                imageUrl: value.image,
                                                duration: value.duration,
                                                artists: value.artists,
                                                playlistData: playlistData,
                                                index: 0,
                                                shuffleMode: _shuffleMode,
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
                                          builder: (BuildContext builder) {
                                            return CupertinoPopupSurface(
                                              child: MusicPlayer(
                                                link: value.downloadUrl.last,
                                                id: value.id,
                                                name: value.name.split('(')[0],
                                                imageUrl: value.image,
                                                duration: value.duration,
                                                artists: value.artists,
                                                playlistData: playlistData,
                                                index: 0,
                                                shuffleMode: _shuffleMode,
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
                                    var value = data.songs.elementAt(index);
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext builder) {
                                          return CupertinoPopupSurface(
                                            child: MusicPlayer(
                                              link: value.downloadUrl.last,
                                              id: value.id,
                                              name: value.name.split('(')[0],
                                              imageUrl: value.image,
                                              duration: value.duration,
                                              artists: value.artists,
                                              playlistData: playlistData,
                                              index: index,
                                              shuffleMode: _shuffleMode,
                                            ),
                                          );
                                        });
                                  },
                                  child: CupertinoListTile(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 15, left: 10),
                                    leading: CachedNetworkImage(
                                      imageUrl:
                                          data.songs.elementAt(index).image,
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
                                                color:
                                                    AppPallete.secondaryColor,
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
                      // Flexible(
                      //   child: SizedBox(
                      //     height: size.height * 0.6,
                      //     child: ListView.builder(
                      //         itemCount: data.songsCount,
                      //         itemBuilder: (context, index) {
                      //           return Container(
                      //             padding: const EdgeInsets.symmetric(
                      //                 horizontal: 25),
                      //             margin: const EdgeInsets.only(bottom: 5),
                      //             height: 75,
                      //             decoration: BoxDecoration(
                      //               color:
                      //                   const Color.fromARGB(255, 27, 27, 27),
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Flexible(
                      //                   child: Column(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.center,
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       Text(
                      //                         '${index + 1}.   ${data.songs.elementAt(index).name.split('(')[0]}',
                      //                         style: const TextStyle(
                      //                             color: CupertinoColors.white,
                      //                             fontWeight: FontWeight.bold),
                      //                       ),
                      //                       const SizedBox(height: 2),
                      //                       Text(
                      //                         data.songs
                      //                             .elementAt(index)
                      //                             .artists
                      //                             .join(',  '),
                      //                         style: const TextStyle(
                      //                             fontSize: 10,
                      //                             color: CupertinoColors.white),
                      //                         softWrap: true,
                      //                         maxLines: 2,
                      //                         overflow: TextOverflow.fade,
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 IconButton(
                      //                   onPressed: () {
                      //                     var value =
                      //                         data.songs.elementAt(index);
                      //                     showCupertinoModalPopup(
                      //                         context: context,
                      //                         builder: (BuildContext builder) {
                      //                           return CupertinoPopupSurface(
                      //                             child: MusicPlayer(
                      //                               link:
                      //                                   value.downloadUrl.last,
                      //                               id: value.id,
                      //                               name: value.name
                      //                                   .split('(')[0],
                      //                               imageUrl: value.image,
                      //                               duration: value.duration,
                      //                               artists: value.artists,
                      //                               playlistData: playlistData,
                      //                               index: index,
                      //                               shuffleMode: false,
                      //                             ),
                      //                           );
                      //                         });
                      //                   },
                      //                   icon: Icon(
                      //                     CupertinoIcons.play_circle,
                      //                     color: AppPallete().accentColor,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           );
                      //         }),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ),
        )
      ],
    ));
  }
}
