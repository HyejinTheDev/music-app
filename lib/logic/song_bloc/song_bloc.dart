import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'song_event.dart';
import 'song_state.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/repositories/notification_repository.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final SongRepository songRepository;
  final NotificationRepository? notificationRepository;

  SongBloc({required this.songRepository, this.notificationRepository})
    : super(SongLoading()) {
    // Xử lý: Load danh sách
    on<LoadSongs>((event, emit) async {
      emit(SongLoading());
      try {
        final songs = await songRepository.getLocalSongs();
        emit(SongLoaded(songs));
      } catch (e) {
        emit(SongError("Lỗi tải dữ liệu: $e"));
      }
    });

    // Xử lý: Thêm bài hát → lưu local + sync cloud + thông báo followers
    on<AddSongEvent>((event, emit) async {
      try {
        await songRepository.addSong(event.song);
        add(LoadSongs());

        // Sync cloud (không chặn UI)
        try {
          await songRepository.syncToCloud();
        } catch (_) {}

        // Gửi thông báo cho followers (tách riêng để lỗi sync không ảnh hưởng)
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && notificationRepository != null) {
            await notificationRepository!.notifyFollowersOfNewSong(
              uploaderUserId: user.uid,
              uploaderUserName: user.displayName ?? 'Người dùng',
              songTitle: event.song.title,
              songArtist: event.song.artist,
            );
          }
        } catch (_) {}
      } catch (e) {
        emit(SongError("Không thể thêm bài hát"));
      }
    });

    // Xử lý: Sửa bài hát
    on<UpdateSongEvent>((event, emit) async {
      try {
        await songRepository.updateSong(event.song);
        add(LoadSongs());

        try {
          await songRepository.syncToCloud();
        } catch (_) {}
      } catch (e) {
        emit(SongError("Lỗi cập nhật"));
      }
    });

    // Xử lý: Xóa bài hát
    on<DeleteSongEvent>((event, emit) async {
      try {
        await songRepository.deleteSong(event.id);
        add(LoadSongs());

        try {
          await songRepository.syncToCloud();
        } catch (_) {}
      } catch (e) {
        emit(SongError("Lỗi xóa bài hát"));
      }
    });

    // Xử lý: Đồng bộ LÊN Firebase
    on<SyncToCloudEvent>((event, emit) async {
      try {
        emit(SongLoading());
        await songRepository.syncToCloud();
        add(LoadSongs()); // Đồng bộ xong load lại
      } catch (e) {
        emit(SongError("Lỗi đồng bộ lên Cloud: $e"));
      }
    });

    // Xử lý: Đồng bộ TỪ Firebase về
    on<SyncFromCloudEvent>((event, emit) async {
      try {
        emit(SongLoading());
        await songRepository.syncFromCloud();
        add(LoadSongs()); // Tải xong load lại để thấy dữ liệu mới
      } catch (e) {
        emit(SongError("Lỗi tải từ Cloud: $e"));
      }
    });
  }
}
