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
        final user = FirebaseAuth.instance.currentUser;

        // Sync từ Firebase cloud (không chặn UI nếu lỗi/timeout)
        if (user != null) {
          try {
            await songRepository.syncFromCloud().timeout(
              const Duration(seconds: 10),
            );
          } catch (_) {
            // Bỏ qua lỗi sync — vẫn hiện bài hát local
          }
        }

        // Backfill uploaderName cho bài hát cũ chưa có
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
