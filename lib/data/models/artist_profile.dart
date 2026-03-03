import 'song_model.dart';

/// Model đại diện cho một nghệ sĩ (tài khoản người dùng)
/// Tổng hợp từ danh sách bài hát theo userId
class ArtistProfile {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int songCount;

  const ArtistProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.songCount = 0,
  });

  /// Tạo danh sách ArtistProfile từ danh sách Song
  /// Nhóm theo userId, loại bỏ trùng lặp
  static List<ArtistProfile> fromSongs(List<Song> songs) {
    final Map<String, List<Song>> grouped = {};

    for (final song in songs) {
      final uid = song.userId;
      if (uid == null || uid.isEmpty) continue;
      grouped.putIfAbsent(uid, () => []);
      grouped[uid]!.add(song);
    }

    return grouped.entries.map((entry) {
      final userSongs = entry.value;
      final firstSong = userSongs.first;
      return ArtistProfile(
        userId: entry.key,
        displayName: firstSong.uploaderName ?? firstSong.artist,
        avatarUrl: firstSong.coverUrl,
        songCount: userSongs.length,
      );
    }).toList();
  }
}
