/// Các trạng thái của Feed
abstract class FeedState {}

/// Đang tải bài viết
class FeedLoading extends FeedState {}

/// Đã tải xong — feed hiển thị real-time qua StreamBuilder nên state chỉ cần báo sẵn sàng
class FeedReady extends FeedState {}

/// Đang tạo/sửa/xóa bài viết
class FeedActionInProgress extends FeedState {}

/// Thao tác thành công (tạo/sửa/xóa)
class FeedActionSuccess extends FeedState {
  final String message;

  FeedActionSuccess(this.message);
}

/// Lỗi
class FeedError extends FeedState {
  final String message;

  FeedError(this.message);
}
