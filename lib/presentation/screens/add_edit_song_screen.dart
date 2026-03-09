import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/song_model.dart';
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
    final currentUser = FirebaseAuth.instance.currentUser;

    // Fallback: nếu displayName null → dùng phần trước @ của email
    final fallbackName =
        currentUser?.displayName ??
        currentUser?.email?.split('@').first ??
        'Người dùng';

    final song = Song(
      id: widget.song?.id,
      title: _titleController.text,
      artist: _artistController.text,
      lyrics: _lyricsController.text,
      audioUrl: _audioUrlController.text,
      userId: widget.song?.userId ?? currentUser?.uid,
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

    // Đợi SongBloc xử lý xong insert/update rồi mới reload danh sách
    Future.delayed(const Duration(milliseconds: 500), () {
      songListBloc.add(sle.LoadSongs());
    });
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
          key: _formKey,
          child: ListView(
            children: [
              // --- LINK ẢNH BÌA ---
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(
                  labelText: "Link ảnh bìa (URL)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: "Dán link ảnh vào đây",
                ),
              ),
              const SizedBox(height: 16),

              // --- TÊN BÀI HÁT ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Tên bài hát (*)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.audio_file),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tên bài hát";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- CA SĨ ---
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

              // --- LINK NHẠC ---
              TextFormField(
                controller: _audioUrlController,
                decoration: const InputDecoration(
                  labelText: "Link nhạc (MP3 URL) (*)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: "Dán link .mp3 vào đây",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập link nhạc";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- LỜI BÀI HÁT ---
              TextFormField(
                controller: _lyricsController,
                decoration: const InputDecoration(
                  labelText: "Lời bài hát",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
              ),
              const SizedBox(height: 24),

              // --- NÚT LƯU ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveSong,
                  child: Text(
                    isEditing ? "CẬP NHẬT" : "LƯU BÀI HÁT",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
