import '../../data/models/album_model.dart';

/// Các sự kiện quản lý album
abstract class AlbumEvent {}

/// Tải danh sách albums
class LoadAlbums extends AlbumEvent {}

/// Tạo album mới
class CreateAlbum extends AlbumEvent {
  final String title;
  final String coverUrl;
  final List<String> songIds;

  CreateAlbum({
    required this.title,
    required this.coverUrl,
    required this.songIds,
  });
}

/// Xóa album
class DeleteAlbum extends AlbumEvent {
  final String docId;

  DeleteAlbum(this.docId);
}

/// Cập nhật album
class UpdateAlbum extends AlbumEvent {
  final String docId;
  final String title;
  final String coverUrl;
  final List<String> songIds;

  UpdateAlbum({
    required this.docId,
    required this.title,
    required this.coverUrl,
    required this.songIds,
  });
}

/// Tải danh sách bài hát của user từ local DB (cho màn tạo album)
class LoadUserSongs extends AlbumEvent {}
