import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/song_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC quản lý thông tin profile người dùng
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SongRepository songRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc({required this.songRepository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateDisplayName>(_onUpdateDisplayName);
  }

  /// Tải thông tin profile từ FirebaseAuth
  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) {
    final user = _auth.currentUser;
    if (user != null) {
      emit(
        ProfileLoaded(
          displayName: user.displayName ?? 'Nghệ sĩ mới',
          email: user.email ?? 'Guest Mode',
          photoUrl: user.photoURL,
        ),
      );
    } else {
      emit(ProfileError('Chưa đăng nhập'));
    }
  }

  /// Cập nhật tên hiển thị:
  /// 1. Đổi tên trên Firebase Auth
  /// 2. Cập nhật uploader_name trên tất cả bài hát của user trong local DB
  /// 3. Emit state mới
  void _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<ProfileState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ProfileError('Chưa đăng nhập'));
      return;
    }

    emit(ProfileLoading());

    try {
      // 1. Cập nhật tên trên Firebase
      await user.updateDisplayName(event.displayName);
      await user.reload();

      // 2. Cập nhật uploader_name cho tất cả bài hát của user trong local DB
      await songRepository.updateUploaderName(user.uid, event.displayName);

      // 3. Lấy lại user mới nhất
      final updatedUser = _auth.currentUser!;
      emit(
        ProfileLoaded(
          displayName: updatedUser.displayName ?? 'Nghệ sĩ mới',
          email: updatedUser.email ?? 'Guest Mode',
          photoUrl: updatedUser.photoURL,
        ),
      );
    } catch (e) {
      emit(ProfileError('Lỗi cập nhật: ${e.toString()}'));
      // Reload lại profile hiện tại
      add(LoadProfile());
    }
  }
}
