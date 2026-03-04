import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service quản lý local push notification cho điện thoại
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Khởi tạo service — gọi 1 lần khi app start
  static Future<void> initialize() async {
    if (_initialized) return;

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS / macOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);

    // Xóa channel cũ (nếu có) để Android dùng settings mới
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.deleteNotificationChannel('music_app_channel');
    }

    _initialized = true;
  }

  /// Hiển thị notification trên điện thoại
  /// Mỗi lần gọi sẽ có âm thanh + rung + hiện trên thanh trạng thái
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Dùng channel mới — đảm bảo settings không bị cache
    const androidDetails = AndroidNotificationDetails(
      'music_app_notifications_v2',
      'Thông báo Music App',
      channelDescription: 'Thông báo khi có like, comment, bài hát mới',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'Thông báo mới',
      // Đảm bảo mỗi notification hiện riêng
      groupKey: null,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Dùng timestamp-based ID để đảm bảo mỗi notification unique
    final uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _plugin.show(uniqueId, title, body, details);
  }
}
