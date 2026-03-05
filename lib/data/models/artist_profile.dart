import 'package:cloud_firestore/cloud_firestore.dart';
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
  /// Lấy ảnh đại diện từ Firestore (users/{uid}/photoUrl)
  static Future<List<ArtistProfile>> fromSongs(List<Song> songs) async {
    final Map<String, List<Song>> grouped = {};

    for (final song in songs) {
      final uid = song.userId;
      if (uid == null || uid.isEmpty) continue;
      grouped.putIfAbsent(uid, () => []);
      grouped[uid]!.add(song);
    }

    final firestore = FirebaseFirestore.instance;
    final List<ArtistProfile> artists = [];

    for (final entry in grouped.entries) {
      final userSongs = entry.value;
      final firstSong = userSongs.first;

      // Lấy photoUrl từ Firestore
      String? photoUrl;
      try {
        final doc = await firestore.collection('users').doc(entry.key).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          photoUrl = data['photoUrl'];
        }
      } catch (_) {}

      artists.add(
        ArtistProfile(
          userId: entry.key,
          displayName: firstSong.uploaderName ?? firstSong.artist,
          avatarUrl: photoUrl,
          songCount: userSongs.length,
        ),
      );
    }

    return artists;
  }
}
