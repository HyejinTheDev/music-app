import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một bình luận trong bài viết
/// Tách từ class Comment cũ trong feed_screen.dart
class Comment {
  final String? id; // Firestore document ID
  final String userName;
  final String text;
  final Timestamp? timestamp;

  const Comment({
    this.id,
    required this.userName,
    required this.text,
    this.timestamp,
  });

  /// Tạo Comment từ Firestore document
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userName: data['userName'] ?? 'Ẩn danh',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  /// Chuyển Comment thành Map để ghi vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'text': text,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  /// Tính thời gian tương đối từ timestamp
  /// Trả về chuỗi như "Vừa xong", "5 phút trước", "2 giờ trước"
  String get timeAgo {
    if (timestamp == null) return 'Vừa xong';
    final dateTime = timestamp!.toDate();
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
