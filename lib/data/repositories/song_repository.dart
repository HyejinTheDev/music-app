import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/song_model.dart';

// --- QUAN TRỌNG: Dòng này kết nối tới file ở Bước 1 ---
// Dấu .. nghĩa là "thát ra ngoài thư mục repositories"
// Vào thư mục dataproviders -> tìm file db_helper.dart
import '../dataproviders/db_helper.dart';

class SongRepository {
  // Bây giờ dòng này sẽ hết báo lỗi đỏ
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref("songs");

  Future<List<Song>> getLocalSongs() => _dbHelper.getSongs();
  Future<int> addSong(Song song) => _dbHelper.insertSong(song);
  Future<int> updateSong(Song song) => _dbHelper.updateSong(song);
  Future<int> deleteSong(int id) => _dbHelper.deleteSong(id);

  // Sync to Cloud
  Future<void> syncToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    List<Song> localSongs = await _dbHelper.getSongs();
    for (var song in localSongs) {
      if (song.id != null) {
        await _firebaseRef
            .child(user.uid)
            .child(song.id.toString())
            .set(song.toMap());
      }
    }
  }

  // Sync from Cloud
  Future<void> syncFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await _firebaseRef.child(user.uid).get();
    if (snapshot.exists) {
      await _dbHelper.deleteAll();
      for (final child in snapshot.children) {
        if (child.value != null) {
          final data = Map<String, dynamic>.from(child.value as Map);
          final song = Song.fromMap(data);
          await _dbHelper.insertSong(song);
        }
      }
    }
  }
}
