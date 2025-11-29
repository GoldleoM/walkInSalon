import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class ProfileImagePicker extends StatelessWidget {
  final Uint8List? webProfileImage;
  final File? profileImage;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    this.webProfileImage,
    this.profileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageProvider? imageProvider;
    if (kIsWeb && webProfileImage != null) {
      imageProvider = MemoryImage(webProfileImage!);
    } else if (!kIsWeb && profileImage != null) {
      imageProvider = FileImage(profileImage!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: imageProvider == null
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.surface.withValues(alpha: 0.5))
              : Colors.transparent,
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
        ),
        child: imageProvider == null
            ? Icon(
                Icons.camera_alt,
                size: 30,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              )
            : null,
      ),
    );
  }
}
