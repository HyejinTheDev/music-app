import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// Repository đóng gói tất cả Firestore calls cho Posts và Comments
/// Tách từ logic trực tiếp trong feed_screen.dart và home_screen.dart
class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================
  // POSTS
  // ========================

  /// Stream danh sách bài viết (real-time)
  Stream<QuerySnapshot> getPostsStream() {
    return _firestore.collection('posts').snapshots();
  }

  /// Tạo bài viết mới
  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').add(post.toMap());
  }

  /// Cập nhật caption bài viết
  Future<void> updatePostCaption(String docId, String newCaption) async {
    await _firestore.collection('posts').doc(docId).update({
      'caption': newCaption,
    });
  }

  /// Xóa bài viết (kèm xóa comments subcollection)
  Future<void> deletePost(String docId) async {
    // Xóa tất cả comments trước
    final commentsSnapshot = await _firestore
        .collection('posts')
        .doc(docId)
        .collection('comments')
        .get();

    for (final doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Xóa bài viết
    await _firestore.collection('posts').doc(docId).delete();
  }

  /// Toggle like cho bài viết
  Future<void> toggleLike(
    String docId,
    bool isCurrentlyLiked,
    int currentLikes,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (isCurrentlyLiked) {
      await _firestore.collection('posts').doc(docId).update({
        'likes': currentLikes - 1,
        'likedBy': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await _firestore.collection('posts').doc(docId).update({
        'likes': currentLikes + 1,
        'likedBy': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  // ========================
  // COMMENTS
  // ========================

  /// Stream danh sách bình luận của một bài viết (real-time)
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Thêm bình luận mới
  Future<void> addComment(String postId, Comment comment) async {
    // Thêm comment vào subcollection
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment.toMap());

    // Cập nhật số lượng comment trên post
    final commentsSnapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    await _firestore.collection('posts').doc(postId).update({
      'comments': commentsSnapshot.docs.length,
    });
  }

  // ========================
  // SHARING (Tạo post từ chia sẻ bài hát)
  // ========================

  /// Chia sẻ bài hát lên feed — dùng trong home_screen._handleShowOptions
  Future<void> shareToFeed({
    required String songTitle,
    required String songArtist,
    required String songCoverUrl,
    required String songAudioUrl,
    required int? songId,
    required String caption,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    final post = Post(
      userId: user?.uid,
      userName: user?.displayName ?? "Người dùng ẩn danh",
      userAvatar: user?.photoURL ?? "https://i.pravatar.cc/150?img=12",
      caption: caption,
      songTitle: songTitle,
      songArtist: songArtist,
      songCoverUrl: songCoverUrl,
      songAudioUrl: songAudioUrl,
      songId: songId,
      likedBy: [],
    );

    await createPost(post);
  }

  /// Lấy bài hát của user từ Firestore (dùng khi tạo bài viết)
  Stream<QuerySnapshot> getUserSongsStream(String userId) {
    return _firestore
        .collection('user_songs')
        .doc(userId)
        .collection('songs')
        .snapshots();
  }
}
