import 'package:flutter/foundation.dart';
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
    debugPrint(
      '[NotifyPost] 📢 Gửi thông báo cho followers của $posterUserName ($posterUserId)',
    );

    // 1. Query tất cả followers của poster
    final followersSnapshot = await _firestore
        .collection('followers')
        .doc(posterUserId)
        .collection('users')
        .get();

    debugPrint(
      '[NotifyPost] Tìm thấy ${followersSnapshot.docs.length} followers',
    );

    if (followersSnapshot.docs.isEmpty) {
      debugPrint('[NotifyPost] ⚠️ Không có follower nào → bỏ qua');
      return;
    }

    // 2. Tạo notification model
    final now = DateTime.now();
    final notifData = NotificationModel(
      id: '',
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
      debugPrint('[NotifyPost] → Gửi cho: $followerUserId');
      final notifRef = _firestore
          .collection('user_notifications')
          .doc(followerUserId)
          .collection('items')
          .doc();
      batch.set(notifRef, notifData);
    }
    await batch.commit();
    debugPrint(
      '[NotifyPost] ✅ Đã gửi thông báo cho ${followersSnapshot.docs.length} followers',
    );
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

  // ========================
  // LIKE — Thông báo khi ai đó thích bài viết
  // ========================

  /// Gửi thông báo cho chủ bài viết khi có người like
  Future<void> notifyPostOwnerOfLike({
    required String postOwnerUserId,
    required String likerUserId,
    required String likerUserName,
    required String postId,
    required String songTitle,
  }) async {
    // Không thông báo cho chính mình
    if (postOwnerUserId == likerUserId) return;

    final notifData = NotificationModel(
      id: '',
      title: '$likerUserName đã thích bài viết của bạn',
      body: songTitle.isNotEmpty ? '🎵 $songTitle' : 'Đã thích bài viết',
      type: NotificationType.like,
      artistId: likerUserId,
      artistName: likerUserName,
      postId: postId,
      timestamp: DateTime.now(),
    ).toMap();

    await _firestore
        .collection('user_notifications')
        .doc(postOwnerUserId)
        .collection('items')
        .add(notifData);
  }

  // ========================
  // SHARE — Thông báo khi ai đó chia sẻ bài hát của bạn
  // ========================

  /// Gửi thông báo cho chủ bài hát khi có người chia sẻ
  Future<void> notifySongOwnerOfShare({
    required String songOwnerUserId,
    required String sharerUserId,
    required String sharerUserName,
    required String postId,
    required String songTitle,
  }) async {
    // Không thông báo cho chính mình
    if (songOwnerUserId == sharerUserId) return;

    final notifData = NotificationModel(
      id: '',
      title: '$sharerUserName đã chia sẻ bài hát của bạn',
      body: songTitle.isNotEmpty ? '🎵 $songTitle' : 'Đã chia sẻ bài hát',
      type: NotificationType.newPost,
      artistId: sharerUserId,
      artistName: sharerUserName,
      postId: postId,
      timestamp: DateTime.now(),
    ).toMap();

    await _firestore
        .collection('user_notifications')
        .doc(songOwnerUserId)
        .collection('items')
        .add(notifData);
  }

  // ========================
  // COMMENT — Thông báo khi ai đó bình luận
  // ========================

  /// Gửi thông báo cho chủ bài viết khi có người comment
  Future<void> notifyPostOwnerOfComment({
    required String postOwnerUserId,
    required String commenterUserId,
    required String commenterUserName,
    required String postId,
    required String commentText,
  }) async {
    // Không thông báo cho chính mình
    if (postOwnerUserId == commenterUserId) return;

    final notifData = NotificationModel(
      id: '',
      title: '$commenterUserName đã bình luận',
      body: commentText.length > 100
          ? '${commentText.substring(0, 100)}...'
          : commentText,
      type: NotificationType.comment,
      artistId: commenterUserId,
      artistName: commenterUserName,
      postId: postId,
      timestamp: DateTime.now(),
    ).toMap();

    await _firestore
        .collection('user_notifications')
        .doc(postOwnerUserId)
        .collection('items')
        .add(notifData);
  }

  // ========================
  // NEW SONG — Thông báo khi đăng bài hát mới
  // ========================

  /// Gửi thông báo cho TẤT CẢ followers khi user đăng bài hát mới
  Future<void> notifyFollowersOfNewSong({
    required String uploaderUserId,
    required String uploaderUserName,
    required String songTitle,
    required String songArtist,
  }) async {
    final followersSnapshot = await _firestore
        .collection('followers')
        .doc(uploaderUserId)
        .collection('users')
        .get();

    if (followersSnapshot.docs.isEmpty) return;

    final notifData = NotificationModel(
      id: '',
      title: '$uploaderUserName đã đăng bài hát mới',
      body: '🎵 $songTitle - $songArtist',
      type: NotificationType.newSong,
      artistId: uploaderUserId,
      artistName: uploaderUserName,
      timestamp: DateTime.now(),
    ).toMap();

    final batch = _firestore.batch();
    for (final followerDoc in followersSnapshot.docs) {
      final followerUserId = followerDoc.id;
      final notifRef = _firestore
          .collection('user_notifications')
          .doc(followerUserId)
          .collection('items')
          .doc();
      batch.set(notifRef, notifData);
    }
    await batch.commit();
  }
}
