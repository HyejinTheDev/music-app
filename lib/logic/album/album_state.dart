import '../../data/models/song_model.dart';

/// Các trạng thái quản lý album
abstract class AlbumState {}

/// Đang tải
class AlbumLoading extends AlbumState {}

/// Sẵn sàng — danh sách albums hiển thị qua StreamBuilder
class AlbumReady extends AlbumState {}

/// Đang tạo album
class AlbumCreating extends AlbumState {}

/// Tạo album thành công
class AlbumCreateSuccess extends AlbumState {
  final String message;

  AlbumCreateSuccess(this.message);
}

/// Đã tải danh sách bài hát của user (cho màn tạo album)
class AlbumUserSongsLoaded extends AlbumState {
  final List<Song> userSongs;

  AlbumUserSongsLoaded(this.userSongs);
}

/// Lỗi
class AlbumError extends AlbumState {
  final String message;

  AlbumError(this.message);
}
