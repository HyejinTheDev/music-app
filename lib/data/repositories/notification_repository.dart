import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// Repository đóng gói tất cả Firestore calls cho Notifications
/// Mỗi user có riêng collection: user_notifications/{userId}/items
/// Khi ai đó đăng bài → tạo notification cho TẤT CẢ followers của họ
class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========================
  // LISTEN — Lắng nghe thông báo cá nhân
  // ========================

  /// Stream thông báo real-time cho user, mới nhất lên đầu
  Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('user_notifications')
        .doc(userId)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // ========================
  // CREATE — Gửi thông báo cho followers
  // ========================

  /// Tạo thông báo cho TẤT CẢ followers của [posterUserId]
  /// Gọi khi user đăng bài mới trên Feed
  Future<void> notifyFollowersOfNewPost({
    required String posterUserId,
    required String posterUserName,
    required String postId,
    required String songTitle,
    required String caption,
  }) async {
    // 1. Query tất cả followers của poster
    final followersSnapshot = await _firestore
        .collection('followers')
        .doc(posterUserId)
        .collection('users')
        .get();

    if (followersSnapshot.docs.isEmpty) return;

    // 2. Tạo notification model
    final now = DateTime.now();
    final notifData = NotificationModel(
      id: '', // Firestore sẽ tự tạo ID
      title: '$posterUserName đã đăng bài mới',
      body: songTitle.isNotEmpty
          ? 'Đang nghe: $songTitle 🎵'
          : caption.isNotEmpty
          ? caption
          : 'Đã chia sẻ một bài hát mới',
      type: NotificationType.newPost,
      artistId: posterUserId,
      artistName: posterUserName,
      postId: postId,
      postCaption: caption,
      timestamp: now,
    ).toMap();

    // 3. Batch write — tạo notification cho mỗi follower
    final batch = _firestore.batch();
    for (final followerDoc in followersSnapshot.docs) {
      final followerUserId = followerDoc.id;
      final notifRef = _firestore
          .collection('user_notifications')
          .doc(followerUserId)
          .collection('items')
          .doc(); // Auto-generate ID
      batch.set(notifRef, notifData);
    }
    await batch.commit();
  }

  // ========================
  // UPDATE — Đánh dấu đã đọc
  // ========================

  /// Đánh dấu một thông báo đã đọc
  Future<void> markAsRead(String userId, String notifId) async {
    await _firestore
        .collection('user_notifications')
        .doc(userId)
        .collection('items')
        .doc(notifId)
        .update({'isRead': true});
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('user_notifications')
        .doc(userId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
