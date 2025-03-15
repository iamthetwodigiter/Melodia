import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melodia/models/audio_player_state_model.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/providers/playing_queue_provider.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/providers/watch_history_provider.dart';
import 'package:melodia/services/audio_services.dart';
import 'package:rxdart/rxdart.dart';

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
  (ref) => AudioPlayerNotifier(ref),
);

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioService().audioPlayer;
  List<AudioSource> _currentPlaylist = [];
  List<Songs> _songsList = [];
  final Ref ref;

  AudioPlayerNotifier(this.ref) : super(const AudioPlayerState()) {
    _initialize();
  }

  void _initialize() {
    // Use read so that settings changes here don't recreate the notifier.
    final settings = ref.read(settingsProvider);
    final historyNotifier = ref.read(historyProvider.notifier);
    _audioPlayer.setShuffleModeEnabled(settings?.shuffleMode ?? false);
    _audioPlayer.setLoopMode(
        settings?.repeatMode == true ? LoopMode.all : LoopMode.off);

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        historyNotifier.addHistory(songsList.elementAt(index));
        state = state.copyWith(currentIndex: index);
      }
    });
    _audioPlayer.playingStream.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });
    _audioPlayer.volumeStream.listen((volume) {
      state = state.copyWith(volume: volume);
    });
    _audioPlayer.loopModeStream.listen((loopMode) {
      state = state.copyWith(loopMode: loopMode);
    });
    _audioPlayer.shuffleModeEnabledStream.listen((isShuffleMode) {
      state = state.copyWith(isShuffleMode: isShuffleMode);
    });
    durationStateStream.listen((updatedState) {
      state = updatedState;
    });
  }

  Stream<AudioPlayerState> get durationStateStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, AudioPlayerState>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (progress, buffered, total) {
          return state.copyWith(
            progress: progress,
            buffered: buffered,
            total: total ?? Duration.zero,
          );
        },
      );

  Future<void> setPlaylist(List<AudioSource> playlist, List<Songs>? songsList,
      {int? initialIndex}) async {
    _currentPlaylist = playlist;

    if (songsList != null) {
      _songsList = ref.read(playingQueueProvider);
    } else {
      _songsList = [];
    }

    final audioSource = ConcatenatingAudioSource(children: _currentPlaylist);
    await _audioPlayer.setAudioSource(audioSource, initialIndex: initialIndex);
    state = state.copyWith(currentIndex: initialIndex);
  }

  void play() => _audioPlayer.play();

  void pause() => _audioPlayer.pause();

  void stop() => _audioPlayer.stop();

  void resetSongsList() {
    _songsList = [];
  }

  void previous() {
    if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
    }
  }

  void next() {
    if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
    } else {
      _audioPlayer.seek(Duration.zero, index: 0);
    }
  }

  void seek(Duration position, {int? index}) {
    _audioPlayer.seek(position, index: index);
  }

  void toggleShuffle() {
    final isShuffleMode = !state.isShuffleMode;
    _audioPlayer.setShuffleModeEnabled(isShuffleMode);
    state = state.copyWith(isShuffleMode: isShuffleMode);
  }

  void toggleLoop() {
    final newLoopMode = state.loopMode == LoopMode.off
        ? LoopMode.all
        : state.loopMode == LoopMode.all
            ? LoopMode.one
            : LoopMode.off;
    _audioPlayer.setLoopMode(newLoopMode);
    state = state.copyWith(loopMode: newLoopMode);
  }

  void adjustVolume(double volume) {
    // final newVolume = (_audioPlayer.volume + delta).clamp(0.0, 1.0);
    // setVolume(newVolume);
    _audioPlayer.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  bool get isPlaylistSet =>
      _audioPlayer.sequence != null && _audioPlayer.sequence!.isNotEmpty;

  List<AudioSource> get currentPlaylist => _currentPlaylist;
  List<Songs> get songsList => _songsList;

  void changeSlabShowStatus() {
    if (songsList.isEmpty) {
      state = state.copyWith(isSlabShown: false);
    } else {
      state = state.copyWith(isSlabShown: true);
    }
  }

  bool get isSlabShown => state.isSlabShown;

  @override
  void dispose() {
    // _audioPlayer.dispose();
    super.dispose();
  }
}
