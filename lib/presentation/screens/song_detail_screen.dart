import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  const SongDetailScreen({super.key, required this.song});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.song.audioUrl.isNotEmpty) {
        await _player.setUrl(widget.song.audioUrl); // Load nhạc từ Link
      }
    } catch (e) {
      print("Lỗi tải nhạc: $e");
    }
    
    // Lắng nghe trạng thái để đổi icon Play/Pause
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose(); // Tắt nhạc khi thoát màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.song.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ảnh đĩa nhạc
            const Icon(Icons.music_note, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            
            Text(widget.song.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.song.artist, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),

            // Nút điều khiển
            IconButton(
              iconSize: 80,
              color: Colors.blue,
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              onPressed: () {
                if (_isPlaying) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
            ),
            
            const SizedBox(height: 20),
            const Text("Lời bài hát:", style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.song.lyrics, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}