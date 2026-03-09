import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dataproviders/db_helper.dart';
import 'stats_event.dart';
import 'stats_state.dart';

/// BLoC quản lý thống kê nghe nhạc
/// Đọc dữ liệu từ SQLite (bảng history) qua DatabaseHelper
/// Tính toán: tổng bài đã nghe, số nghệ sĩ, top 5 nghệ sĩ
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final DatabaseHelper _dbHelper;

  StatsBloc({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      super(StatsInitial()) {
    on<LoadStats>(_onLoadStats);
  }

  /// Tải lịch sử từ SQLite → tính toán thống kê
  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(StatsLoading());

    try {
      final songs = await _dbHelper.getHistory();

      if (songs.isEmpty) {
        emit(StatsLoaded(totalPlayed: 0, uniqueArtists: 0, topArtists: []));
        return;
      }

      // Đếm số lần nghe theo nghệ sĩ
      final artistCounts = <String, int>{};
      for (final song in songs) {
        final artist = song.artist;
        artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
      }

      // Sắp xếp top 5 nghệ sĩ nghe nhiều nhất
      final sorted = artistCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top5 = sorted.take(5).toList();

      emit(
        StatsLoaded(
          totalPlayed: songs.length,
          uniqueArtists: artistCounts.length,
          topArtists: top5,
        ),
      );
    } catch (e) {
      emit(StatsError('Lỗi tải thống kê: $e'));
    }
  }
}
