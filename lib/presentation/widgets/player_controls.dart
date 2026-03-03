import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_event.dart';

/// Thanh điều khiển phát nhạc (seek bar + play/pause/next/prev)
/// Tách từ song_detail_screen.dart
class PlayerControls extends StatelessWidget {
  final AudioPlayer player;
  final bool hasSongs;

  const PlayerControls({Key? key, required this.player, required this.hasSongs})
    : super(key: key);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final playerBloc = context.read<PlayerBloc>();

    final theme = Theme.of(context);

    return Column(
      children: [
        // --- THANH TRƯỢT THỜI GIAN (SEEK BAR) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: StreamBuilder<Duration?>(
            stream: player.durationStream,
            builder: (context, durationSnapshot) {
              final totalDuration = durationSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, positionSnapshot) {
                  final currentPosition =
                      positionSnapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.tealAccent,
                          inactiveTrackColor: theme.dividerColor,
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
                          max: totalDuration.inMilliseconds.toDouble().clamp(
                            1,
                            double.infinity,
                          ),
                          value: currentPosition.inMilliseconds
                              .toDouble()
                              .clamp(
                                0,
                                totalDuration.inMilliseconds.toDouble().clamp(
                                  1,
                                  double.infinity,
                                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                icon: Icon(
                  Icons.replay_10,
                  color: theme.iconTheme.color,
                  size: 32,
                ),
                onPressed: () {
                  final current = player.position;
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
                  color: hasSongs ? theme.iconTheme.color : theme.disabledColor,
                  size: 40,
                ),
                onPressed: hasSongs
                    ? () => playerBloc.add(PreviousSongRequested())
                    : null,
              ),

              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
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
                  color: hasSongs ? theme.iconTheme.color : theme.disabledColor,
                  size: 40,
                ),
                onPressed: hasSongs
                    ? () => playerBloc.add(NextSongRequested())
                    : null,
              ),
              IconButton(
                icon: Icon(
                  Icons.forward_10,
                  color: theme.iconTheme.color,
                  size: 32,
                ),
                onPressed: () {
                  final current = player.position;
                  final total = player.duration ?? Duration.zero;
                  final newPos = current + const Duration(seconds: 10);
                  playerBloc.add(
                    SeekRequested(newPos > total ? total : newPos),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
