import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album_model.dart';

/// Repository đóng gói tất cả Firestore calls cho Albums
/// Tách từ logic trực tiếp trong add_album_screen.dart và home_screen.dart
class AlbumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream danh sách albums (real-time, sắp xếp theo ngày tạo)
  Stream<QuerySnapshot> getAlbumsStream() {
    return _firestore
        .collection('albums')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Tạo album mới
  Future<void> createAlbum(Album album) async {
    await _firestore.collection('albums').add(album.toMap());
  }

  /// Xóa album
  Future<void> deleteAlbum(String docId) async {
    await _firestore.collection('albums').doc(docId).delete();
  }

  /// Cập nhật album
  Future<void> updateAlbum(String docId, Album album) async {
    await _firestore.collection('albums').doc(docId).update(album.toMap());
  }

  /// Lấy album theo ID
  Future<Album?> getAlbumById(String docId) async {
    final doc = await _firestore.collection('albums').doc(docId).get();
    if (doc.exists) {
      return Album.fromFirestore(doc);
    }
    return null;
  }
}
