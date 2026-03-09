import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/song_model.dart';
import '../dataproviders/db_helper.dart';

/// Repository đóng gói tất cả thao tác dữ liệu cho Songs
/// Sử dụng SQLite (qua DatabaseHelper) cho local storage
/// và Firebase Realtime Database cho cloud sync
class SongRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref("songs");

  // ========================
  // LOCAL (SQLite) CRUD
  // ========================

  Future<List<Song>> getLocalSongs() => _dbHelper.getSongs();
  Future<int> addSong(Song song) => _dbHelper.insertSong(song);
  Future<int> updateSong(Song song) => _dbHelper.updateSong(song);
  Future<int> deleteSong(int id) => _dbHelper.deleteSong(id);

  /// Xóa bài hát khỏi Firebase Realtime Database
  Future<void> deleteFromCloud(int id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseRef.child(user.uid).child(id.toString()).remove();
    debugPrint('[DeleteFromCloud] ✅ Đã xóa bài hát id=$id khỏi cloud');
  }

  // ========================
  // CLOUD SYNC
  // ========================

  /// Sync bài hát CỦA USER HIỆN TẠI lên Firebase Realtime Database
  /// Chỉ push bài hát có user_id trùng với UID hiện tại
  Future<void> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[SyncToCloud] ❌ Chưa đăng nhập');
        return;
      }

      List<Song> localSongs = await _dbHelper.getSongs();

      // Chỉ push bài hát của CHÍNH user hiện tại
      final mySongs = localSongs.where((s) => s.userId == user.uid).toList();
      debugPrint(
        '[SyncToCloud] 📤 Đang sync ${mySongs.length}/${localSongs.length} bài hát (của mình) lên cloud...',
      );

      // ★ LUÔN xóa node cũ trên Firebase TRƯỚC (kể cả khi không còn bài nào)
      await _firebaseRef.child(user.uid).remove();

      if (mySongs.isEmpty) {
        debugPrint(
          '[SyncToCloud] ⚠️ Không có bài hát nào của mình để sync — đã xóa sạch trên cloud',
        );
        return;
      }

      for (var song in mySongs) {
        if (song.id != null) {
          final songData = song.toMap();
          debugPrint(
            '[SyncToCloud] → Đang push: ${song.title} (id=${song.id})',
          );
          await _firebaseRef
              .child(user.uid)
              .child(song.id.toString())
              .set(songData);
        }
      }

      debugPrint('[SyncToCloud] ✅ Sync thành công ${mySongs.length} bài hát!');
    } catch (e, stackTrace) {
      debugPrint('[SyncToCloud] ❌ LỖI: $e');
      debugPrint('[SyncToCloud] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Sync bài hát từ Firebase về local SQLite
  /// Luôn chạy SAU syncToCloud để local data đã có trên cloud
  /// deleteAll + re-import: đảm bảo thấy bài hát của TẤT CẢ user
  Future<void> syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[SyncFromCloud] ❌ Chưa đăng nhập');
        return;
      }

      debugPrint('[SyncFromCloud] 📥 Đang kéo bài hát từ cloud...');

      final snapshot = await _firebaseRef.get();

      debugPrint('[SyncFromCloud] snapshot.exists = ${snapshot.exists}');

      if (snapshot.exists && snapshot.value != null) {
        // Xóa local → re-import từ cloud (an toàn vì syncToCloud chạy trước)
        await _dbHelper.deleteAll();
        int count = 0;

        final allData = Map<String, dynamic>.from(snapshot.value as Map);

        for (final userId in allData.keys) {
          final userSongs = allData[userId];
          if (userSongs is Map) {
            final songsMap = Map<String, dynamic>.from(userSongs);
            for (final songId in songsMap.keys) {
              try {
                final songData = Map<String, dynamic>.from(
                  songsMap[songId] as Map,
                );

                // ★ Xóa 'id' gốc để SQLite tự gán ID mới (tránh xung đột)
                songData.remove('id');

                // ★ Đảm bảo user_id luôn được set từ path Firebase
                songData['user_id'] ??= userId;

                // ★ Bỏ qua bài hát bị nhân bản (user_id trong data ≠ userId trên path)
                // Đây là rác từ bug syncToCloud cũ đã push tất cả bài dưới mọi user
                if (songData['user_id'] != userId) {
                  debugPrint(
                    '[SyncFromCloud] 🗑️ Bỏ qua bản sao rác: $songId (user_id=${songData['user_id']} ≠ path=$userId)',
                  );
                  continue;
                }

                final song = Song.fromMap(songData);
                await _dbHelper.insertSong(song);
                count++;
              } catch (e) {
                debugPrint('[SyncFromCloud] ⚠️ Bỏ qua: $songId - $e');
              }
            }
          }
        }

        debugPrint('[SyncFromCloud] ✅ Đã kéo về $count bài hát từ tất cả user');
      } else {
        debugPrint('[SyncFromCloud] ⚠️ Firebase trống');
      }
    } catch (e, stackTrace) {
      debugPrint('[SyncFromCloud] ❌ LỖI: $e');
      debugPrint('[SyncFromCloud] StackTrace: $stackTrace');
    }
  }

  /// Cập nhật uploader_name cho tất cả bài hát của user
  /// Delegate sang DatabaseHelper thay vì truy cập DB trực tiếp
  Future<void> updateUploaderName(String userId, String newName) async {
    await _dbHelper.updateUploaderName(userId, newName);
  }
}
