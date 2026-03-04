import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../logic/notification/notification_bloc.dart';
import '../../logic/notification/notification_event.dart';
import '../../logic/notification/notification_state.dart';

/// Màn hình danh sách thông báo
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state.hasUnread) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(MarkAllAsRead());
                  },
                  child: const Text(
                    'Đọc hết',
                    style: TextStyle(color: Colors.tealAccent, fontSize: 13),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            );
          }

          final notifications = state.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo nào',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

/// Widget hiển thị một thông báo
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newSong:
        return Icons.music_note;
      case NotificationType.newPost:
        return Icons.article;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.newSong:
        return Colors.tealAccent;
      case NotificationType.newPost:
        return Colors.purpleAccent;
      case NotificationType.like:
        return Colors.pinkAccent;
      case NotificationType.comment:
        return Colors.greenAccent;
      case NotificationType.follow:
        return Colors.blueAccent;
      case NotificationType.system:
        return Colors.orangeAccent;
    }
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      tileColor: notification.isRead
          ? Colors.transparent
          : (theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.teal.withOpacity(0.05)),
      leading: CircleAvatar(
        backgroundColor: _getIconColor(notification.type).withOpacity(0.15),
        child: Icon(
          _getIcon(notification.type),
          color: _getIconColor(notification.type),
          size: 22,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            notification.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _timeAgo(notification.timestamp),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
              ),
            ),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationBloc>().add(MarkAsRead(notification.id));
        }
      },
    );
  }
}
