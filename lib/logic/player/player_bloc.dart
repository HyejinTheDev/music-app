import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import '../../data/models/song_model.dart';
import 'player_event.dart';
import 'player_state.dart';

/// BLoC quản lý AudioPlayer tập trung cho toàn app
/// Thay thế logic player bị duplicate trong:
/// - home_screen._playMusic()
/// - song_detail_screen._switchSong()
/// - mini_player._nextSong() / _previousSong()
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _playlist = [];
  Song? _currentSong;

  /// Truy cập AudioPlayer (để UI stream playerState, position, duration)
  AudioPlayer get player => _player;

  PlayerBloc() : super(const PlayerInitial()) {
    // Xử lý: Phát bài hát
    on<PlaySongRequested>(_onPlaySong);

    // Xử lý: Tạm dừng
    on<PauseRequested>(_onPause);

    // Xử lý: Tiếp tục phát
    on<ResumeRequested>(_onResume);

    // Xử lý: Dừng hoàn toàn
    on<StopRequested>(_onStop);

    // Xử lý: Bài tiếp theo
    on<NextSongRequested>(_onNextSong);

    // Xử lý: Bài trước đó
    on<PreviousSongRequested>(_onPreviousSong);

    // Xử lý: Cập nhật playlist
    on<UpdatePlaylist>(_onUpdatePlaylist);

    // Xử lý: Seek
    on<SeekRequested>(_onSeek);

    // Tự động chuyển bài khi hết nhạc
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        add(NextSongRequested());
      }
    });
  }

  /// Phát bài hát — nếu đang phát bài này thì toggle play/pause
  Future<void> _onPlaySong(
    PlaySongRequested event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      // Toggle play/pause nếu bấm vào bài đang phát
      if (_currentSong?.id == event.song.id) {
        if (_player.playing) {
          _player.pause();
          emit(
            PlayerPaused(
              player: _player,
              currentSong: _currentSong!,
              playlist: _playlist,
            ),
          );
        } else {
          _player.play();
          emit(
            PlayerPlaying(
              player: _player,
              currentSong: _currentSong!,
              playlist: _playlist,
            ),
          );
        }
        return;
      }

      // Phát bài mới
      _currentSong = event.song;
      await _player.stop();

      if (event.song.audioUrl.isNotEmpty) {
        await _player.setUrl(event.song.audioUrl);
        _player.play();
      }

      emit(
        PlayerPlaying(
          player: _player,
          currentSong: _currentSong!,
          playlist: _playlist,
        ),
      );
    } catch (e) {
      emit(
        PlayerError(
          "Lỗi phát nhạc: $e",
          currentSong: _currentSong,
          playlist: _playlist,
        ),
      );
    }
  }

  /// Tạm dừng
  Future<void> _onPause(PauseRequested event, Emitter<PlayerState> emit) async {
    _player.pause();
    if (_currentSong != null) {
      emit(
        PlayerPaused(
          player: _player,
          currentSong: _currentSong!,
          playlist: _playlist,
        ),
      );
    }
  }

  /// Tiếp tục phát
  Future<void> _onResume(
    ResumeRequested event,
    Emitter<PlayerState> emit,
  ) async {
    _player.play();
    if (_currentSong != null) {
      emit(
        PlayerPlaying(
          player: _player,
          currentSong: _currentSong!,
          playlist: _playlist,
        ),
      );
    }
  }

  /// Dừng hoàn toàn — ẩn MiniPlayer
  Future<void> _onStop(StopRequested event, Emitter<PlayerState> emit) async {
    await _player.stop();
    _currentSong = null;
    emit(const PlayerStopped());
  }

  /// Chuyển bài tiếp theo (vòng lặp)
  Future<void> _onNextSong(
    NextSongRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (_playlist.isEmpty || _currentSong == null) return;

    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    final nextIndex = (currentIndex + 1) % _playlist.length;
    final nextSong = _playlist[nextIndex];

    add(PlaySongRequested(nextSong));
  }

  /// Chuyển bài trước đó (vòng lặp)
  Future<void> _onPreviousSong(
    PreviousSongRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (_playlist.isEmpty || _currentSong == null) return;

    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    final prevIndex = (currentIndex - 1 + _playlist.length) % _playlist.length;
    final prevSong = _playlist[prevIndex];

    add(PlaySongRequested(prevSong));
  }

  /// Cập nhật playlist (khi SongListLoaded hoặc chuyển tab)
  void _onUpdatePlaylist(UpdatePlaylist event, Emitter<PlayerState> emit) {
    _playlist = event.songs;
  }

  /// Seek đến vị trí cụ thể
  Future<void> _onSeek(SeekRequested event, Emitter<PlayerState> emit) async {
    await _player.seek(event.position);
  }

  @override
  Future<void> close() {
    _player.dispose();
    return super.close();
  }
}
