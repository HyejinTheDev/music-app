import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song_model.dart';

/// Helper class đóng gói tất cả thao tác SQLite
/// Version 5: thêm bảng favorites và history cho persistence
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'music_app.db');
    return await openDatabase(
      path,
      version: 5, // Version 5: thêm bảng favorites và history
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE songs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            artist TEXT,
            lyrics TEXT,
            audio_url TEXT,
            user_id TEXT,
            uploader_name TEXT,
            cover_image_url TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites(
            song_id INTEGER PRIMARY KEY,
            song_json TEXT NOT NULL,
            added_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE history(
            song_id INTEGER PRIMARY KEY,
            song_json TEXT NOT NULL,
            played_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE songs ADD COLUMN user_id TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE songs ADD COLUMN uploader_name TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE songs ADD COLUMN cover_image_url TEXT');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorites(
              song_id INTEGER PRIMARY KEY,
              song_json TEXT NOT NULL,
              added_at INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS history(
              song_id INTEGER PRIMARY KEY,
              song_json TEXT NOT NULL,
              played_at INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  // ========================
  // SONGS
  // ========================

  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert('songs', song.toMap());
  }

  Future<List<Song>> getSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      orderBy: "id DESC",
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<int> updateSong(Song song) async {
    final db = await database;
    return await db.update(
      'songs',
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('songs');
  }

  /// Cập nhật uploader_name cho tất cả bài hát của user
  Future<void> updateUploaderName(String userId, String newName) async {
    final db = await database;
    await db.update(
      'songs',
      {'uploader_name': newName},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ========================
  // FAVORITES — lưu bài hát yêu thích vào SQLite
  // ========================

  /// Thêm bài hát vào danh sách yêu thích
  Future<void> insertFavorite(Song song) async {
    final db = await database;
    await db.insert('favorites', {
      'song_id': song.id,
      'song_json': song.toJson(),
      'added_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Xóa bài hát khỏi danh sách yêu thích
  Future<void> removeFavorite(int songId) async {
    final db = await database;
    await db.delete('favorites', where: 'song_id = ?', whereArgs: [songId]);
  }

  /// Lấy tất cả bài hát yêu thích (mới nhất trước)
  Future<List<Song>> getFavorites() async {
    final db = await database;
    final maps = await db.query('favorites', orderBy: 'added_at DESC');
    return maps.map((m) => Song.fromJson(m['song_json'] as String)).toList();
  }

  /// Kiểm tra bài hát có trong favorites không
  Future<bool> isFavorite(int songId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    return result.isNotEmpty;
  }

  // ========================
  // HISTORY — lưu lịch sử nghe nhạc vào SQLite
  // ========================

  /// Thêm bài hát vào lịch sử (replace nếu đã tồn tại)
  Future<void> insertHistory(Song song) async {
    final db = await database;
    await db.insert('history', {
      'song_id': song.id,
      'song_json': song.toJson(),
      'played_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Lấy lịch sử nghe nhạc (mới nhất trước)
  Future<List<Song>> getHistory() async {
    final db = await database;
    final maps = await db.query('history', orderBy: 'played_at DESC');
    return maps.map((m) => Song.fromJson(m['song_json'] as String)).toList();
  }

  /// Xóa toàn bộ lịch sử
  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}
