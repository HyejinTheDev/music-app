import '../../data/models/song_model.dart';

/// Các sự kiện cho Feed (bài viết)
abstract class FeedEvent {}

/// Tải danh sách bài viết (bắt đầu lắng nghe stream)
class LoadFeed extends FeedEvent {}

/// Tạo bài viết mới trên feed
class CreatePost extends FeedEvent {
  final String caption;
  final Song song;

  CreatePost({required this.caption, required this.song});
}

/// Sửa caption bài viết
class EditPost extends FeedEvent {
  final String docId;
  final String newCaption;

  EditPost({required this.docId, required this.newCaption});
}

/// Xóa bài viết
class DeletePost extends FeedEvent {
  final String docId;

  DeletePost(this.docId);
}

/// Toggle like bài viết
class ToggleLike extends FeedEvent {
  final String docId;
  final bool isCurrentlyLiked;
  final String postOwnerUserId; // Chủ bài viết → gửi thông báo
  final String songTitle; // Tên bài hát → hiện trong thông báo

  ToggleLike({
    required this.docId,
    required this.isCurrentlyLiked,
    this.postOwnerUserId = '',
    this.songTitle = '',
  });
}

/// Thêm bình luận
class AddComment extends FeedEvent {
  final String postId;
  final String text;
  final String postOwnerUserId; // Chủ bài viết → gửi thông báo

  AddComment({
    required this.postId,
    required this.text,
    this.postOwnerUserId = '',
  });
}
