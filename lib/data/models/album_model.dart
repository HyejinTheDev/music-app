import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một Album nhạc
/// Tách từ dữ liệu Map trong add_album_screen.dart và home_screen.dart
class Album {
  final String? id; // Firestore document ID
  final String title;
  final String artist;
  final String? userId;
  final String coverUrl;
  final List<String> songIds;
  final Timestamp? createdAt;

  const Album({
    this.id,
    required this.title,
    required this.artist,
    this.userId,
    required this.coverUrl,
    this.songIds = const [],
    this.createdAt,
  });

  /// Tạo Album từ Firestore document
  factory Album.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Album(
      id: doc.id,
      title: data['title'] ?? 'Không tên',
      artist: data['artist'] ?? 'Nghệ sĩ',
      userId: data['userId'],
      coverUrl: data['coverUrl'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// Chuyển Album thành Map để ghi vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'userId': userId,
      'coverUrl': coverUrl,
      'songIds': songIds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// URL ảnh bìa mặc định nếu người dùng không nhập
  static const String defaultCoverUrl =
      'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=500&auto=format&fit=crop';

  /// Lấy coverUrl hiệu quả — dùng ảnh mặc định nếu trống
  String get effectiveCoverUrl {
    return coverUrl.isNotEmpty ? coverUrl : defaultCoverUrl;
  }
}
