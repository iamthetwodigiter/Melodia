import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:melodia/player/model/offline_song_model.dart';

class OfflineAudioPlayer extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  OfflineSongModel song;
  OfflineAudioPlayer({
    required this.song,
  }) {
    _initializePlayer();
  }

  void _initializePlayer() async {
    int index = song.index;
    final audioSource = AudioSource.uri(
      Uri.file(song.songList.elementAt(index).path),
      tag: MediaItem(
        id: song.tags.elementAt(index)!.title!,
        title: song.tags.elementAt(index)!.title!,
        album: song.tags.elementAt(index)!.artist,
        // artUri: Uri.file(
        //   song.path
        //       .replaceAll('/Music/Melodia/',
        //           '/Android/data/com.thetwodigiter.melodia/files/')
        //       .replaceAll('m4a', 'png')
        //       .replaceAll(' ', '_'),
        // ),
      ),
    );
    player.setAudioSource(audioSource);
    player.play();
    notifyListeners();
  }

  int songsCount() {
    return song.songList.length;
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

  OfflineSongModel previousPlayback() {
    int index = shuffle()
        ? Random().nextInt(songsCount())
        : (song.index - 1) % songsCount();
    if (index < 0) index = songsCount() - 1;

    final songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    _initializePlayer();
    notifyListeners();
    return songmodel;
  }

  OfflineSongModel nextPlayback() {
    int index = shuffle()
        ? Random().nextInt(songsCount())
        : (song.index + 1) % songsCount();

    if (index >= songsCount()) index = 0;

    final songmodel = _getSongModelAtIndex(index);
    song = songmodel;
    _initializePlayer();
    notifyListeners();
    return songmodel;
  }

  OfflineSongModel _getSongModelAtIndex(int index) {
    return OfflineSongModel(
      songList: song.songList,
      index: index,
      thumbList: song.thumbList,
      tags: song.tags,
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
