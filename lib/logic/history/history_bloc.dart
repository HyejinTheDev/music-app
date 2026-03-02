import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/song_model.dart';
import 'history_event.dart';
import 'history_state.dart';

/// BLoC quản lý lịch sử nghe nhạc
/// Lưu danh sách bài hát đã phát, mới nhất ở đầu
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final List<Song> _history = [];

  HistoryBloc() : super(const HistoryInitial()) {
    on<AddToHistory>(_onAddToHistory);
    on<ClearHistory>(_onClearHistory);
  }

  /// Thêm bài hát vào lịch sử
  /// Nếu đã có thì xóa bản cũ, đẩy lên đầu (nghe gần nhất)
  void _onAddToHistory(AddToHistory event, Emitter<HistoryState> emit) {
    _history.removeWhere((s) => s.id == event.song.id);
    _history.insert(0, event.song);

    emit(HistoryLoaded(songs: List.unmodifiable(_history)));
  }

  /// Xóa toàn bộ lịch sử
  void _onClearHistory(ClearHistory event, Emitter<HistoryState> emit) {
    _history.clear();
    emit(const HistoryInitial());
  }
}
