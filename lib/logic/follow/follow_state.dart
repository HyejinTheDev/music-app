/// Các trạng thái của FollowBloc
abstract class FollowState {
  final Set<String> followingIds;
  const FollowState({this.followingIds = const {}});

  /// Kiểm tra đang theo dõi artistUserId không
  bool isFollowing(String artistUserId) => followingIds.contains(artistUserId);
}

/// Chưa tải
class FollowInitial extends FollowState {}

/// Đang tải
class FollowLoading extends FollowState {}

/// Đã tải xong
class FollowLoaded extends FollowState {
  const FollowLoaded({required Set<String> followingIds})
    : super(followingIds: followingIds);
}

/// Lỗi
class FollowError extends FollowState {
  final String message;
  const FollowError(this.message);
}
