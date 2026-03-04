import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dataproviders/db_helper.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// BLoC quản lý danh sách bài hát yêu thích
/// Dữ liệu được persist vào SQLite qua DatabaseHelper
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final DatabaseHelper _dbHelper;

  FavoritesBloc({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  /// Tải danh sách yêu thích từ SQLite
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final songs = await _dbHelper.getFavorites();
      final ids = songs.map((s) => s.id.toString()).toList();
      emit(
        FavoritesLoaded(
          favoriteSongs: List.unmodifiable(songs),
          likedSongIds: List.unmodifiable(ids),
        ),
      );
    } catch (e) {
      // Fallback: emit trạng thái rỗng nếu lỗi
      emit(const FavoritesInitial());
    }
  }

  /// Toggle yêu thích — thêm/xóa trong SQLite rồi cập nhật state
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final songId = event.song.id;
      if (songId == null) return;

      final isCurrentlyFavorite = state.isFavorite(event.song);

      if (isCurrentlyFavorite) {
        // Bỏ yêu thích → xóa khỏi SQLite
        await _dbHelper.removeFavorite(songId);
      } else {
        // Thêm yêu thích → insert vào SQLite
        await _dbHelper.insertFavorite(event.song);
      }

      // Reload từ SQLite để đảm bảo consistency
      final songs = await _dbHelper.getFavorites();
      final ids = songs.map((s) => s.id.toString()).toList();
      emit(
        FavoritesLoaded(
          favoriteSongs: List.unmodifiable(songs),
          likedSongIds: List.unmodifiable(ids),
        ),
      );
    } catch (e) {
      // Giữ state hiện tại nếu lỗi
    }
  }
}
