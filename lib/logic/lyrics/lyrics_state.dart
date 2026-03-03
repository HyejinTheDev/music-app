/// Các trạng thái cho LyricsBloc
abstract class LyricsState {}

/// Chưa tải
class LyricsInitial extends LyricsState {}

/// Đang tải
class LyricsLoading extends LyricsState {}

/// Đã tải xong — có lời bài hát
class LyricsLoaded extends LyricsState {
  final String lyrics;
  final String songTitle;

  LyricsLoaded({required this.lyrics, required this.songTitle});

  bool get hasLyrics => lyrics.isNotEmpty;
}

/// Lỗi
class LyricsError extends LyricsState {
  final String message;
  LyricsError(this.message);
}
