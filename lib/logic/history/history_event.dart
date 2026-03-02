import '../../data/models/song_model.dart';

/// Các sự kiện của HistoryBloc
abstract class HistoryEvent {}

/// Thêm bài hát vào lịch sử khi phát
class AddToHistory extends HistoryEvent {
  final Song song;
  AddToHistory(this.song);
}

/// Xóa toàn bộ lịch sử
class ClearHistory extends HistoryEvent {}
