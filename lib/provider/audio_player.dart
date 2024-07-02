import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/player/model/songs_model.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  SongModel song;
  late String streamingQuality;

  AudioService({required this.song}) {
    _initializePlayer();
  }

  void _initializePlayer() async {
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

  SongModel previousPlayback() {
    player.seekToPrevious();
    int index = (song.index - 1) % songsCount();
    if (index < 0) index = songsCount() - 1;

    final songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    _initializePlayer();
    notifyListeners();
    return songmodel;
  }

  SongModel nextPlayback() {
    player.seekToNext();
    int index = (song.index + 1) % songsCount();

    final songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    _initializePlayer();
    notifyListeners();
    return songmodel;
  }

  SongModel shufflePlayback() {
    var temp = Random();
    int index = temp.nextInt(songsCount());

    player.seek(Duration.zero, index: index);

    final songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    _initializePlayer();
    notifyListeners();
    return songmodel;
  }

  SongModel isCompleted() {
    return shuffle() ? shufflePlayback() : nextPlayback();
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
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
