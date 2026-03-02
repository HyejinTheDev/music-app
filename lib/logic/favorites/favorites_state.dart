import '../../data/models/song_model.dart';

/// Các trạng thái của danh sách yêu thích
abstract class FavoritesState {
  final List<Song> favoriteSongs;
  final List<String> likedSongIds;

  const FavoritesState({
    this.favoriteSongs = const [],
    this.likedSongIds = const [],
  });

  /// Kiểm tra nhanh bài hát có trong danh sách yêu thích không
  bool isFavorite(Song song) => likedSongIds.contains(song.id.toString());
}

/// Trạng thái ban đầu (chưa có gì)
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial() : super();
}

/// Đã tải xong danh sách yêu thích
class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({
    required List<Song> favoriteSongs,
    required List<String> likedSongIds,
  }) : super(favoriteSongs: favoriteSongs, likedSongIds: likedSongIds);
}
