import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'follow_event.dart';
import 'follow_state.dart';

/// BLoC quản lý theo dõi nghệ sĩ
/// Lưu trữ trên Firestore: following/{currentUserId}/artists/{artistUserId}
/// Cập nhật followerCount/followingCount trên users/{uid}
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final _firestore = FirebaseFirestore.instance;
  final Set<String> _followingIds = {};

  FollowBloc() : super(FollowInitial()) {
    on<LoadFollowing>(_onLoad);
    on<ToggleFollow>(_onToggle);
  }

  /// Lấy ref collection following của user hiện tại
  CollectionReference? _getFollowingRef() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('following').doc(uid).collection('artists');
  }

  Future<void> _onLoad(LoadFollowing event, Emitter<FollowState> emit) async {
    emit(FollowLoading());
    try {
      final ref = _getFollowingRef();
      if (ref == null) {
        emit(const FollowLoaded(followingIds: {}));
        return;
      }

      final snapshot = await ref.get();
      _followingIds.clear();
      for (final doc in snapshot.docs) {
        _followingIds.add(doc.id);
      }
      emit(FollowLoaded(followingIds: Set.from(_followingIds)));
    } catch (e) {
      emit(FollowError('Lỗi tải danh sách theo dõi: $e'));
    }
  }

  Future<void> _onToggle(ToggleFollow event, Emitter<FollowState> emit) async {
    try {
      final ref = _getFollowingRef();
      if (ref == null) return;

      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = ref.doc(event.artistUserId);

      if (_followingIds.contains(event.artistUserId)) {
        // Bỏ theo dõi
        await docRef.delete();
        _followingIds.remove(event.artistUserId);

        // Xóa reverse index: followers/{artistUserId}/users/{currentUid}
        await _firestore
            .collection('followers')
            .doc(event.artistUserId)
            .collection('users')
            .doc(currentUid)
            .delete();

        // Giảm followingCount của mình
        await _firestore.collection('users').doc(currentUid).update({
          'followingCount': FieldValue.increment(-1),
        });
        // Giảm followerCount của nghệ sĩ
        await _firestore.collection('users').doc(event.artistUserId).update({
          'followerCount': FieldValue.increment(-1),
        });
      } else {
        // Theo dõi
        await docRef.set({
          'artistName': event.artistName,
          'followedAt': FieldValue.serverTimestamp(),
        });
        _followingIds.add(event.artistUserId);

        // Thêm reverse index: followers/{artistUserId}/users/{currentUid}
        await _firestore
            .collection('followers')
            .doc(event.artistUserId)
            .collection('users')
            .doc(currentUid)
            .set({
              'followerName':
                  FirebaseAuth.instance.currentUser?.displayName ?? 'Ẩn danh',
              'followedAt': FieldValue.serverTimestamp(),
            });

        // Tăng followingCount của mình
        await _firestore.collection('users').doc(currentUid).update({
          'followingCount': FieldValue.increment(1),
        });
        // Tăng followerCount của nghệ sĩ
        await _firestore.collection('users').doc(event.artistUserId).update({
          'followerCount': FieldValue.increment(1),
        });
      }

      emit(FollowLoaded(followingIds: Set.from(_followingIds)));
    } catch (e) {
      emit(FollowError('Lỗi cập nhật theo dõi: $e'));
    }
  }
}
