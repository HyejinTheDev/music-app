class Song {
  final int? id;
  final String title;
  final String artist;
  final String lyrics;
  final String audioUrl;
  final String? userId; // UID của người đăng bài hát
  final String? uploaderName; // Tên hiển thị của người đăng
  final String? coverImageUrl; // URL ảnh bìa do user upload

  Song({
    this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.audioUrl,
    this.userId,
    this.uploaderName,
    this.coverImageUrl,
  });

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
      title: map['title'],
      artist: map['artist'],
      lyrics: map['lyrics'],
      audioUrl: map['audio_url'] ?? '',
      userId: map['user_id'],
      uploaderName: map['uploader_name'],
      coverImageUrl: map['cover_image_url'],
    );
  }

  /// Nếu có ảnh bìa do user upload thì dùng, không thì dùng ảnh mặc định
  String get coverUrl {
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      return coverImageUrl!;
    }
    final seed = id ?? 1;
    return "https://picsum.photos/seed/$seed/200/200";
  }
}
