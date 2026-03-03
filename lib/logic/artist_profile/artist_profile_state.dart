import '../../data/models/artist_profile.dart';
import '../../data/models/song_model.dart';

/// Các trạng thái của ArtistProfileBloc
abstract class ArtistProfileState {}

/// Chưa tải
class ArtistProfileInitial extends ArtistProfileState {}

/// Đang tải
class ArtistProfileLoading extends ArtistProfileState {}

/// Đã tải xong — chứa thông tin nghệ sĩ và danh sách bài hát
class ArtistProfileLoaded extends ArtistProfileState {
  final ArtistProfile artist;
  final List<Song> artistSongs;

  ArtistProfileLoaded({required this.artist, required this.artistSongs});
}

/// Lỗi
class ArtistProfileError extends ArtistProfileState {
  final String message;
  ArtistProfileError(this.message);
}
