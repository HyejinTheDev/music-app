import '../../data/models/song_model.dart';

/// Các sự kiện quản lý bài hát yêu thích
abstract class FavoritesEvent {}

/// Tải danh sách yêu thích ban đầu
class LoadFavorites extends FavoritesEvent {}

/// Toggle yêu thích (thêm nếu chưa có, xóa nếu đã có)
class ToggleFavorite extends FavoritesEvent {
  final Song song;

  ToggleFavorite(this.song);
}
