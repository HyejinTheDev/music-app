import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một thông báo
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? artistId;
  final String? artistName;
  final String? songId;
  final String? postId;
  final String? postCaption;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.artistId,
    this.artistName,
    this.songId,
    this.postId,
    this.postCaption,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      artistId: artistId,
      artistName: artistName,
      songId: songId,
      postId: postId,
      postCaption: postCaption,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Tạo từ Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.system,
      ),
      artistId: data['artistId'],
      artistName: data['artistName'],
      songId: data['songId']?.toString(),
      postId: data['postId'],
      postCaption: data['postCaption'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  /// Chuyển thành Map để ghi vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.name,
      'artistId': artistId,
      'artistName': artistName,
      'songId': songId,
      'postId': postId,
      'postCaption': postCaption,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

/// Loại thông báo
enum NotificationType {
  newSong, // Nghệ sĩ bạn theo dõi đăng bài hát mới
  newPost, // Nghệ sĩ bạn theo dõi đăng bài viết trên feed
  like, // Ai đó thích bài viết của bạn
  comment, // Ai đó bình luận bài viết của bạn
  follow, // Có người theo dõi bạn
  system, // Thông báo hệ thống
}
