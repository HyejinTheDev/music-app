import 'package:flutter/material.dart';

/// Lớp localization đơn giản dùng Map
/// Hỗ trợ: vi (Tiếng Việt) + en (English)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper: lấy instance từ context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Bảng dịch vi/en
  static const Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      // Bottom Nav
      'home': 'Trang chủ',
      'feed': 'Cộng đồng',
      'search': 'Tìm kiếm',
      'library': 'Thư viện',
      'profile': 'Cá nhân',

      // Home Content
      'app_title': 'Music App Pro',
      'featured_artists': 'Nghệ sĩ nổi bật',
      'suggestions': 'Gợi ý cho bạn',
      'latest_albums': 'Album mới nhất',

      // Profile
      'content_management': 'Quản lý nội dung',
      'add_song': 'Thêm bài hát mới',
      'add_song_sub': 'Tải nhạc của bạn lên hệ thống',
      'add_album': 'Thêm album mới',
      'add_album_sub': 'Tạo danh sách phát của riêng bạn',
      'history': 'Lịch sử đã nghe',
      'favorites': 'Danh sách yêu thích',
      'settings': 'Cài đặt',
      'logout': 'Đăng xuất',
      'new_artist': 'Nghệ sĩ mới',
      'guest_mode': 'Chế độ khách',

      // Settings Screen
      'settings_title': 'Cài đặt',
      'appearance': 'Giao diện',
      'dark_mode': 'Chế độ tối',
      'dark_mode_sub': 'Nền tối, dễ nhìn ban đêm',
      'light_mode_sub': 'Nền sáng, dễ nhìn ban ngày',
      'language': 'Ngôn ngữ',
      'language_sub': 'Chọn ngôn ngữ hiển thị',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',

      // Common
      'now_playing': 'Đang phát',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'close': 'Đóng',

      // Profile Edit
      'followers': 'Người theo dõi',
      'following': 'Đang theo dõi',
      'edit_profile': 'Sửa hồ sơ',
      'display_name': 'Tên hiển thị',
      'enter_name_hint': 'Nhập tên mới...',
      'photo_url': 'URL ảnh đại diện',
      'photo_url_hint': 'Nhập link ảnh...',

      // Artist Profile
      'artist_profile': 'Trang nghệ sĩ',
      'uploaded_songs': 'Bài hát đã đăng',
      'song_count': 'bài hát',
      'no_songs': 'Chưa có bài hát nào',
    },
    'en': {
      // Bottom Nav
      'home': 'Home',
      'feed': 'Feed',
      'search': 'Search',
      'library': 'Library',
      'profile': 'Profile',

      // Home Content
      'app_title': 'Music App Pro',
      'featured_artists': 'Featured Artists',
      'suggestions': 'Suggestions for you',
      'latest_albums': 'Latest Albums',

      // Profile
      'content_management': 'Content Management',
      'add_song': 'Add new song',
      'add_song_sub': 'Upload your music to the system',
      'add_album': 'Add new album',
      'add_album_sub': 'Create your own playlist',
      'history': 'Listening history',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'logout': 'Log out',
      'new_artist': 'New artist',
      'guest_mode': 'Guest Mode',

      // Settings Screen
      'settings_title': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'dark_mode_sub': 'Dark background, easy on the eyes at night',
      'light_mode_sub': 'Light background, easy on the eyes during the day',
      'language': 'Language',
      'language_sub': 'Choose display language',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',

      // Common
      'now_playing': 'Now Playing',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',

      // Profile Edit
      'followers': 'Followers',
      'following': 'Following',
      'edit_profile': 'Edit Profile',
      'display_name': 'Display Name',
      'enter_name_hint': 'Enter new name...',
      'photo_url': 'Photo URL',
      'photo_url_hint': 'Enter image link...',

      // Artist Profile
      'artist_profile': 'Artist Profile',
      'uploaded_songs': 'Uploaded Songs',
      'song_count': 'songs',
      'no_songs': 'No songs yet',
    },
  };

  /// Dịch key sang text tương ứng
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

/// Delegate cho AppLocalizations
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
