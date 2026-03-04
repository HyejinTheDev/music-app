import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';

/// Service quản lý Firebase Cloud Messaging (FCM)
/// - Lấy và lưu device token vào Firestore users/{uid}.fcmToken
/// - Xử lý foreground message → show local notification
/// - Setup background message handler
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Khởi tạo FCM — gọi 1 lần sau khi Firebase.initializeApp
  static Future<void> initialize() async {
    // 1. Yêu cầu quyền thông báo (iOS/Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return; // User từ chối quyền thông báo
    }

    // 2. Lấy device token và lưu vào Firestore
    await _saveDeviceToken();

    // 3. Lắng nghe khi token thay đổi (refresh)
    _messaging.onTokenRefresh.listen((_) => _saveDeviceToken());

    // 4. Lắng nghe FCM message khi app đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        LocalNotificationService.showNotification(
          id: message.hashCode,
          title: notification.title ?? 'Thông báo mới',
          body: notification.body ?? '',
        );
      }
    });
  }

  /// Lấy FCM token và lưu vào Firestore users/{uid}.fcmToken
  static Future<void> _saveDeviceToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FcmService] Lỗi lưu device token: $e');
    }
  }
}
