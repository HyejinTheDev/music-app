import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/song_repository.dart';
import 'song_list_event.dart';
import 'song_list_state.dart';

/// BLoC quản lý danh sách bài hát
/// - LoadSongs: chỉ đọc local SQLite (nhanh, không xung đột)
/// - SyncAndLoadSongs: sync cloud rồi load (user bấm ☁️ hoặc lần đầu mở app)
class SongListBloc extends Bloc<SongListEvent, SongListState> {
  final SongRepository songRepository;

  SongListBloc({required this.songRepository}) : super(SongListInitial()) {
    // Chỉ đọc local — không gọi cloud
    on<LoadSongs>((event, emit) async {
      emit(SongListLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

         // Backfill uploaderName
        if (user != null && user.displayName != null) {
          await songRepository.updateUploaderName(user.uid, user.displayName!);
        }

        final songs = await songRepository.getLocalSongs();
        emit(SongListLoaded(songs));
      } catch (e) {
        emit(SongListError("Lỗi tải nhạc: $e"));
      }
    });

    // Sync cloud TRƯỚC → rồi load local
    on<SyncAndLoadSongs>((event, emit) async {
      emit(SongListLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // 1. Push local lên cloud trước
          try {
            debugPrint('[SyncAndLoad] 📤 Đẩy bài hát local lên cloud...');
            await songRepository.syncToCloud();
          } catch (e) {
            debugPrint('[SyncAndLoad] ⚠️ Lỗi push: $e');
          }

          // 2. Kéo tất cả bài hát từ cloud về
          try {
            debugPrint('[SyncAndLoad] 📥 Kéo bài hát từ cloud...');
            await songRepository.syncFromCloud().timeout(
              const Duration(seconds: 30),
            );
          } catch (e) {
            debugPrint('[SyncAndLoad] ⚠️ Lỗi pull: $e');
          }
        }

        // Backfill uploaderName
        if (user != null && user.displayName != null) {
          await songRepository.updateUploaderName(user.uid, user.displayName!);
        }

        final songs = await songRepository.getLocalSongs();
        debugPrint('[SyncAndLoad] ✅ Tổng ${songs.length} bài hát');
        emit(SongListLoaded(songs));
      } catch (e) {
        emit(SongListError("Lỗi đồng bộ: $e"));
      }
    });
  }
}
