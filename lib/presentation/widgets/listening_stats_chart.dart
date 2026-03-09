import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/stats/stats_bloc.dart';
import '../../logic/stats/stats_state.dart';

/// Widget biểu đồ thống kê nghe nhạc
/// Hiển thị tần suất nghe theo nghệ sĩ (BarChart)
/// Dùng StatsBloc riêng biệt thay vì HistoryBloc
class ListeningStatsChart extends StatelessWidget {
  const ListeningStatsChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state is StatsLoading) {
          return _buildLoadingState(theme);
        }

        if (state is StatsError) {
          return _buildErrorState(theme, state.message);
        }

        if (state is! StatsLoaded || state.topArtists.isEmpty) {
          return _buildEmptyState(theme);
        }

        final top5 = state.topArtists;
        final maxY = (top5.first.value + 1).toDouble();

        // Màu sắc cho từng cột
        final barColors = [
          Colors.tealAccent,
          Colors.cyanAccent,
          Colors.lightBlueAccent,
          Colors.purpleAccent,
          Colors.amberAccent,
        ];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: Colors.tealAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thống kê nghe nhạc',
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Top ${top5.length} nghệ sĩ bạn nghe nhiều nhất',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Tổng số bài đã nghe
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBadge(
                    icon: Icons.headphones,
                    value: state.totalPlayed.toString(),
                    label: 'Bài đã nghe',
                    color: Colors.tealAccent,
                    theme: theme,
                  ),
                  _buildStatBadge(
                    icon: Icons.person,
                    value: state.uniqueArtists.toString(),
                    label: 'Nghệ sĩ',
                    color: Colors.cyanAccent,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Biểu đồ cột
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final artist = top5[group.x.toInt()].key;
                          return BarTooltipItem(
                            '$artist\n${rod.toY.toInt()} lần',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == value.roundToDouble()) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < top5.length) {
                              final name = top5[idx].key;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  name.length > 8
                                      ? '${name.substring(0, 7)}…'
                                      : name,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(top5.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: top5[index].value.toDouble(),
                            color: barColors[index % barColors.length],
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart, color: Colors.grey, size: 40),
          const SizedBox(height: 10),
          Text(
            'Thống kê nghe nhạc',
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hãy nghe nhạc để xem thống kê!',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
