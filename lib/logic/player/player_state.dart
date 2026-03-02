import 'package:just_audio/just_audio.dart' hide PlayerState;
import '../../data/models/song_model.dart';

/// Các trạng thái của player
abstract class PlayerState {
  final Song? currentSong;
  final List<Song> playlist;
  final bool isPlaying;

  const PlayerState({
    this.currentSong,
    this.playlist = const [],
    this.isPlaying = false,
  });
}

/// Chưa phát gì (MiniPlayer ẩn)
class PlayerInitial extends PlayerState {
  const PlayerInitial() : super();
}

/// Đang phát nhạc
class PlayerPlaying extends PlayerState {
  final AudioPlayer player;

  const PlayerPlaying({
    required this.player,
    required Song currentSong,
    List<Song> playlist = const [],
  }) : super(currentSong: currentSong, playlist: playlist, isPlaying: true);
}

/// Đang tạm dừng
class PlayerPaused extends PlayerState {
  final AudioPlayer player;

  const PlayerPaused({
    required this.player,
    required Song currentSong,
    List<Song> playlist = const [],
  }) : super(currentSong: currentSong, playlist: playlist, isPlaying: false);
}

/// Đã dừng hoàn toàn (MiniPlayer ẩn)
class PlayerStopped extends PlayerState {
  const PlayerStopped() : super();
}

/// Lỗi phát nhạc
class PlayerError extends PlayerState {
  final String message;

  const PlayerError(
    this.message, {
    Song? currentSong,
    List<Song> playlist = const [],
  }) : super(currentSong: currentSong, playlist: playlist);
}
