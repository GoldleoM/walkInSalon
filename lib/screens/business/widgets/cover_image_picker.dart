import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class CoverImagePicker extends StatelessWidget {
  final Uint8List? webCoverImage;
  final File? coverImage;
  final VoidCallback onTap;

  const CoverImagePicker({
    super.key,
    this.webCoverImage,
    this.coverImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DecorationImage? coverDecoration;

    if (kIsWeb && webCoverImage != null) {
      coverDecoration = DecorationImage(
        image: MemoryImage(webCoverImage!),
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && coverImage != null) {
      coverDecoration = DecorationImage(
        image: FileImage(coverImage!),
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: coverDecoration == null
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.surface.withValues(alpha: 0.5))
              : Colors.transparent,
          image: coverDecoration,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
        ),
        child: coverDecoration == null
            ? Center(
                child: Text(
                  "Tap to add cover photo",
                  style: AppConfig.text.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
