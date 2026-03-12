import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/song_bloc/song_bloc.dart';
import '../../logic/song_bloc/song_event.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart' as sle;

class AddEditSongScreen extends StatefulWidget {
  final Song? song;
  const AddEditSongScreen({super.key, this.song});

  @override
  State<AddEditSongScreen> createState() => _AddEditSongScreenState();
}

class _AddEditSongScreenState extends State<AddEditSongScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _lyricsController;
  late TextEditingController _audioUrlController;
  late TextEditingController _coverUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _lyricsController = TextEditingController(text: widget.song?.lyrics ?? '');
    _audioUrlController = TextEditingController(
      text: widget.song?.audioUrl ?? '',
    );
    _coverUrlController = TextEditingController(
      text: widget.song?.coverImageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _lyricsController.dispose();
    _audioUrlController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  void _saveSong() {
    if (!_formKey.currentState!.validate()) return;

    final coverUrl = _coverUrlController.text.trim();
    final authRepo = context.read<AuthRepository>();

    final fallbackName =
        authRepo.currentUserDisplayName ??
        authRepo.currentUserEmail?.split('@').first ??
        'Người dùng';

    final song = Song(
      id: widget.song?.id,
      title: _titleController.text,
      artist: _artistController.text,
      lyrics: _lyricsController.text,
      audioUrl: _audioUrlController.text,
      userId: widget.song?.userId ?? authRepo.currentUserId,
      uploaderName: widget.song?.uploaderName ?? fallbackName,
      coverImageUrl: coverUrl.isNotEmpty ? coverUrl : null,
    );

    final isEditing = widget.song != null;
    final songBloc = context.read<SongBloc>();
    final songListBloc = context.read<SongListBloc>();

    if (isEditing) {
      songBloc.add(UpdateSongEvent(song));
    } else {
      songBloc.add(AddSongEvent(song));
    }

    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 500), () {
      songListBloc.add(sle.LoadSongs());
    });
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.tealAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.song != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? "Sửa Bài Hát" : "Thêm Bài Hát Mới",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ảnh bìa preview (nếu có URL)
              ValueListenableBuilder(
                valueListenable: _coverUrlController,
                builder: (context, value, _) {
                  final url = value.text.trim();
                  if (url.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey[900],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.white24,
                                size: 40,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Không tải được ảnh",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Link ảnh bìa
              TextFormField(
                controller: _coverUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: "Link ảnh bìa (URL)",
                  icon: Icons.image_outlined,
                  hint: "Dán link ảnh vào đây",
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null ||
                        !uri.hasScheme ||
                        (!uri.isScheme('http') && !uri.isScheme('https'))) {
                      return "Link ảnh không hợp lệ";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Tên bài hát
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: _inputDecoration(
                  label: "Tên bài hát *",
                  icon: Icons.music_note_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên bài hát";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Ca sĩ
              TextFormField(
                controller: _artistController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: _inputDecoration(
                  label: "Ca sĩ *",
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên ca sĩ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Link nhạc
              TextFormField(
                controller: _audioUrlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: "Link nhạc (MP3 URL) *",
                  icon: Icons.link,
                  hint: "Dán link .mp3 vào đây",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập link nhạc";
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null ||
                      !uri.hasScheme ||
                      (!uri.isScheme('http') && !uri.isScheme('https'))) {
                    return "Link nhạc không hợp lệ";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Lời bài hát
              TextFormField(
                controller: _lyricsController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Lời bài hát",
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.tealAccent),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 6,
              ),
              const SizedBox(height: 28),

              // Nút Lưu
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveSong,
                  child: Text(
                    isEditing ? "CẬP NHẬT" : "LƯU BÀI HÁT",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
