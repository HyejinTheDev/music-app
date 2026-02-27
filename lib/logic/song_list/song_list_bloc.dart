import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/song_repository.dart';
import 'song_list_event.dart';
import 'song_list_state.dart';

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  final SongRepository songRepository;

  SongListBloc({required this.songRepository}) : super(SongListInitial()) {
    on<LoadSongs>((event, emit) async {
      emit(SongListLoading());
      try {
        // Lấy bài hát từ Database (SQLite)
        final songs = await songRepository.getLocalSongs();
        emit(SongListLoaded(songs));
      } catch (e) {
        emit(SongListError("Lỗi tải nhạc: $e"));
      }
    });
  }
}