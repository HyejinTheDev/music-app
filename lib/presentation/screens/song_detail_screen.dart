import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';
import '../../logic/player/player_state.dart' as ps;
import '../../logic/favorites/favorites_bloc.dart';
import '../../logic/favorites/favorites_event.dart';
import '../../logic/favorites/favorites_state.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final AudioPlayer player;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final List<Song> songs;
  final Function(Song)? onSongChanged;

  const SongDetailScreen({
    Key? key,
    required this.song,
    required this.player,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.songs = const [],
    this.onSongChanged,
  }) : super(key: key);

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

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
    return BlocBuilder<PlayerBloc, ps.PlayerState>(
      builder: (context, playerState) {
        final currentSong = playerState.currentSong ?? widget.song;
        final playerBloc = context.read<PlayerBloc>();
        final hasSongs =
            playerState.playlist.isNotEmpty || widget.songs.isNotEmpty;

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
                              currentSong.coverUrl,
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
                              border: Border.all(
                                color: Colors.black87,
                                width: 15,
                              ),
                            ),
                          ),
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF121212),
                              border: Border.all(
                                color: Colors.white38,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // --- THÔNG TIN BÀI HÁT + NÚT YÊU THÍCH ---
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
                              currentSong.title,
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
                              currentSong.artist,
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
                      // Nút thả tim — dùng FavoritesBloc
                      BlocBuilder<FavoritesBloc, dynamic>(
                        builder: (context, favState) {
                          final isFav = favState is FavoritesState
                              ? favState.isFavorite(currentSong)
                              : widget.isFavorite;
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              context.read<FavoritesBloc>().add(
                                ToggleFavorite(currentSong),
                              );
                            },
                          );
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
                      final totalDuration =
                          durationSnapshot.data ?? Duration.zero;
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
                                    playerBloc.add(
                                      SeekRequested(
                                        Duration(milliseconds: value.toInt()),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                        icon: const Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          final current = widget.player.position;
                          final newPos = current - const Duration(seconds: 10);
                          playerBloc.add(
                            SeekRequested(
                              newPos < Duration.zero ? Duration.zero : newPos,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          color: hasSongs ? Colors.white : Colors.white38,
                          size: 40,
                        ),
                        onPressed: hasSongs
                            ? () => playerBloc.add(PreviousSongRequested())
                            : null,
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
                                  playerBloc.add(PauseRequested());
                                } else {
                                  playerBloc.add(ResumeRequested());
                                }
                              },
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: hasSongs ? Colors.white : Colors.white38,
                          size: 40,
                        ),
                        onPressed: hasSongs
                            ? () => playerBloc.add(NextSongRequested())
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          final current = widget.player.position;
                          final total = widget.player.duration ?? Duration.zero;
                          final newPos = current + const Duration(seconds: 10);
                          playerBloc.add(
                            SeekRequested(newPos > total ? total : newPos),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
