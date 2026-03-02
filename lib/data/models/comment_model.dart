import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một bình luận trong bài viết
/// Tách từ class Comment cũ trong feed_screen.dart
class Comment {
  final String? id; // Firestore document ID
  final String userName;
  final String text;
  final String timeAgo;
  final Timestamp? timestamp;

  const Comment({
    this.id,
    required this.userName,
    required this.text,
    this.timeAgo = '',
    this.timestamp,
  });

  /// Tạo Comment từ Firestore document
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userName: data['userName'] ?? 'Ẩn danh',
      text: data['text'] ?? '',
      timeAgo: data['timeAgo'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  /// Chuyển Comment thành Map để ghi vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'text': text,
      'timeAgo': timeAgo,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
