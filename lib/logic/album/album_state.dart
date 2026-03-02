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

/// Lỗi
class AlbumError extends AlbumState {
  final String message;

  AlbumError(this.message);
}
