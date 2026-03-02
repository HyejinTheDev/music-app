import '../../data/models/banner_model.dart';

abstract class BannerState {
  final List<BannerItem> banners;
  final int currentIndex;

  const BannerState({this.banners = const [], this.currentIndex = 0});
}

/// Trạng thái đang tải
class BannerLoading extends BannerState {
  const BannerLoading() : super();
}

/// Đã tải xong danh sách banner
class BannerLoaded extends BannerState {
  const BannerLoaded({
    required List<BannerItem> banners,
    required int currentIndex,
  }) : super(banners: banners, currentIndex: currentIndex);

  BannerLoaded copyWith({List<BannerItem>? banners, int? currentIndex}) {
    return BannerLoaded(
      banners: banners ?? this.banners,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

/// Lỗi khi tải banner
class BannerError extends BannerState {
  final String message;
  const BannerError(this.message) : super();
}
