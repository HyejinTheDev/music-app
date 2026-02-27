import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final AudioPlayer player; // Nhận máy phát nhạc từ bên ngoài vào

  const SongDetailScreen({
    Key? key,
    required this.song,
    required this.player,
  }) : super(key: key);

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

// Bắt buộc phải có SingleTickerProviderStateMixin để làm Animation
class _SongDetailScreenState extends State<SongDetailScreen> with SingleTickerProviderStateMixin {
  // Biến điều khiển chuyển động xoay
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    // Cài đặt bộ xoay: 1 vòng quay mất 15 giây
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Lắng nghe trạng thái của máy phát nhạc
    widget.player.playerStateStream.listen((state) {
      if (mounted) {
        if (state.playing) {
          _animationController.repeat(); // Nếu đang phát -> Quay liên tục
        } else {
          _animationController.stop();   // Nếu tạm dừng -> Đứng im
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Nhớ dọn dẹp bộ nhớ khi tắt màn hình
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Màu nền tối chữ đạo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context), // Vuốt xuống hoặc bấm để tắt
        ),
        title: const Text("Đang phát", style: TextStyle(color: Colors.white70, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- TRUNG TÂM: ĐĨA THAN XOAY TRÒN ---
            Center(
              child: RotationTransition(
                turns: _animationController, // Cắm biến điều khiển xoay vào đây
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Ảnh bìa bài hát bo tròn
                      ClipOval(
                        child: Image.network(
                          widget.song.coverUrl,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 2. Viền đen bên ngoài giả làm đĩa Vinyl
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 15),
                        ),
                      ),
                      // 3. Cái lỗ nhỏ ở giữa đĩa than
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF121212), // Tiệp màu nền
                          border: Border.all(color: Colors.white38, width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // --- THÔNG TIN BÀI HÁT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.song.title,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.song.artist,
                          style: const TextStyle(color: Colors.white54, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Nút thả tim (Có thể code logic SQLite vào đây sau)
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- THANH ĐIỀU KHIỂN PLAY/PAUSE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.shuffle, color: Colors.white54), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40), onPressed: () {}),
                  
                  // Nút Play/Pause tự động cập nhật
                  StreamBuilder<PlayerState>(
                    stream: widget.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.tealAccent),
                        child: IconButton(
                          iconSize: 50,
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.black),
                          onPressed: () {
                            if (playing) {
                              widget.player.pause();
                            } else {
                              widget.player.play();
                            }
                          },
                        ),
                      );
                    },
                  ),

                  IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 40), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.repeat, color: Colors.white54), onPressed: () {}),
                ],
              ),
            ),
            
            const SizedBox(height: 50), // Khoảng trống dưới đáy
          ],
        ),
      ),
    );
  }
}