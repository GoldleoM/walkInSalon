import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/salon_model.dart';

class SalonCard extends StatelessWidget {
  final SalonModel salon;
  final VoidCallback onTap;
  final String? distance;

  const SalonCard({
    super.key,
    required this.salon,
    required this.onTap,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppConfig.adaptiveSurface(context),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: AppDecorations.shadowSoft(isDark: isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Salon Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadius),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: salon.imageUrl != null && salon.imageUrl!.isNotEmpty
                    ? Image.network(
                        salon.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            child: const Center(
                              child: Icon(
                                Icons.store,
                                size: 50,
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(
                            Icons.store,
                            size: 50,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
              ),
            ),

            // ℹ️ Salon Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (salon.profileImageUrl != null &&
                      salon.profileImageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 25, // Bigger size (50px)
                          backgroundImage: NetworkImage(salon.profileImageUrl!),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                salon.salonName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 14,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    salon.rating.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.warning,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppConfig.adaptiveTextColor(
                                context,
                              ).withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${salon.address}${distance != null ? ' • $distance' : ''}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppConfig.adaptiveTextColor(
                                        context,
                                      ).withValues(alpha: 0.6),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppConfig.adaptiveTextColor(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppConfig.adaptiveTextColor(context).withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
