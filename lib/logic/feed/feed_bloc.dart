import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/post_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

/// BLoC quản lý toàn bộ logic CRUD cho bài viết trên Feed
/// Tách từ logic Firestore trực tiếp trong feed_screen.dart và home_screen.dart
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository postRepository;

  FeedBloc({required this.postRepository}) : super(FeedLoading()) {
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

  /// Tạo bài viết mới
  Future<void> _onCreatePost(CreatePost event, Emitter<FeedState> emit) async {
    emit(FeedActionInProgress());
    try {
      final user = FirebaseAuth.instance.currentUser;

      final post = Post(
        userId: user?.uid,
        userName: user?.displayName ?? "Người dùng ẩn danh",
        userAvatar: user?.photoURL ?? "https://i.pravatar.cc/150?img=12",
        caption: event.caption.isNotEmpty
            ? event.caption
            : "Đang nghe bài này 🎵",
        songTitle: event.song.title,
        songArtist: event.song.artist,
        songCoverUrl: event.song.coverUrl,
        songAudioUrl: event.song.audioUrl,
        songId: event.song.id,
        likedBy: [],
      );

      await postRepository.createPost(post);
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

  /// Toggle like
  Future<void> _onToggleLike(ToggleLike event, Emitter<FeedState> emit) async {
    try {
      await postRepository.toggleLike(
        event.docId,
        event.isCurrentlyLiked,
        event.currentLikes,
      );
    } catch (e) {
      emit(FeedError("Lỗi like: $e"));
      emit(FeedReady());
    }
  }

  /// Thêm bình luận
  Future<void> _onAddComment(AddComment event, Emitter<FeedState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final comment = Comment(
        userName: user?.displayName ?? 'Ẩn danh',
        text: event.text,
        timeAgo: 'Vừa xong',
      );

      await postRepository.addComment(event.postId, comment);
    } catch (e) {
      emit(FeedError("Lỗi bình luận: $e"));
      emit(FeedReady());
    }
  }
}
