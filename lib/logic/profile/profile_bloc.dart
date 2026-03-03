import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/song_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC quản lý thông tin profile người dùng
/// Lưu profile riêng mỗi user trong Firestore: users/{uid}
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SongRepository songRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileBloc({required this.songRepository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateDisplayName>(_onUpdateDisplayName);
    on<UpdateProfile>(_onUpdateProfile);
  }

  /// Lấy ref document profile của user
  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Tải thông tin profile từ Firestore
  /// Nếu chưa có document → tạo mới từ Firebase Auth data
  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ProfileError('Chưa đăng nhập'));
      return;
    }

    try {
      final doc = await _userDoc(user.uid).get();

      String displayName;
      String email;
      String? photoUrl;

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        displayName = data['displayName'] ?? user.displayName ?? 'Nghệ sĩ mới';
        email = data['email'] ?? user.email ?? 'Guest Mode';
        photoUrl = data['photoUrl'];
      } else {
        // Tạo document mới từ Firebase Auth data
        displayName = user.displayName ?? 'Nghệ sĩ mới';
        email = user.email ?? 'Guest Mode';
        photoUrl = user.photoURL;

        await _userDoc(user.uid).set({
          'displayName': displayName,
          'email': email,
          'photoUrl': photoUrl,
          'followerCount': 0,
          'followingCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Lấy follower/following counts
      final followerCount = (doc.exists)
          ? ((doc.data() as Map<String, dynamic>)['followerCount'] ?? 0) as int
          : 0;
      final followingCount = (doc.exists)
          ? ((doc.data() as Map<String, dynamic>)['followingCount'] ?? 0) as int
          : 0;

      emit(
        ProfileLoaded(
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          followerCount: followerCount,
          followingCount: followingCount,
        ),
      );
    } catch (e) {
      emit(ProfileError('Lỗi tải profile: $e'));
    }
  }

  /// Cập nhật tên hiển thị (backward-compatible)
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
      // Cập nhật trên Firestore
      await _userDoc(user.uid).update({'displayName': event.displayName});

      // Đồng bộ lên Firebase Auth
      await user.updateDisplayName(event.displayName);
      await user.reload();

      // Cập nhật uploader_name trong local DB
      await songRepository.updateUploaderName(user.uid, event.displayName);

      // Reload profile
      add(LoadProfile());
    } catch (e) {
      emit(ProfileError('Lỗi cập nhật: ${e.toString()}'));
      add(LoadProfile());
    }
  }

  /// Cập nhật profile: tên + ảnh trên Firestore
  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ProfileError('Chưa đăng nhập'));
      return;
    }

    emit(ProfileLoading());

    try {
      // Cập nhật trên Firestore
      final updates = <String, dynamic>{'displayName': event.displayName};
      if (event.photoUrl != null) {
        updates['photoUrl'] = event.photoUrl;
      }
      await _userDoc(user.uid).update(updates);

      // Đồng bộ lên Firebase Auth
      await user.updateDisplayName(event.displayName);
      if (event.photoUrl != null) {
        await user.updatePhotoURL(event.photoUrl);
      }
      await user.reload();

      // Cập nhật uploader_name trong local DB
      await songRepository.updateUploaderName(user.uid, event.displayName);

      // Reload profile
      add(LoadProfile());
    } catch (e) {
      emit(ProfileError('Lỗi cập nhật: ${e.toString()}'));
      add(LoadProfile());
    }
  }
}
