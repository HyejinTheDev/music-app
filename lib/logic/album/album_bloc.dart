import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/album_model.dart';
import '../../data/repositories/album_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/dataproviders/db_helper.dart';
import 'album_event.dart';
import 'album_state.dart';

/// BLoC quản lý toàn bộ logic CRUD cho Albums
/// Tách từ logic Firestore trực tiếp trong add_album_screen.dart
class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository albumRepository;
  final AuthRepository authRepository;

  AlbumBloc({required this.albumRepository, required this.authRepository})
    : super(AlbumLoading()) {
    on<LoadAlbums>(_onLoadAlbums);
    on<CreateAlbum>(_onCreateAlbum);
    on<DeleteAlbum>(_onDeleteAlbum);
    on<LoadUserSongs>(_onLoadUserSongs);
  }

  /// Tải albums — chuyển sang trạng thái sẵn sàng (list qua StreamBuilder)
  void _onLoadAlbums(LoadAlbums event, Emitter<AlbumState> emit) {
    emit(AlbumReady());
  }

  /// Tải danh sách bài hát của user hiện tại từ local DB
  Future<void> _onLoadUserSongs(
    LoadUserSongs event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumLoading());
    try {
      final allSongs = await DatabaseHelper().getSongs();
      final currentUid = authRepository.currentUserId;
      final userSongs = allSongs
          .where((song) => song.userId == currentUid)
          .toList();
      emit(AlbumUserSongsLoaded(userSongs));
    } catch (e) {
      emit(AlbumError("Lỗi tải danh sách bài hát: $e"));
    }
  }

  /// Tạo album mới
  Future<void> _onCreateAlbum(
    CreateAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    emit(AlbumCreating());
    try {
      final uid = authRepository.currentUserId;
      final displayName = authRepository.currentUserDisplayName;
      final email = authRepository.currentUserEmail;
      final artistName =
          displayName ?? email?.split('@')[0] ?? 'Nghệ sĩ ẩn danh';

      // Nếu link ảnh trống, dùng ảnh mặc định
      final finalCoverUrl = event.coverUrl.isNotEmpty
          ? event.coverUrl
          : Album.defaultCoverUrl;

      final album = Album(
        title: event.title,
        artist: artistName,
        userId: uid,
        coverUrl: finalCoverUrl,
        songIds: event.songIds,
      );

      await albumRepository.createAlbum(album);
      emit(AlbumCreateSuccess("Đã tạo Album thành công!"));
      emit(AlbumReady());
    } catch (e) {
      emit(AlbumError("Lỗi tạo Album: $e"));
      emit(AlbumReady());
    }
  }

  /// Xóa album
  Future<void> _onDeleteAlbum(
    DeleteAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    try {
      await albumRepository.deleteAlbum(event.docId);
      emit(AlbumCreateSuccess("Đã xóa Album!"));
      emit(AlbumReady());
    } catch (e) {
      emit(AlbumError("Lỗi xóa Album: $e"));
      emit(AlbumReady());
    }
  }
}
