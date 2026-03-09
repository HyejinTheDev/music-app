import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'banner_event.dart';
import 'banner_state.dart';
import '../../data/models/banner_model.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  BannerBloc() : super(const BannerLoading()) {
    on<LoadBanners>(_onLoadBanners);
    on<NextBanner>(_onNextBanner);
    on<PreviousBanner>(_onPreviousBanner);
  }

  static const List<BannerItem> _defaultBanners = [
    BannerItem(
      title: "\u{1F3B5} Khám phá ngay!",
      subtitle: "Hàng ngàn bài hát mới đang chờ bạn. Nghe miễn phí!",
      buttonText: "Nghe ngay",
      icon: Icons.headphones,
      gradientColors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
    ),
    BannerItem(
      title: "\u{1F525} Top thịnh hành",
      subtitle: "Những bài hát hot nhất tuần này. Cập nhật liên tục!",
      buttonText: "Xem ngay",
      icon: Icons.trending_up,
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    ),
    BannerItem(
      title: "\u{1F3A7} Playlist cho bạn",
      subtitle: "Playlist được tạo riêng theo sở thích âm nhạc của bạn.",
      buttonText: "Khám phá",
      icon: Icons.queue_music,
      gradientColors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    ),
  ];

  void _onLoadBanners(LoadBanners event, Emitter<BannerState> emit) {
    emit(const BannerLoaded(banners: _defaultBanners, currentIndex: 0));
  }

  void _onNextBanner(NextBanner event, Emitter<BannerState> emit) {
    if (state is BannerLoaded) {
      final current = state as BannerLoaded;
      final nextIndex = (current.currentIndex + 1) % current.banners.length;
      emit(current.copyWith(currentIndex: nextIndex));
    }
  }

  void _onPreviousBanner(PreviousBanner event, Emitter<BannerState> emit) {
    if (state is BannerLoaded) {
      final current = state as BannerLoaded;
      final prevIndex = current.currentIndex == 0
          ? current.banners.length - 1
          : current.currentIndex - 1;
      emit(current.copyWith(currentIndex: prevIndex));
    }
  }
}
