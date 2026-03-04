import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository đóng gói tất cả Firestore calls cho Follow/Unfollow
/// Tách từ logic trực tiếp trong follow_bloc.dart
/// Quản lý hai collection:
///   - following/{currentUserId}/artists/{artistUserId} — ai tôi theo dõi
///   - followers/{artistUserId}/users/{currentUserId} — ai theo dõi nghệ sĩ
class FollowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách ID nghệ sĩ mà user đang theo dõi
  Future<Set<String>> getFollowingIds(String userId) async {
    final snapshot = await _firestore
        .collection('following')
        .doc(userId)
        .collection('artists')
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Theo dõi nghệ sĩ
  Future<void> follow({
    required String currentUid,
    required String artistId,
    required String artistName,
    required String followerName,
  }) async {
    // 1. Thêm vào following/{currentUid}/artists/{artistId}
    await _firestore
        .collection('following')
        .doc(currentUid)
        .collection('artists')
        .doc(artistId)
        .set({
          'artistName': artistName,
          'followedAt': FieldValue.serverTimestamp(),
        });

    // 2. Thêm reverse index: followers/{artistId}/users/{currentUid}
    await _firestore
        .collection('followers')
        .doc(artistId)
        .collection('users')
        .doc(currentUid)
        .set({
          'followerName': followerName,
          'followedAt': FieldValue.serverTimestamp(),
        });

    // 3. Tăng counter
    await _firestore.collection('users').doc(currentUid).update({
      'followingCount': FieldValue.increment(1),
    });
    await _firestore.collection('users').doc(artistId).update({
      'followerCount': FieldValue.increment(1),
    });
  }

  /// Bỏ theo dõi nghệ sĩ
  Future<void> unfollow({
    required String currentUid,
    required String artistId,
  }) async {
    // 1. Xóa khỏi following
    await _firestore
        .collection('following')
        .doc(currentUid)
        .collection('artists')
        .doc(artistId)
        .delete();

    // 2. Xóa reverse index
    await _firestore
        .collection('followers')
        .doc(artistId)
        .collection('users')
        .doc(currentUid)
        .delete();

    // 3. Giảm counter
    await _firestore.collection('users').doc(currentUid).update({
      'followingCount': FieldValue.increment(-1),
    });
    await _firestore.collection('users').doc(artistId).update({
      'followerCount': FieldValue.increment(-1),
    });
  }
}
