import '../../data/models/artist_profile.dart';
import '../../data/models/song_model.dart';

/// Các sự kiện cho ArtistProfileBloc
abstract class ArtistProfileEvent {}

/// Tải thông tin nghệ sĩ và danh sách bài hát của họ
class LoadArtistProfile extends ArtistProfileEvent {
  final ArtistProfile artist;
  final List<Song> allSongs;

  LoadArtistProfile({required this.artist, required this.allSongs});
}
