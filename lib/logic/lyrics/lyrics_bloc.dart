import 'package:flutter_bloc/flutter_bloc.dart';
import 'lyrics_event.dart';
import 'lyrics_state.dart';

/// BLoC quản lý lời bài hát
/// Lấy lyrics từ Song model
class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  LyricsBloc() : super(LyricsInitial()) {
    on<LoadLyrics>(_onLoadLyrics);
  }

  void _onLoadLyrics(LoadLyrics event, Emitter<LyricsState> emit) {
    emit(LyricsLoading());

    try {
      emit(
        LyricsLoaded(lyrics: event.song.lyrics, songTitle: event.song.title),
      );
    } catch (e) {
      emit(LyricsError('Lỗi tải lời bài hát: $e'));
    }
  }
}
