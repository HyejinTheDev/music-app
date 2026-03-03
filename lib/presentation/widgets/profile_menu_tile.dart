import 'package:flutter/material.dart';

/// Widget tile cho menu Profile
/// Tách từ profile_screen._buildTile
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isExit;

  const ProfileMenuTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isExit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isExit
            ? Colors.redAccent
            : theme.iconTheme.color?.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isExit ? Colors.redAccent : theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: theme.dividerColor, size: 18),
    );
  }
}

/// Card tính năng quản lý nội dung (thêm bài hát, thêm album)
/// Tách từ profile_screen.dart
class ContentManagementCard extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ContentManagementCard({
    Key? key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        color: Colors.tealAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(leadingIcon, color: Colors.tealAccent),
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
          trailing: const Icon(Icons.add_circle, color: Colors.tealAccent),
          onTap: onTap,
        ),
      ),
    );
  }
}
