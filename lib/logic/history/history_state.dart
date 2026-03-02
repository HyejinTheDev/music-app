import '../../data/models/song_model.dart';

/// Các trạng thái của lịch sử nghe nhạc
abstract class HistoryState {
  final List<Song> songs;

  const HistoryState({this.songs = const []});
}

/// Chưa có lịch sử
class HistoryInitial extends HistoryState {
  const HistoryInitial() : super();
}

/// Đã có dữ liệu lịch sử
class HistoryLoaded extends HistoryState {
  const HistoryLoaded({required List<Song> songs}) : super(songs: songs);
}
