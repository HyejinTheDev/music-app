class Song {
  final int? id;
  final String title;
  final String artist;
  final String lyrics;
  final String audioUrl;
  final String? userId; // UID của người đăng bài hát

  Song({
    this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.audioUrl,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'lyrics': lyrics,
      'audio_url': audioUrl,
      'user_id': userId,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      lyrics: map['lyrics'],
      audioUrl: map['audio_url'] ?? '',
      userId: map['user_id'],
    );
  }

  String get coverUrl {
    final seed = id ?? 1;
    return "https://picsum.photos/seed/$seed/200/200";
  }
}
