import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/album/model/playlist_model.dart';
import 'package:melodia/player/model/songs_model.dart';
import 'package:melodia/search/model/suggestions.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  SongModel song;
  late String streamingQuality;

  AudioService({required this.song}) {
    _initializePlayer();
  }

  Future<Playlist> fetchAndCreatePlaylist(String songId) async {
    final suggestionResults = await getSuggestions(songId);

    List<String> idList = [];
    List<String> linkList = [];
    List<String> imageUrlList = [];
    List<String> nameList = [];
    List<List<String>> artistList = [];
    List<String> durationList = [];

    for (var item in suggestionResults) {
      idList.add(item.id);
      linkList.add(item.downloadUrls.last);
      imageUrlList.add(item.imageUrl);
      nameList.add(item.title);
      artistList.add(item.artist);
      durationList.add(item.duration);
    }

    return Playlist(
      idList: idList,
      linkList: linkList,
      imageUrlList: imageUrlList,
      nameList: nameList,
      artistsList: artistList,
      durationList: durationList,
    );
  }

  Future<void> getSuggestedSongs(SongModel songx) async {
    try {
      final updatedPlaylist = await fetchAndCreatePlaylist(songx.id);
      song = SongModel(
        link: updatedPlaylist.linkList.first,
        id: updatedPlaylist.idList.first,
        name: updatedPlaylist.nameList.first.split('(')[0],
        imageUrl: updatedPlaylist.imageUrlList.first,
        duration: updatedPlaylist.durationList.first,
        artists: updatedPlaylist.artistsList.first,
        index: 0,
        playlistData: updatedPlaylist,
        shuffleMode: false,
        playlistName: 'Random',
        year: '2024',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializePlayer() async {
    Box settings = await Hive.openBox('settings');
    streamingQuality = settings.get('streaming_quality');
    final audioSource = AudioSource.uri(
      Uri.parse(song.link.replaceAll('320', streamingQuality)),
      tag: MediaItem(
        id: song.id,
        title: song.name,
        album: song.artists.join(", "),
        artUri: Uri.parse(song.imageUrl),
      ),
    );

    await player.setAudioSource(audioSource);
    player.play();
    notifyListeners();
  }

  int songsCount() {
    return song.playlistData!.linkList.length;
  }

  bool shuffle() {
    Box settings = Hive.box('settings');
    return settings.get('shuffle') == 1;
  }

  void play() {
    player.play();
    notifyListeners();
  }

  void pause() {
    player.pause();
    notifyListeners();
  }

  void stop() {
    player.stop();
    notifyListeners();
  }

  void seek(Duration position) {
    player.seek(position);
    notifyListeners();
  }

  Future<SongModel> previousPlayback() async {
    int index = shuffle()
        ? Random().nextInt(songsCount())
        : (song.index - 1) % songsCount();
    if (index < 0) index = songsCount() - 1;

    final songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    await _initializePlayer();
    notifyListeners();
    return songmodel;
  }

  Future<SongModel> nextPlayback() async {
    int index = shuffle()
        ? Random().nextInt(songsCount())
        : (song.index + 1) % songsCount();
    
    SongModel songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    bool suggestions = Hive.box('settings').get('suggestions');
    if (index == songsCount() - 1) {
      if (!suggestions) {
        index = 0;
      } else {
        await getSuggestedSongs(songmodel);
      }
    } else if (index >= songsCount()) {
      index = 0;
      return songmodel;
    }

    await _initializePlayer();
    notifyListeners();
    return song;
  }

  SongModel _getSongModelAtIndex(int index) {
    return SongModel(
      link: song.playlistData!.linkList.elementAt(index),
      id: song.playlistData!.idList.elementAt(index),
      name: song.playlistData!.nameList.elementAt(index).split('(')[0],
      imageUrl: song.playlistData!.imageUrlList.elementAt(index),
      duration: song.playlistData!.durationList.elementAt(index),
      artists: song.playlistData!.artistsList.elementAt(index),
      playlistData: song.playlistData,
      index: index,
      shuffleMode: shuffle(),
      playlistName: song.playlistName,
      year: song.year,
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
