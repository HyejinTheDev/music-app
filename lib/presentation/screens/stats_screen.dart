import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/stats/stats_bloc.dart';
import '../../logic/stats/stats_event.dart';
import '../widgets/listening_stats_chart.dart';

/// Màn hình thống kê nghe nhạc — mở từ Profile
class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => StatsBloc()..add(LoadStats()),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Thống kê nghe nhạc",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: theme.iconTheme.color),
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              ListeningStatsChart(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
