import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/auth_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

/// BLoC quản lý toàn bộ logic CRUD cho bài viết trên Feed
/// Sử dụng AuthRepository (MVVM) thay vì gọi FirebaseAuth trực tiếp
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository postRepository;
  final NotificationRepository notificationRepository;
  final AuthRepository authRepository;

  FeedBloc({
    required this.postRepository,
    required this.notificationRepository,
    required this.authRepository,
  }) : super(FeedLoading()) {
    on<LoadFeed>(_onLoadFeed);
    on<CreatePost>(_onCreatePost);
    on<EditPost>(_onEditPost);
    on<DeletePost>(_onDeletePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
  }

  /// Tải feed — chuyển sang trạng thái sẵn sàng (list hiển thị qua StreamBuilder)
  void _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) {
    emit(FeedReady());
  }

  /// Tạo bài viết mới + gửi thông báo
  Future<void> _onCreatePost(CreatePost event, Emitter<FeedState> emit) async {
    emit(FeedActionInProgress());
    try {
      final user = authRepository.currentUser;
      final caption = event.caption.isNotEmpty
          ? event.caption
          : "Đang nghe bài này 🎵";

      final post = Post(
        userId: user?.uid,
        userName: user?.displayName ?? "Người dùng ẩn danh",
        userAvatar: user?.photoURL ?? "https://i.pravatar.cc/150?img=12",
        caption: caption,
        songTitle: event.song.title,
        songArtist: event.song.artist,
        songCoverUrl: event.song.coverUrl,
        songAudioUrl: event.song.audioUrl,
        songId: event.song.id,
        likedBy: [],
      );

      // Tạo post trên Firestore
      final docRef = await postRepository.createPostAndReturnRef(post);

      if (user != null) {
        // 1. Gửi thông báo cho CHỦ BÀI HÁT (chia sẻ bài hát của họ)
        final songOwnerId = event.song.userId;
        if (songOwnerId != null &&
            songOwnerId.isNotEmpty &&
            songOwnerId != user.uid) {
          try {
            await notificationRepository.notifySongOwnerOfShare(
              songOwnerUserId: songOwnerId,
              sharerUserId: user.uid,
              sharerUserName: user.displayName ?? 'Người dùng',
              postId: docRef.id,
              songTitle: event.song.title,
            );
          } catch (_) {}
        }

        // 2. Gửi thông báo cho followers
        try {
          await notificationRepository.notifyFollowersOfNewPost(
            posterUserId: user.uid,
            posterUserName: user.displayName ?? 'Người dùng ẩn danh',
            postId: docRef.id,
            songTitle: event.song.title,
            caption: caption,
          );
        } catch (_) {}
      }

      emit(FeedActionSuccess("Đã đăng bài thành công!"));
      emit(FeedReady());
    } catch (e) {
      emit(FeedError("Lỗi đăng bài: $e"));
      emit(FeedReady());
    }
  }

  /// Sửa caption bài viết
  Future<void> _onEditPost(EditPost event, Emitter<FeedState> emit) async {
    emit(FeedActionInProgress());
    try {
      await postRepository.updatePostCaption(event.docId, event.newCaption);
      emit(FeedActionSuccess("Đã cập nhật bài viết!"));
      emit(FeedReady());
    } catch (e) {
      emit(FeedError("Lỗi cập nhật: $e"));
      emit(FeedReady());
    }
  }

  /// Xóa bài viết
  Future<void> _onDeletePost(DeletePost event, Emitter<FeedState> emit) async {
    emit(FeedActionInProgress());
    try {
      await postRepository.deletePost(event.docId);
      emit(FeedActionSuccess("Đã xóa bài viết!"));
      emit(FeedReady());
    } catch (e) {
      emit(FeedError("Lỗi xóa: $e"));
      emit(FeedReady());
    }
  }

  /// Toggle like — dùng FieldValue.increment (atomic, tránh race condition)
  Future<void> _onToggleLike(ToggleLike event, Emitter<FeedState> emit) async {
    try {
      await postRepository.toggleLike(event.docId, event.isCurrentlyLiked);

      // Gửi thông báo cho chủ bài viết khi LIKE (không phải unlike)
      if (!event.isCurrentlyLiked && event.postOwnerUserId.isNotEmpty) {
        final user = authRepository.currentUser;
        if (user != null) {
          try {
            await notificationRepository.notifyPostOwnerOfLike(
              postOwnerUserId: event.postOwnerUserId,
              likerUserId: user.uid,
              likerUserName: user.displayName ?? 'Người dùng',
              postId: event.docId,
              songTitle: event.songTitle,
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      emit(FeedError("Lỗi like: $e"));
      emit(FeedReady());
    }
  }

  /// Thêm bình luận
  Future<void> _onAddComment(AddComment event, Emitter<FeedState> emit) async {
    try {
      final user = authRepository.currentUser;

      final comment = Comment(
        userName: user?.displayName ?? 'Ẩn danh',
        text: event.text,
      );

      await postRepository.addComment(event.postId, comment);

      // Gửi thông báo cho chủ bài viết
      if (user != null && event.postOwnerUserId.isNotEmpty) {
        try {
          await notificationRepository.notifyPostOwnerOfComment(
            postOwnerUserId: event.postOwnerUserId,
            commenterUserId: user.uid,
            commenterUserName: user.displayName ?? 'Người dùng',
            postId: event.postId,
            commentText: event.text,
          );
        } catch (_) {}
      }
    } catch (e) {
      emit(FeedError("Lỗi bình luận: $e"));
      emit(FeedReady());
    }
  }
}
