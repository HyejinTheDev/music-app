import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Model đại diện cho một bài hát
/// Sử dụng Equatable để BLoC state comparison chính xác
class Song extends Equatable {
  final int? id;
  final String title;
  final String artist;
  final String lyrics;
  final String audioUrl;
  final String? userId; // UID của người đăng bài hát
  final String? uploaderName; // Tên hiển thị của người đăng
  final String? coverImageUrl; // URL ảnh bìa do user upload

  const Song({
    this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.audioUrl,
    this.userId,
    this.uploaderName,
    this.coverImageUrl,
  });

  /// Tạo bản copy với các giá trị mới (immutable pattern)
  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? lyrics,
    String? audioUrl,
    String? userId,
    String? uploaderName,
    String? coverImageUrl,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      lyrics: lyrics ?? this.lyrics,
      audioUrl: audioUrl ?? this.audioUrl,
      userId: userId ?? this.userId,
      uploaderName: uploaderName ?? this.uploaderName,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }

  /// Chuyển thành Map cho SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'artist': artist,
      'lyrics': lyrics,
      'audio_url': audioUrl,
      'user_id': userId,
      'uploader_name': uploaderName,
      'cover_image_url': coverImageUrl,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      lyrics: map['lyrics'] ?? '',
      audioUrl: map['audio_url'] ?? '',
      userId: map['user_id'],
      uploaderName: map['uploader_name'],
      coverImageUrl: map['cover_image_url'],
    );
  }

  /// Serialize thành JSON string (dùng để lưu vào SQLite favorites/history)
  String toJson() => jsonEncode(toMap());

  /// Deserialize từ JSON string
  factory Song.fromJson(String jsonStr) {
    return Song.fromMap(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  /// Nếu có ảnh bìa do user upload thì dùng, không thì dùng ảnh mặc định
  String get coverUrl {
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      return coverImageUrl!;
    }
    final seed = id ?? 1;
    return "https://picsum.photos/seed/$seed/200/200";
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    lyrics,
    audioUrl,
    userId,
    uploaderName,
    coverImageUrl,
  ];
}
