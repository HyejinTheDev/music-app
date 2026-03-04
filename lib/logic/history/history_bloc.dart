import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dataproviders/db_helper.dart';
import 'history_event.dart';
import 'history_state.dart';

/// BLoC quản lý lịch sử nghe nhạc
/// Dữ liệu được persist vào SQLite qua DatabaseHelper
/// Lưu danh sách bài hát đã phát, mới nhất ở đầu
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final DatabaseHelper _dbHelper;

  HistoryBloc({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<AddToHistory>(_onAddToHistory);
    on<ClearHistory>(_onClearHistory);
  }

  /// Tải lịch sử từ SQLite
  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final songs = await _dbHelper.getHistory();
      emit(HistoryLoaded(songs: List.unmodifiable(songs)));
    } catch (e) {
      emit(const HistoryInitial());
    }
  }

  /// Thêm bài hát vào lịch sử
  /// Insert/replace trong SQLite rồi reload state
  Future<void> _onAddToHistory(
    AddToHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _dbHelper.insertHistory(event.song);

      // Reload từ SQLite
      final songs = await _dbHelper.getHistory();
      emit(HistoryLoaded(songs: List.unmodifiable(songs)));
    } catch (e) {
      // Giữ state hiện tại nếu lỗi
    }
  }

  /// Xóa toàn bộ lịch sử
  Future<void> _onClearHistory(
    ClearHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _dbHelper.clearHistory();
      emit(const HistoryInitial());
    } catch (e) {
      // Giữ state hiện tại nếu lỗi
    }
  }
}
