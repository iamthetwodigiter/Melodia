import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodia/album/model/api_calls.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/core/cupertino_popup_message.dart';
import 'package:melodia/download/model/downloader.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/player/view/mini_player.dart';
import 'package:melodia/player/view/player_screen.dart';
import 'package:melodia/player/widgets/custom_page_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:melodia/library/view/playlist_screen.dart';
import 'package:melodia/provider/songs_notifier.dart';

class AlbumDetails extends ConsumerStatefulWidget {
  final String albumID;
  final String type;

  const AlbumDetails({
    super.key,
    required this.albumID,
    required this.type,
  });

  @override
  ConsumerState<AlbumDetails> createState() => _AlbumDetailsState();
}

class _AlbumDetailsState extends ConsumerState<AlbumDetails> {
  late Playlist playlistData;
  Box<Playlist> playlistBox = Hive.box<Playlist>('playlist');
  // List<Playlist> playlist = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final song = ref.watch(currentSongProvider);
    bool darkMode = Hive.box('settings').get('darkMode') ?? false;

    List<String> idList = [];
    List<String> linkList = [];
    List<String> imageUrlList = [];
    List<String> nameList = [];
    List<List<String>> artistsList = [];
    List<String> durationList = [];

    double downloadProgress = 0.0;

    void updateProgress(double progress) {
      setState(() {
        downloadProgress = progress;
      });
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Home',
        middle: Text(
          'Playlist',
          style: TextStyle(
            color: darkMode ? Colors.white : AppPallete().accentColor,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height:
                    song != null ? size.height * 0.9 - 65 : size.height * 0.9,
                child: CustomScrollView(
                  scrollBehavior: const CupertinoScrollBehavior(),
                  slivers: [
                    SliverFillRemaining(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: FutureBuilder(
                          future: fetchAlbumData(widget.type, widget.albumID),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Error occured'),
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
                              nameList.add(songs.name.split('(')[0]);
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
                              padding:
                                  const EdgeInsets.all(20).copyWith(bottom: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: data.image,
                                          width: 150,
                                          height: 150,
                                          placeholder: (context, url) {
                                            return const Center(
                                              child:
                                                  CupertinoActivityIndicator(),
                                            );
                                          },
                                          errorWidget: (context, url, error) {
                                            return SizedBox(
                                              width: 150,
                                              height: 150,
                                              child: Image.asset(
                                                  'assets/playlist_art.png'),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 50),
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
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: darkMode
                                                        ? AppPallete
                                                            .subtitleDarkTextColor
                                                        : AppPallete()
                                                            .subtitleTextColor,
                                                  ),
                                                ),
                                                data.year.toString() != '0'
                                                    ? Text(
                                                        data.year.toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: darkMode
                                                                ? AppPallete
                                                                    .subtitleDarkTextColor
                                                                : AppPallete()
                                                                    .subtitleTextColor),
                                                      )
                                                    : Text(
                                                        '--__--',
                                                        style: TextStyle(
                                                          color: darkMode
                                                              ? AppPallete
                                                                  .subtitleDarkTextColor
                                                              : AppPallete()
                                                                  .subtitleTextColor,
                                                        ),
                                                      ),
                                                Text(
                                                  '${data.songsCount.toString()} Song(s)',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: darkMode
                                                        ? AppPallete
                                                            .subtitleDarkTextColor
                                                        : AppPallete()
                                                            .subtitleTextColor,
                                                  ),
                                                ),
                                                TextButton(
                                                  style: const ButtonStyle(
                                                    padding:
                                                        MaterialStatePropertyAll(
                                                      EdgeInsets.zero,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    playlistBox.put(
                                                      data.name,
                                                      Playlist(
                                                        idList: idList,
                                                        linkList: linkList,
                                                        imageUrlList:
                                                            imageUrlList,
                                                        nameList: nameList,
                                                        artistsList:
                                                            artistsList,
                                                        durationList:
                                                            durationList,
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Add to Playlist',
                                                    style: TextStyle(
                                                        color: AppPallete()
                                                            .accentColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              height: 60,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    data.artists
                                                            .elementAt(index)
                                                            .imageUrl
                                                            .isNotEmpty
                                                        ? data.artists
                                                            .elementAt(index)
                                                            .imageUrl
                                                            .replaceAll(
                                                                '50', '500')
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
                                              data.artists
                                                  .elementAt(index)
                                                  .name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: darkMode
                                                    ? AppPallete
                                                        .subtitleDarkTextColor
                                                    : AppPallete()
                                                        .subtitleTextColor,
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
                                              // IconButton(
                                              //   style: ButtonStyle(
                                              //     padding:
                                              //         const MaterialStatePropertyAll(
                                              //       EdgeInsets.all(0),
                                              //     ),
                                              //     backgroundColor:
                                              //         MaterialStatePropertyAll(
                                              //       AppPallete().accentColor,
                                              //     ),
                                              //   ),
                                              //   onPressed: () {
                                              //     int count = playlistData
                                              //         .idList.length;
                                              //     for (int i = 0;
                                              //         i < count;
                                              //         i++) {
                                              //           print(playlistData.nameList.elementAt(i));
                                              //       List metadata = [
                                              //         playlistData.nameList
                                              //             .elementAt(i),
                                              //         playlistData.artistsList
                                              //             .elementAt(i),
                                              //         data.name,
                                              //         playlistData.durationList
                                              //             .elementAt(i),
                                              //         playlistData.imageUrlList
                                              //             .elementAt(i),
                                              //         i,
                                              //         data.songs
                                              //             .elementAt(i)
                                              //             .year
                                              //       ];
                                              //       download(
                                              //         playlistData.linkList
                                              //             .elementAt(i),
                                              //         '${playlistData.nameList.elementAt(i).trimRight()}.m4a',
                                              //         metadata,
                                              //         context,
                                              //         updateProgress,
                                              //       );
                                              //     }
                                              //   },
                                              //   icon: Icon(
                                              //     Icons.download_rounded,
                                              //     color: darkMode
                                              //         ? Colors.black
                                              //         : Colors.white,
                                              //   ),
                                              // ),
                                              IconButton(
                                                onPressed: () {
                                                  ref
                                                      .watch(offlineSongProvider
                                                          .notifier)
                                                      .state = null;
                                                  settings.put('shuffle', 1);
                                                  final song = SongModel(
                                                      link: data.songs.first
                                                          .downloadUrl.last,
                                                      id: data.songs.first.id,
                                                      name: data
                                                          .songs.first.name
                                                          .split('(')[0],
                                                      imageUrl: data
                                                          .songs.first.image,
                                                      duration: data
                                                          .songs.first.duration,
                                                      artists: data
                                                          .songs.first.artists,
                                                      playlistData:
                                                          playlistData,
                                                      index: 0,
                                                      shuffleMode: true,
                                                      playlistName: data.name,
                                                      year:
                                                          data.songs.first.year,
                                                      isUserCreated:
                                                          Hive.box<Playlist>(
                                                                  'playlist')
                                                              .containsKey(
                                                                  data.name));
                                                  ref
                                                      .read(currentSongProvider
                                                          .notifier)
                                                      .state = song;
                                                  ref
                                                      .watch(
                                                          audioServiceProvider)!
                                                      .play();

                                                  Navigator.of(context).push(
                                                    CustomPageRoute(
                                                      page: MusicPlayer(
                                                          song: song),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  CupertinoIcons.shuffle_medium,
                                                  color:
                                                      AppPallete().accentColor,
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  ref
                                                      .watch(offlineSongProvider
                                                          .notifier)
                                                      .state = null;
                                                  final song = SongModel(
                                                      link: data.songs.first
                                                          .downloadUrl.last,
                                                      id: data.songs.first.id,
                                                      name: data
                                                          .songs.first.name
                                                          .split('(')[0],
                                                      imageUrl: data
                                                          .songs.first.image,
                                                      duration: data
                                                          .songs.first.duration,
                                                      artists: data
                                                          .songs.first.artists,
                                                      playlistData:
                                                          playlistData,
                                                      index: 0,
                                                      shuffleMode: false,
                                                      playlistName: data.name,
                                                      year:
                                                          data.songs.first.year,
                                                      isUserCreated:
                                                          Hive.box<Playlist>(
                                                                  'playlist')
                                                              .containsKey(
                                                                  data.name));

                                                  ref
                                                      .read(currentSongProvider
                                                          .notifier)
                                                      .state = song;

                                                  ref
                                                      .watch(
                                                          audioServiceProvider)!
                                                      .play();

                                                  Navigator.of(context).push(
                                                    CustomPageRoute(
                                                      page: MusicPlayer(
                                                          song: song),
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  CupertinoIcons
                                                      .play_circle_fill,
                                                  color:
                                                      AppPallete().accentColor,
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
                                          final favorites =
                                              playlistBox.get('Favorites');
                                          bool songExists = favorites!.idList
                                              .contains(data.songs
                                                  .elementAt(index)
                                                  .id);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CupertinoListTile(
                                                onTap: () {
                                                  ref
                                                      .watch(offlineSongProvider
                                                          .notifier)
                                                      .state = null;
                                                  final song = SongModel(
                                                      link: data.songs
                                                          .elementAt(index)
                                                          .downloadUrl
                                                          .last,
                                                      id: data.songs
                                                          .elementAt(index)
                                                          .id,
                                                      name: data.songs
                                                          .elementAt(index)
                                                          .name
                                                          .split('(')[0],
                                                      imageUrl: data.songs
                                                          .elementAt(index)
                                                          .image,
                                                      duration: data.songs
                                                          .elementAt(index)
                                                          .duration,
                                                      artists: data.songs
                                                          .elementAt(index)
                                                          .artists,
                                                      playlistData:
                                                          playlistData,
                                                      index: index,
                                                      shuffleMode: false,
                                                      playlistName: data.name,
                                                      year: data.songs
                                                          .elementAt(index)
                                                          .year,
                                                      isUserCreated:
                                                          Hive.box<Playlist>(
                                                                  'playlist')
                                                              .containsKey(
                                                                  data.name));

                                                  ref
                                                      .read(currentSongProvider
                                                          .notifier)
                                                      .state = song;

                                                  ref
                                                      .watch(
                                                          audioServiceProvider)!
                                                      .play();

                                                  Navigator.of(context).push(
                                                    CustomPageRoute(
                                                      page: MusicPlayer(
                                                          song: song),
                                                    ),
                                                  );
                                                },
                                                backgroundColor: AppPallete()
                                                    .accentColor
                                                    .withAlpha(20),
                                                padding: const EdgeInsets.only(
                                                    top: 5,
                                                    bottom: 5,
                                                    left: 10),
                                                leading: CachedNetworkImage(
                                                  imageUrl: data.songs
                                                      .elementAt(index)
                                                      .image,
                                                  height: 50,
                                                  placeholder: (context, url) {
                                                    return const SizedBox(
                                                        width: 60);
                                                  },
                                                  errorWidget:
                                                      (context, url, error) {
                                                    return SizedBox(
                                                      height: 50,
                                                      child: Image.asset(
                                                        'assets/song_thumb.png',
                                                        height: 50,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                trailing: Row(
                                                  children: [
                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () {
                                                        if (!songExists) {
                                                          final updatedPlaylist =
                                                              Playlist(
                                                            idList: List.from(
                                                                favorites
                                                                    .idList)
                                                              ..add(data.songs
                                                                  .elementAt(
                                                                      index)
                                                                  .id),
                                                            linkList: List.from(
                                                                favorites
                                                                    .linkList)
                                                              ..add(data.songs
                                                                  .elementAt(
                                                                      index)
                                                                  .downloadUrl
                                                                  .last),
                                                            imageUrlList: List
                                                                .from(favorites
                                                                    .imageUrlList)
                                                              ..add(data.songs
                                                                  .elementAt(
                                                                      index)
                                                                  .image),
                                                            nameList: List.from(
                                                                favorites
                                                                    .nameList)
                                                              ..add(data.songs
                                                                  .elementAt(
                                                                      index)
                                                                  .name
                                                                  .split(
                                                                      '(')[0]),
                                                            artistsList: List
                                                                .from(favorites
                                                                    .artistsList)
                                                              ..add(data.songs
                                                                  .elementAt(
                                                                      index)
                                                                  .artists),
                                                            durationList: List
                                                                .from(favorites
                                                                    .durationList)
                                                              ..add(data.songs
                                                                  .elementAt(
                                                                      index)
                                                                  .duration),
                                                          );
                                                          playlistBox.put(
                                                              'Favorites',
                                                              updatedPlaylist);
                                                          showCupertinoCenterPopup(
                                                              context,
                                                              '${data.songs.elementAt(index).name.split('(')[0]} Added to Favorites',
                                                              Icons
                                                                  .download_done_rounded);
                                                        } else {
                                                          final updatedPlaylist =
                                                              Playlist(
                                                            idList: List.from(
                                                                favorites
                                                                    .idList)
                                                              ..remove(data
                                                                  .songs
                                                                  .elementAt(
                                                                      index)
                                                                  .id),
                                                            linkList: List.from(
                                                                favorites
                                                                    .linkList)
                                                              ..remove(data
                                                                  .songs
                                                                  .elementAt(
                                                                      index)
                                                                  .downloadUrl
                                                                  .last),
                                                            imageUrlList: List
                                                                .from(favorites
                                                                    .imageUrlList)
                                                              ..remove(data
                                                                  .songs
                                                                  .elementAt(
                                                                      index)
                                                                  .image),
                                                            nameList: List.from(
                                                                favorites
                                                                    .nameList)
                                                              ..remove(data
                                                                  .songs
                                                                  .elementAt(
                                                                      index)
                                                                  .name
                                                                  .split(
                                                                      '(')[0]),
                                                            artistsList: List
                                                                .from(favorites
                                                                    .artistsList)
                                                              ..remove(data
                                                                  .songs
                                                                  .elementAt(
                                                                      index)
                                                                  .artists),
                                                            durationList: List
                                                                .from(favorites
                                                                    .durationList)
                                                              ..remove(data
                                                                  .songs
                                                                  .elementAt(
                                                                      index)
                                                                  .duration),
                                                          );
                                                          playlistBox.put(
                                                              'Favorites',
                                                              updatedPlaylist);
                                                          showCupertinoCenterPopup(
                                                              context,
                                                              '${data.songs.elementAt(index).name.split('(')[0]} Removed from Favorites',
                                                              Icons
                                                                  .download_done_rounded);
                                                        }
                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                        songExists
                                                            ? CupertinoIcons
                                                                .heart_fill
                                                            : CupertinoIcons
                                                                .heart,
                                                        color: CupertinoColors
                                                            .destructiveRed,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        showCupertinoModalPopup(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            if (playlistBox
                                                                    .length !=
                                                                0) {
                                                              return CupertinoActionSheet(
                                                                actions: [
                                                                  CupertinoActionSheetAction(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      showCupertinoModalPopup(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          if (playlistBox.length !=
                                                                              0) {
                                                                            final playlists =
                                                                                playlistBox.keys.toList();
                                                                            return CupertinoActionSheet(
                                                                              actions: playlists.map((name) {
                                                                                final currentPlaylist = playlistBox.get(name);
                                                                                if (currentPlaylist != null) {
                                                                                  return CupertinoActionSheetAction(
                                                                                    onPressed: () {
                                                                                      bool songExists = currentPlaylist.idList.contains(data.songs.elementAt(index).id);

                                                                                      if (!songExists) {
                                                                                        final updatedPlaylist = Playlist(
                                                                                          idList: List.from(currentPlaylist.idList)..add(data.songs.elementAt(index).id),
                                                                                          linkList: List.from(currentPlaylist.linkList)..add(data.songs.elementAt(index).downloadUrl.last),
                                                                                          imageUrlList: List.from(currentPlaylist.imageUrlList)..add(data.songs.elementAt(index).image),
                                                                                          nameList: List.from(currentPlaylist.nameList)..add(data.songs.elementAt(index).name.split('(')[0]),
                                                                                          artistsList: List.from(currentPlaylist.artistsList)..add(data.songs.elementAt(index).artists),
                                                                                          durationList: List.from(currentPlaylist.durationList)..add(data.songs.elementAt(index).duration),
                                                                                        );
                                                                                        playlistBox.put(name, updatedPlaylist);
                                                                                      }
                                                                                      showCupertinoCenterPopup(context, '${data.songs.elementAt(index).name.split('(')[0]} Added to Playlist', Icons.download_done_rounded);
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text(name),
                                                                                  );
                                                                                } else {
                                                                                  return CupertinoActionSheetAction(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: const Text('Error: Playlist not found'),
                                                                                  );
                                                                                }
                                                                              }).toList(),
                                                                              cancelButton: CupertinoActionSheetAction(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                isDestructiveAction: true,
                                                                                child: const Text('Cancel'),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            return CupertinoActionSheet(
                                                                              actions: [
                                                                                CupertinoActionSheetAction(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: const Text('Create Playlist'),
                                                                                ),
                                                                              ],
                                                                              cancelButton: CupertinoActionSheetAction(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                isDestructiveAction: true,
                                                                                child: const Text('Cancel'),
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                      );
                                                                    },
                                                                    child: const Text(
                                                                        'Add to Playlist'),
                                                                  ),
                                                                  CupertinoActionSheetAction(
                                                                    onPressed:
                                                                        () {
                                                                      List
                                                                          metadata =
                                                                          [
                                                                        data.songs
                                                                            .elementAt(index)
                                                                            .name
                                                                            .split("(")[0],
                                                                        data.songs
                                                                            .elementAt(index)
                                                                            .artists,
                                                                        data.name,
                                                                        data.songs
                                                                            .elementAt(index)
                                                                            .duration,
                                                                        data.songs
                                                                            .elementAt(index)
                                                                            .image,
                                                                        index,
                                                                        data.songs
                                                                            .elementAt(index)
                                                                            .year,
                                                                      ];
                                                                      download(
                                                                        data.songs
                                                                            .elementAt(index)
                                                                            .downloadUrl
                                                                            .last,
                                                                        '${data.songs.elementAt(index).name.trimRight().split('(')[0]}.m4a',
                                                                        metadata,
                                                                        context,
                                                                        updateProgress,
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Download',
                                                                    ),
                                                                  ),
                                                                ],
                                                                cancelButton:
                                                                    CupertinoActionSheetAction(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  isDestructiveAction:
                                                                      true,
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                              );
                                                            }
                                                            return CupertinoActionSheet(
                                                              actions: [
                                                                CupertinoActionSheetAction(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pushReplacement(
                                                                      CupertinoPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const LibraryScreen(),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: const Text(
                                                                      'Please Create Playlist First'),
                                                                ),
                                                              ],
                                                              cancelButton:
                                                                  CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                isDestructiveAction:
                                                                    true,
                                                                child: const Text(
                                                                    'Cancel'),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: Icon(
                                                        CupertinoIcons
                                                            .ellipsis_vertical,
                                                        size: 20,
                                                        color: AppPallete()
                                                            .accentColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                title: Text(
                                                  data.songs
                                                      .elementAt(index)
                                                      .name
                                                      .split('(')[0],
                                                  style: TextStyle(
                                                    color: darkMode
                                                        ? AppPallete
                                                            .subtitleDarkTextColor
                                                        : AppPallete()
                                                            .subtitleTextColor,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  data.songs
                                                      .elementAt(index)
                                                      .artists
                                                      .join(", "),
                                                  style: TextStyle(
                                                    color: darkMode
                                                        ? AppPallete
                                                            .subtitleDarkTextColor
                                                        : AppPallete()
                                                            .subtitleTextColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
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
              if (song != null)
                Container(
                  padding: EdgeInsets.zero,
                  height: 60,
                  child: const MiniPlayer(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
