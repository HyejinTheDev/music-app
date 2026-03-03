import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../logic/song_list/song_list_bloc.dart';
import '../../logic/song_list/song_list_event.dart';
import '../../l10n/app_localizations.dart';

/// Dialog sửa profile: tên + ảnh URL
/// Tách từ profile_screen.dart
void showEditProfileDialog(
  BuildContext context,
  String currentName,
  String? currentPhotoUrl,
) {
  final loc = AppLocalizations.of(context);
  final nameController = TextEditingController(text: currentName);
  final photoController = TextEditingController(text: currentPhotoUrl ?? '');

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        loc.translate('edit_profile'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tên hiển thị
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: loc.translate('display_name'),
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: loc.translate('enter_name_hint'),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.tealAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.tealAccent,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // URL ảnh đại diện
            TextField(
              controller: photoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: loc.translate('photo_url'),
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: loc.translate('photo_url_hint'),
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black26,
                prefixIcon: const Icon(
                  Icons.image,
                  color: Colors.tealAccent,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.tealAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.tealAccent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(
            loc.translate('cancel'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            final newName = nameController.text.trim();
            final newPhoto = photoController.text.trim();

            if (newName.isNotEmpty) {
              context.read<ProfileBloc>().add(
                UpdateProfile(
                  displayName: newName,
                  photoUrl: newPhoto.isNotEmpty ? newPhoto : null,
                ),
              );
              // Reload danh sách bài hát để cập nhật tên
              context.read<SongListBloc>().add(LoadSongs());
            }
            Navigator.pop(dialogContext);
          },
          child: Text(
            loc.translate('save'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
