import '../../data/models/song_model.dart';

/// Các sự kiện điều khiển player
abstract class PlayerEvent {}

/// Phát một bài hát (nếu đang phát bài này rồi thì toggle play/pause)
class PlaySongRequested extends PlayerEvent {
  final Song song;

  PlaySongRequested(this.song);
}

/// Tạm dừng
class PauseRequested extends PlayerEvent {}

/// Tiếp tục phát
class ResumeRequested extends PlayerEvent {}

/// Dừng hoàn toàn và ẩn player
class StopRequested extends PlayerEvent {}

/// Chuyển bài tiếp theo
class NextSongRequested extends PlayerEvent {}

/// Chuyển bài trước đó
class PreviousSongRequested extends PlayerEvent {}

/// Cập nhật danh sách bài hát hiện tại (để next/previous hoạt động)
class UpdatePlaylist extends PlayerEvent {
  final List<Song> songs;

  UpdatePlaylist(this.songs);
}

/// Seek đến vị trí cụ thể trong bài hát
class SeekRequested extends PlayerEvent {
  final Duration position;

  SeekRequested(this.position);
}
