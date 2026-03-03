import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/local_notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC quản lý thông báo — theo pattern BLoC + MVVM
/// Lắng nghe Firestore user_notifications/{currentUserId}/items
/// Chỉ nhận thông báo từ người mình đã theo dõi (follow)
/// Gửi cả thông báo in-app và local push notification cho điện thoại
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  final List<NotificationModel> _notifications = [];
  StreamSubscription? _notifSub;
  int _notifIdCounter = 0;

  /// Lưu lại thời điểm bắt đầu lắng nghe (chỉ push notification cho bài mới hơn)
  DateTime? _listenStartTime;

  /// Set lưu các notifId đã xử lý (tránh push trùng)
  final Set<String> _processedNotifIds = {};

  NotificationBloc({required this.notificationRepository})
    : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<AddNotification>(_onAdd);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<StartListeningNotifications>(_onStartListening);
  }

  void _onLoad(LoadNotifications event, Emitter<NotificationState> emit) {
    emit(NotificationLoaded(notifications: List.from(_notifications)));
  }

  void _onAdd(AddNotification event, Emitter<NotificationState> emit) {
    _notifications.insert(0, event.notification); // Mới nhất lên đầu
    emit(NotificationLoaded(notifications: List.from(_notifications)));
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final index = _notifications.indexWhere(
      (n) => n.id == event.notificationId,
    );
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      emit(NotificationLoaded(notifications: List.from(_notifications)));

      // Cập nhật trên Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        notificationRepository.markAsRead(uid, event.notificationId);
      }
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    emit(NotificationLoaded(notifications: List.from(_notifications)));

    // Cập nhật trên Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      notificationRepository.markAllAsRead(uid);
    }
  }

  /// Bắt đầu lắng nghe Firestore user_notifications/{currentUserId}/items
  /// Khi có thông báo mới → hiện in-app + local push notification
  void _onStartListening(
    StartListeningNotifications event,
    Emitter<NotificationState> emit,
  ) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    _listenStartTime = DateTime.now();
    _notifSub?.cancel();

    _notifSub = notificationRepository
        .getUserNotificationsStream(currentUserId)
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            // Chỉ xử lý thông báo MỚI thêm vào
            if (change.type != DocumentChangeType.added) continue;

            final doc = change.doc;

            // Bỏ qua nếu đã xử lý
            if (_processedNotifIds.contains(doc.id)) continue;
            _processedNotifIds.add(doc.id);

            // Parse notification từ Firestore
            final notification = NotificationModel.fromFirestore(doc);

            // Thêm vào danh sách in-app
            add(AddNotification(notification));

            // Chỉ show local push cho thông báo MỚI (sau khi bắt đầu lắng nghe)
            if (_listenStartTime != null &&
                notification.timestamp.isAfter(_listenStartTime!)) {
              _notifIdCounter++;
              LocalNotificationService.showNotification(
                id: _notifIdCounter,
                title: notification.title,
                body: notification.body,
              );
            }
          }
        });
  }

  @override
  Future<void> close() {
    _notifSub?.cancel();
    return super.close();
  }
}
