import '../../data/models/notification_model.dart';

/// Các trạng thái của NotificationBloc
abstract class NotificationState {
  final List<NotificationModel> notifications;
  const NotificationState({this.notifications = const []});

  /// Số thông báo chưa đọc
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Có thông báo chưa đọc không
  bool get hasUnread => unreadCount > 0;
}

/// Chưa tải
class NotificationInitial extends NotificationState {}

/// Đang tải
class NotificationLoading extends NotificationState {}

/// Đã tải xong
class NotificationLoaded extends NotificationState {
  const NotificationLoaded({required List<NotificationModel> notifications})
    : super(notifications: notifications);
}

/// Lỗi
class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
}
