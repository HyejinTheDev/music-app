import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/follow_repository.dart';
import 'follow_event.dart';
import 'follow_state.dart';

/// BLoC quản lý theo dõi nghệ sĩ
/// Delegate tất cả Firestore calls sang FollowRepository (MVVM)
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final FollowRepository followRepository;
  final Set<String> _followingIds = {};

  FollowBloc({required this.followRepository}) : super(FollowInitial()) {
    on<LoadFollowing>(_onLoad);
    on<ToggleFollow>(_onToggle);
  }

  Future<void> _onLoad(LoadFollowing event, Emitter<FollowState> emit) async {
    emit(FollowLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(const FollowLoaded(followingIds: {}));
        return;
      }

      final ids = await followRepository.getFollowingIds(uid);
      _followingIds
        ..clear()
        ..addAll(ids);
      emit(FollowLoaded(followingIds: Set.from(_followingIds)));
    } catch (e) {
      emit(FollowError('Lỗi tải danh sách theo dõi: $e'));
    }
  }

  Future<void> _onToggle(ToggleFollow event, Emitter<FollowState> emit) async {
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) return;

      final followerName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Ẩn danh';

      if (_followingIds.contains(event.artistUserId)) {
        // Bỏ theo dõi
        await followRepository.unfollow(
          currentUid: currentUid,
          artistId: event.artistUserId,
        );
        _followingIds.remove(event.artistUserId);
      } else {
        // Theo dõi
        await followRepository.follow(
          currentUid: currentUid,
          artistId: event.artistUserId,
          artistName: event.artistName,
          followerName: followerName,
        );
        _followingIds.add(event.artistUserId);
      }

      emit(FollowLoaded(followingIds: Set.from(_followingIds)));
    } catch (e) {
      emit(FollowError('Lỗi cập nhật theo dõi: $e'));
    }
  }
}
