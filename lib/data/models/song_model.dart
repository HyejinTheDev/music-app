class Song {
  final int? id;
  final String title;
  final String artist;
  final String lyrics;
  final String audioUrl; // <--- THÊM DÒNG NÀY

  Song({
    this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
    required this.audioUrl, // <--- THÊM DÒNG NÀY
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'lyrics': lyrics,
      'audio_url': audioUrl, // <--- THÊM DÒNG NÀY
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      lyrics: map['lyrics'],
      audioUrl: map['audio_url'] ?? '', // <--- THÊM (Nếu null thì để rỗng)
    );
  }
}