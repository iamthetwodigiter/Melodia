import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodia/album/model/api_calls.dart';
import 'package:melodia/album/model/playlist_model.dart';
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

    // Had to use this troublesome method, because the playlist method of just_audio was not working properly in my case
    List<String> idList = [];
    List<String> linkList = [];
    List<String> imageUrlList = [];
    List<String> nameList = [];
    List<List<String>> artistsList = [];
    List<String> durationList = [];

    bool isPlaylist = false;

    return CupertinoPageScaffold(
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
            } else if (snapshot.connectionState == ConnectionState.waiting) {
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
                          width: 175,
                          placeholder: (context, url) {
                            return const Center(child: CupertinoActivityIndicator(),);
                          },
                          errorWidget:(context, url, error) {
                            return const SizedBox(
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                   Icon(Icons.error, color: CupertinoColors.white,),
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
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
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
                                        style: const TextStyle(fontSize: 12),
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
                  const Text(
                    'Artists',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 125,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.artists.length,
                      itemBuilder: ((context, index) {
                        return Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: 100,
                              width: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: CachedNetworkImageProvider(
                                    data.artists.elementAt(index).imageUrl != ""
                                        ? data.artists.elementAt(index).imageUrl
                                        : "https://img.freepik.com/premium-vector/man-avatar-profile-picture-vector-illustration_268834-538.jpg",
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
                              data.artists.elementAt(index).role.toUpperCase(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Songs',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isPlaylist = !isPlaylist;
                          });
                          var value = data.songs.first;
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => MusicPlayer(
                                link: value.downloadUrl.last,
                                id: value.id,
                                name: value.name.split('(')[0],
                                imageUrl: value.image,
                                duration: value.duration,
                                artists: value.artists,
                                playlistData: playlistData,
                                index: 0,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          CupertinoIcons.play_circle_fill,
                          color: CupertinoColors.white,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: SizedBox(
                      height: size.height * 0.5,
                      child: ListView.builder(
                          itemCount: data.songsCount,
                          itemBuilder: (context, index) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              margin: const EdgeInsets.only(bottom: 5),
                              height: 75,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 27, 27, 27),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${index + 1}.   ${data.songs.elementAt(index).name.split('(')[0]}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          data.songs
                                              .elementAt(index)
                                              .artists
                                              .join(',  '),
                                          style: const TextStyle(fontSize: 10),
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      var value = data.songs.elementAt(index);
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => MusicPlayer(
                                            link: value.downloadUrl.last,
                                            id: value.id,
                                            name: value.name.split('(')[0],
                                            imageUrl: value.image,
                                            duration: value.duration,
                                            artists: value.artists,
                                            playlistData: playlistData,
                                            index: index,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.play_circle,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
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
    );
  }
}
