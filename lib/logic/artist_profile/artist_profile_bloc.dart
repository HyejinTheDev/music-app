import 'package:flutter_bloc/flutter_bloc.dart';
import 'artist_profile_event.dart';
import 'artist_profile_state.dart';

/// BLoC quản lý màn hình thông tin nghệ sĩ
/// Lọc danh sách bài hát theo userId của nghệ sĩ
class ArtistProfileBloc extends Bloc<ArtistProfileEvent, ArtistProfileState> {
  ArtistProfileBloc() : super(ArtistProfileInitial()) {
    on<LoadArtistProfile>(_onLoadArtistProfile);
  }

  void _onLoadArtistProfile(
    LoadArtistProfile event,
    Emitter<ArtistProfileState> emit,
  ) {
    emit(ArtistProfileLoading());

    try {
      // Lọc bài hát theo userId của nghệ sĩ
      final artistSongs = event.allSongs
          .where((song) => song.userId == event.artist.userId)
          .toList();

      emit(ArtistProfileLoaded(artist: event.artist, artistSongs: artistSongs));
    } catch (e) {
      emit(ArtistProfileError('Lỗi tải thông tin nghệ sĩ: $e'));
    }
  }
}
