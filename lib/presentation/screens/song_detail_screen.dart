import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final AudioPlayer player;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const SongDetailScreen({
    Key? key,
    required this.song,
    required this.player,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    widget.player.playerStateStream.listen((state) {
      if (mounted) {
        if (state.playing) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant SongDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() => _isFavorite = widget.isFavorite);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Đang phát",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- ĐĨA THAN XOAY TRÒN ---
            Center(
              child: RotationTransition(
                turns: _animationController,
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
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          widget.song.coverUrl,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 15),
                        ),
                      ),
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF121212),
                          border: Border.all(color: Colors.white38, width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // --- THÔNG TIN BÀI HÁT + NÚT YÊU THÍCH ĐỒNG BỘ ---
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.song.artist,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Nút thả tim — đồng bộ với HomeScreen
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      widget.onToggleFavorite();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- THANH TRƯỢT THỜI GIAN (SEEK BAR) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder<Duration?>(
                stream: widget.player.durationStream,
                builder: (context, durationSnapshot) {
                  final totalDuration = durationSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: widget.player.positionStream,
                    builder: (context, positionSnapshot) {
                      final currentPosition =
                          positionSnapshot.data ?? Duration.zero;
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.tealAccent,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.tealAccent,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              trackHeight: 3,
                            ),
                            child: Slider(
                              min: 0,
                              max: totalDuration.inMilliseconds
                                  .toDouble()
                                  .clamp(1, double.infinity),
                              value: currentPosition.inMilliseconds
                                  .toDouble()
                                  .clamp(
                                    0,
                                    totalDuration.inMilliseconds
                                        .toDouble()
                                        .clamp(1, double.infinity),
                                  ),
                              onChanged: (value) {
                                widget.player.seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(currentPosition),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(totalDuration),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // --- THANH ĐIỀU KHIỂN PLAY/PAUSE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white54),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {},
                  ),

                  StreamBuilder<PlayerState>(
                    stream: widget.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.tealAccent,
                        ),
                        child: IconButton(
                          iconSize: 50,
                          icon: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                          ),
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

                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.white54),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
