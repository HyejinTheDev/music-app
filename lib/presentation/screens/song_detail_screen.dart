import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/song_model.dart';
import '../../logic/player/player_bloc.dart';
import '../../logic/player/player_state.dart' as ps;
import '../../logic/lyrics/lyrics_bloc.dart';
import '../../logic/lyrics/lyrics_event.dart';
import '../widgets/vinyl_disc.dart';
import '../widgets/player_controls.dart';
import '../widgets/song_info_header.dart';
import '../widgets/lyrics_panel.dart';

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
  late LyricsBloc _lyricsBloc;
  Song? _lastLoadedSong;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();

    _lyricsBloc = LyricsBloc();

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
    _sheetController.dispose();
    _lyricsBloc.close();
    super.dispose();
  }

  void _ensureLyricsLoaded(Song song) {
    if (_lastLoadedSong?.id != song.id) {
      _lastLoadedSong = song;
      _lyricsBloc.add(LoadLyrics(song));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _lyricsBloc,
      child: BlocBuilder<PlayerBloc, ps.PlayerState>(
        builder: (context, playerState) {
          final currentSong = playerState.currentSong ?? widget.song;
          final hasSongs =
              playerState.playlist.isNotEmpty || widget.songs.isNotEmpty;

          // Load lyrics khi bài hát thay đổi
          _ensureLyricsLoaded(currentSong);

          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.iconTheme.color,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Đang phát",
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 14,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragEnd: (details) {
                  // Vuốt lên → mở lyrics
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < -300) {
                    _sheetController.animateTo(
                      LyricsPanel.maxChildSize,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  }
                  // Vuốt xuống → đóng lyrics
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 300) {
                    _sheetController.animateTo(
                      LyricsPanel.minChildSize,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Stack(
                  children: [
                    // --- NỘI DUNG CHÍNH ---
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // --- ĐĨA THAN XOAY TRÒN ---
                        VinylDisc(
                          animationController: _animationController,
                          coverUrl: currentSong.coverUrl,
                        ),

                        const Spacer(),

                        // --- THÔNG TIN BÀI HÁT + NÚT YÊU THÍCH ---
                        SongInfoHeader(
                          song: currentSong,
                          isFavorite: widget.isFavorite,
                        ),

                        const SizedBox(height: 20),

                        // --- SEEK BAR + CONTROLS ---
                        PlayerControls(
                          player: widget.player,
                          hasSongs: hasSongs,
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),

                    // --- LỜI BÀI HÁT (LƯỚT LÊN) ---
                    LyricsPanel(controller: _sheetController),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
