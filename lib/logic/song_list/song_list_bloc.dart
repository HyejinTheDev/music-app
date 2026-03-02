import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/song_repository.dart';
import 'song_list_event.dart';
import 'song_list_state.dart';

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  final SongRepository songRepository;

  SongListBloc({required this.songRepository}) : super(SongListInitial()) {
    on<LoadSongs>((event, emit) async {
      emit(SongListLoading());
      try {
        // Tự động backfill uploaderName cho bài hát cũ chưa có
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.displayName != null) {
          await songRepository.updateUploaderName(user.uid, user.displayName!);
        }

        final songs = await songRepository.getLocalSongs();
        emit(SongListLoaded(songs));
      } catch (e) {
        emit(SongListError("Lỗi tải nhạc: $e"));
      }
    });
  }
}
