import '../../data/models/song_model.dart';

/// Các sự kiện cho LyricsBloc
abstract class LyricsEvent {}

/// Tải lời bài hát cho bài hát hiện tại
class LoadLyrics extends LyricsEvent {
  final Song song;
  LoadLyrics(this.song);
}
