import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// BLoC quản lý danh sách bài hát yêu thích
/// Thay thế _likedSongIds và _favoriteSongs trong home_screen.dart
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  // Danh sách nội bộ (mutable) để quản lý state
  final List<Song> _favoriteSongs = [];
  final List<String> _likedSongIds = [];

  FavoritesBloc() : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  /// Tải danh sách yêu thích — hiện tại dùng bộ nhớ RAM
  /// Sau này có thể kết nối Firestore hoặc SQLite
  void _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) {
    emit(
      FavoritesLoaded(
        favoriteSongs: List.unmodifiable(_favoriteSongs),
        likedSongIds: List.unmodifiable(_likedSongIds),
      ),
    );
  }

  /// Toggle yêu thích — thêm hoặc xóa bài hát
  void _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) {
    final songIdStr = event.song.id.toString();

    if (_likedSongIds.contains(songIdStr)) {
      // Bỏ yêu thích
      _likedSongIds.remove(songIdStr);
      _favoriteSongs.removeWhere((s) => s.id == event.song.id);
    } else {
      // Thêm yêu thích
      _likedSongIds.add(songIdStr);
      _favoriteSongs.add(event.song);
    }

    emit(
      FavoritesLoaded(
        favoriteSongs: List.unmodifiable(_favoriteSongs),
        likedSongIds: List.unmodifiable(_likedSongIds),
      ),
    );
  }
}
