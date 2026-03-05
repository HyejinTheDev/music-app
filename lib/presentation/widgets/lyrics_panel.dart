import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/lyrics/lyrics_bloc.dart';
import '../../logic/lyrics/lyrics_state.dart';

/// Panel lời bài hát — vuốt lên ở bất kỳ đâu để hiển thị toàn màn hình
class LyricsPanel extends StatelessWidget {
  final DraggableScrollableController controller;

  const LyricsPanel({Key? key, required this.controller}) : super(key: key);

  // Kích thước tối thiểu (chỉ hiện thanh kéo nhỏ ở dưới)
  static const double minChildSize = 0.07;
  // Kích thước tối đa
  static const double maxChildSize = 0.92;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: minChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: const [maxChildSize],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // --- PHẦN HEADER CỐ ĐỊNH (grab handle + tiêu đề) ---
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Thanh kéo gợi ý vuốt
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Hàng gợi ý "Vuốt lên xem lời bài hát"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lyrics, color: Colors.tealAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Lời bài hát',
                          style: TextStyle(
                            color: theme.textTheme.titleMedium?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                  ],
                ),
              ),

              // --- NỘI DUNG LỜI BÀI HÁT ---
              SliverFillRemaining(
                hasScrollBody: true,
                child: BlocBuilder<LyricsBloc, LyricsState>(
                  builder: (context, state) {
                    if (state is LyricsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      );
                    }

                    if (state is LyricsLoaded) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.hasLyrics
                              ? state.lyrics
                              : 'Chưa có lời bài hát.',
                          style: TextStyle(
                            color:
                                theme.textTheme.bodyMedium?.color?.withValues(
                                  alpha: 0.85,
                                ) ??
                                Colors.white70,
                            fontSize: 17,
                            height: 1.9,
                          ),
                        ),
                      );
                    }

                    if (state is LyricsError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
