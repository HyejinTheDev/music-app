import '../../data/models/notification_model.dart';

/// Các sự kiện cho NotificationBloc
abstract class NotificationEvent {}

/// Tải danh sách thông báo
class LoadNotifications extends NotificationEvent {}

/// Đánh dấu một thông báo đã đọc
class MarkAsRead extends NotificationEvent {
  final String notificationId;
  MarkAsRead(this.notificationId);
}

/// Đánh dấu tất cả đã đọc
class MarkAllAsRead extends NotificationEvent {}

/// Thêm thông báo mới (in-app)
class AddNotification extends NotificationEvent {
  final NotificationModel notification;
  AddNotification(this.notification);
}

/// Bắt đầu lắng nghe thông báo cá nhân từ Firestore
/// (user_notifications/{currentUserId}/items)
class StartListeningNotifications extends NotificationEvent {}
