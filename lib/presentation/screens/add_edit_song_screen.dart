import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import '../../logic/song_bloc/song_bloc.dart';
import '../../logic/song_bloc/song_event.dart';

class AddEditSongScreen extends StatefulWidget {
  final Song? song; // Nếu có song truyền vào thì là Sửa, nếu null thì là Thêm
  const AddEditSongScreen({super.key, this.song});

  @override
  State<AddEditSongScreen> createState() => _AddEditSongScreenState();
}

class _AddEditSongScreenState extends State<AddEditSongScreen> {
  // Key để quản lý Form và Validate
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _lyricsController;
  late TextEditingController _audioUrlController; // <--- 1. Đã thêm khai báo

  @override
  void initState() {
    super.initState();
    // Khởi tạo Controller, nếu có dữ liệu cũ (Sửa) thì điền vào luôn
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _lyricsController = TextEditingController(text: widget.song?.lyrics ?? '');
    _audioUrlController = TextEditingController(text: widget.song?.audioUrl ?? ''); // <--- 2. Đã thêm khởi tạo
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _lyricsController.dispose();
    _audioUrlController.dispose(); // <--- 3. Đã thêm dispose (giải phóng bộ nhớ)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.song != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Sửa Bài Hát" : "Thêm Bài Hát Mới"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Gắn key vào Form
          child: ListView(
            children: [
              // Ô nhập Tên bài hát
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Tên bài hát (*)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.audio_file),
                ),
                // Validate: Không được để trống
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên bài hát";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ô nhập Ca sĩ
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: "Ca sĩ (*)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên ca sĩ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ô nhập Link nhạc (Mới thêm)
              TextFormField(
                controller: _audioUrlController,
                decoration: const InputDecoration(
                  labelText: "Link nhạc (MP3 URL) (*)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: "Dán link .mp3 vào đây"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập link nhạc";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ô nhập Lời bài hát
              TextFormField(
                controller: _lyricsController,
                decoration: const InputDecoration(
                  labelText: "Lời bài hát",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8, // Cho phép nhập nhiều dòng
              ),
              const SizedBox(height: 24),

              // Nút Lưu
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // 1. Kiểm tra Validate
                    if (_formKey.currentState!.validate()) {
                      // 2. Tạo đối tượng Song từ dữ liệu nhập
                      final song = Song(
                        id: widget.song?.id, // Giữ ID cũ nếu là Sửa
                        title: _titleController.text,
                        artist: _artistController.text,
                        lyrics: _lyricsController.text,
                        audioUrl: _audioUrlController.text, // <--- Đã có dữ liệu
                      );

                      // 3. Gửi sự kiện tới BLoC
                      if (isEditing) {
                        context.read<SongBloc>().add(UpdateSongEvent(song));
                      } else {
                        context.read<SongBloc>().add(AddSongEvent(song));
                      }

                      // 4. Quay về màn hình danh sách
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    isEditing ? "CẬP NHẬT" : "LƯU BÀI HÁT",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}