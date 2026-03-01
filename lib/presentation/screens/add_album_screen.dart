import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Đã xóa import file_picker và firebase_storage
import '../../data/models/song_model.dart';
import '../../data/dataproviders/db_helper.dart';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({Key? key}) : super(key: key);

  @override
  State<AddAlbumScreen> createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
  final _titleController = TextEditingController();
  final _coverUrlController = TextEditingController(); // <--- Dùng để nhập link ảnh

  bool _isUploading = false;
  bool _isLoadingSongs = true;

  // Danh sách chứa ID của các bài hát được người dùng tick chọn
  final List<String> _selectedSongIds = [];

  // Danh sách bài hát từ SQLite local
  List<Song> _localSongs = [];

  // Lấy thông tin người dùng hiện tại
  final user = FirebaseAuth.instance.currentUser;
  late String currentUserName;

  @override
  void initState() {
    super.initState();
    currentUserName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Nghệ sĩ ẩn danh';
    _loadLocalSongs(); // Tải bài hát từ SQLite
  }

  // --- ĐỌC BÀI HÁT TỪ SQLITE LOCAL, CHỈ LẤY BÀI CỦA MÌNH ---
  Future<void> _loadLocalSongs() async {
    try {
      final allSongs = await DatabaseHelper().getSongs();
      final currentUid = user?.uid;
      if (mounted) {
        setState(() {
          // Chỉ lấy bài hát do chính tài khoản này đăng
          _localSongs = allSongs.where((song) => song.userId == currentUid).toList();
          _isLoadingSongs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSongs = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tạo Album Mới",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tên Album
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                labelText: "Tên Album (*)",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
                prefixIcon: Icon(Icons.album, color: Colors.tealAccent),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Link Ảnh bìa (Thay thế cho Upload File)
            TextFormField(
              controller: _coverUrlController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: "Link ảnh bìa (Tùy chọn)",
                hintText: "Dán link ảnh (https://...) vào đây",
                hintStyle: TextStyle(color: Colors.white24),
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
                prefixIcon: Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              " * Bỏ trống nếu muốn dùng ảnh bìa mặc định",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),

            // 3. Danh sách nhạc từ SQLite local
            const Text(
              "Chọn bài hát đưa vào Album:",
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: _isLoadingSongs
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      )
                    : _localSongs.isEmpty
                    ? const Center(
                        child: Text(
                          "Bạn chưa tải lên bài hát nào.\nHãy thêm bài hát trước khi tạo Album nhé!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _localSongs.length,
                        itemBuilder: (context, index) {
                          final song = _localSongs[index];
                          final songIdStr = song.id.toString();

                          return CheckboxListTile(
                            activeColor: Colors.tealAccent,
                            checkColor: Colors.black,
                            side: const BorderSide(color: Colors.white54),
                            secondary: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                song.coverUrl,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                                // Xử lý lỗi nếu URL ảnh bị hỏng
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 45,
                                  height: 45,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note, color: Colors.white54),
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            value: _selectedSongIds.contains(songIdStr),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedSongIds.add(songIdStr);
                                } else {
                                  _selectedSongIds.remove(songIdStr);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Nút LƯU ALBUM (Không dùng Storage)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isUploading
                    ? null
                    : () async {
                        if (_titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vui lòng nhập tên Album!"),
                            ),
                          );
                          return;
                        }
                        if (_selectedSongIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vui lòng chọn ít nhất 1 bài hát!"),
                            ),
                          );
                          return;
                        }

                        setState(() => _isUploading = true);

                        try {
                          // Nếu ô nhập link ảnh trống, lấy ảnh đĩa than nhạc mặc định
                          String finalCoverUrl = _coverUrlController.text.trim();
                          if (finalCoverUrl.isEmpty) {
                            finalCoverUrl = "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=500&auto=format&fit=crop"; 
                          }

                          // Lưu thông tin Album vào Firestore collection 'albums'
                          await FirebaseFirestore.instance
                              .collection('albums')
                              .add({
                                'title': _titleController.text.trim(),
                                'artist': currentUserName,
                                'userId': user?.uid,
                                'coverUrl': finalCoverUrl,
                                'songIds': _selectedSongIds,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Đã tạo Album thành công!",
                                  style: TextStyle(color: Colors.tealAccent),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Lỗi tạo Album: $e")),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isUploading = false);
                          }
                        }
                      },
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "TẠO ALBUM",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}