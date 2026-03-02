import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/song_model.dart';
import '../../data/dataproviders/db_helper.dart';
import '../../logic/album/album_bloc.dart';
import '../../logic/album/album_event.dart';
import '../../logic/album/album_state.dart';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({Key? key}) : super(key: key);

  @override
  State<AddAlbumScreen> createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
  final _titleController = TextEditingController();
  final _coverUrlController = TextEditingController();

  bool _isLoadingSongs = true;
  final List<String> _selectedSongIds = [];
  List<Song> _localSongs = [];

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadLocalSongs();
  }

  Future<void> _loadLocalSongs() async {
    try {
      final allSongs = await DatabaseHelper().getSongs();
      final currentUid = user?.uid;
      if (mounted) {
        setState(() {
          _localSongs = allSongs
              .where((song) => song.userId == currentUid)
              .toList();
          _isLoadingSongs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSongs = false);
      }
    }
  }

  void _createAlbum() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên Album!")));
      return;
    }
    if (_selectedSongIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ít nhất 1 bài hát!")),
      );
      return;
    }

    // Gửi event cho AlbumBloc thay vì gọi Firestore trực tiếp
    context.read<AlbumBloc>().add(
      CreateAlbum(
        title: _titleController.text.trim(),
        coverUrl: _coverUrlController.text.trim(),
        songIds: List.from(_selectedSongIds),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlbumBloc, AlbumState>(
      listener: (context, state) {
        if (state is AlbumCreateSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.tealAccent),
              ),
            ),
          );
        } else if (state is AlbumError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
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

              // 2. Link Ảnh bìa
              TextFormField(
                controller: _coverUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: "Link ảnh bìa (Tùy chọn)",
                  hintText: "Dán link ảnh (https://...) vào đây",
                  hintStyle: TextStyle(color: Colors.white24),
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.tealAccent),
                  ),
                  prefixIcon: Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                " * Bỏ trống nếu muốn dùng ảnh bìa mặc định",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 45,
                                        height: 45,
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.music_note,
                                          color: Colors.white54,
                                        ),
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

              // 4. Nút TẠO ALBUM — dùng BlocBuilder cho trạng thái loading
              BlocBuilder<AlbumBloc, AlbumState>(
                builder: (context, state) {
                  final isCreating = state is AlbumCreating;
                  return SizedBox(
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
                      onPressed: isCreating ? null : _createAlbum,
                      child: isCreating
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "TẠO ALBUM",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
