/// Các sự kiện cho FollowBloc
abstract class FollowEvent {}

/// Tải danh sách đang theo dõi
class LoadFollowing extends FollowEvent {}

/// Toggle theo dõi / bỏ theo dõi nghệ sĩ
class ToggleFollow extends FollowEvent {
  final String artistUserId;
  final String artistName;

  ToggleFollow({required this.artistUserId, required this.artistName});
}
