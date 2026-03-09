/// Các trạng thái của StatsBloc
abstract class StatsState {}

/// Chưa có dữ liệu thống kê
class StatsInitial extends StatsState {}

/// Đang tải thống kê
class StatsLoading extends StatsState {}

/// Đã có dữ liệu thống kê
class StatsLoaded extends StatsState {
  /// Tổng số bài đã nghe (bao gồm lặp lại)
  final int totalPlayed;

  /// Số nghệ sĩ khác nhau đã nghe
  final int uniqueArtists;

  /// Top nghệ sĩ nghe nhiều nhất: {tên nghệ sĩ: số lần}
  final List<MapEntry<String, int>> topArtists;

  StatsLoaded({
    required this.totalPlayed,
    required this.uniqueArtists,
    required this.topArtists,
  });
}

/// Lỗi tải thống kê
class StatsError extends StatsState {
  final String message;
  StatsError(this.message);
}
