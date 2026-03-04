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

  // ========================
  // CLOUD SYNC
  // ========================

  /// Sync tất cả bài hát local lên Firebase Realtime Database
  Future<void> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[SyncToCloud] ❌ Chưa đăng nhập');
        return;
      }

      List<Song> localSongs = await _dbHelper.getSongs();
      debugPrint(
        '[SyncToCloud] 📤 Đang sync ${localSongs.length} bài hát lên cloud...',
      );

      if (localSongs.isEmpty) {
        debugPrint('[SyncToCloud] ⚠️ Không có bài hát local nào để sync');
        return;
      }

      for (var song in localSongs) {
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

      debugPrint(
        '[SyncToCloud] ✅ Sync thành công ${localSongs.length} bài hát!',
      );
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
