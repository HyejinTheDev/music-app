abstract class BannerEvent {}

/// Tải danh sách banner
class LoadBanners extends BannerEvent {}

/// Chuyển sang banner tiếp theo (auto-slide hoặc user swipe)
class NextBanner extends BannerEvent {}

/// Chuyển sang banner trước
class PreviousBanner extends BannerEvent {}

/// Nhấn vào banner
class BannerTapped extends BannerEvent {
  final int index;
  BannerTapped(this.index);
}
