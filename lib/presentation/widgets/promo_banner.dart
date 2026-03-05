import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/banner/banner_bloc.dart';
import '../../logic/banner/banner_event.dart';
import '../../logic/banner/banner_state.dart';
import '../../data/models/banner_model.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({Key? key}) : super(key: key);

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      context.read<BannerBloc>().add(NextBanner());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BannerBloc, BannerState>(
      listener: (context, state) {
        if (state is BannerLoaded && _pageController.hasClients) {
          _pageController.animateToPage(
            state.currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      builder: (context, state) {
        if (state is BannerLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            ),
          );
        }

        if (state is BannerLoaded) {
          return Column(
            children: [
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.banners.length,
                  onPageChanged: (index) {
                    if (state.currentIndex != index) {}
                  },
                  itemBuilder: (context, index) {
                    return _buildBannerCard(state.banners[index]);
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  state.banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: state.currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: state.currentIndex == index
                          ? Colors.tealAccent
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBannerCard(BannerItem banner) {
    // --- THÊM PHẦN NÀY ĐỂ LÀM TỐI MÀU ---
    // Pha trộn mỗi màu gốc với 50% màu đen (số 0.5).
    // Bạn có thể tăng lên 0.6 hoặc 0.7 nếu muốn nó tối hơn nữa.
    final List<Color> darkenedColors = banner.gradientColors.map((color) {
      return Color.lerp(color, Colors.black, 0.5) ?? color;
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: darkenedColors, // Dùng mảng màu đã làm tối
        ),
        boxShadow: [
          BoxShadow(
            color: darkenedColors.first.withValues(
              alpha: 0.3,
            ), // Đổ bóng cũng dùng màu tối
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.05,
                ), // Giảm độ nhạt của hình tròn trang trí
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.05,
                ), // Giảm độ nhạt của hình tròn trang trí
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(banner.icon, color: Colors.white70, size: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
