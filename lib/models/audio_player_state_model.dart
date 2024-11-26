import 'package:just_audio/just_audio.dart';

class AudioPlayerState {
  final int? currentIndex;
  final bool isPlaying;
  final double volume;
  final LoopMode loopMode;
  final bool isShuffleMode;
  final Duration progress;
  final Duration buffered;
  final Duration total;
  final bool isSlabShown;

  const AudioPlayerState({
    this.currentIndex,
    this.isPlaying = false,
    this.volume = 1.0,
    this.loopMode = LoopMode.off,
    this.isShuffleMode = false,
    this.progress = Duration.zero,
    this.buffered = Duration.zero,
    this.total = Duration.zero,
    this.isSlabShown = false,
  });

  AudioPlayerState copyWith({
    int? currentIndex,
    bool? isPlaying,
    double? volume,
    LoopMode? loopMode,
    bool? isShuffleMode,
    Duration? progress,
    Duration? buffered,
    Duration? total,
    bool? isSlabShown,
  }) {
    return AudioPlayerState(
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      loopMode: loopMode ?? this.loopMode,
      isShuffleMode: isShuffleMode ?? this.isShuffleMode,
      progress: progress ?? this.progress,
      buffered: buffered ?? this.buffered,
      total: total ?? this.total,
      isSlabShown: isSlabShown ?? this.isSlabShown,
    );
  }
}
