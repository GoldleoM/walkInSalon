import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

/// 🧭 macOS-style translucent drawer item
Widget buildDrawerItem(
  BuildContext context,
  IconData icon,
  String title,
  Widget page,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppDecorations.glassPanel(context),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkTextPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: AppDecorations.shadowSoft(
                        isDark: Theme.of(context).brightness == Brightness.dark),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon,
                      color: AppConfig.adaptiveTextColor(context), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppConfig.adaptiveTextColor(context).withOpacity(0.45),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
