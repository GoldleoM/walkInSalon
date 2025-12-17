import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class ServiceList extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final Function(Map<String, dynamic>) onServiceSelected;

  const ServiceList({
    super.key,
    required this.services,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No services available.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConfig.adaptiveTextColor(
                context,
              ).withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];
        return Container(
          decoration: AppDecorations.glassPanel(context),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              service['name'] ?? 'Unknown Service',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "${service['duration'] ?? '30'} mins",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConfig.adaptiveTextColor(
                  context,
                ).withValues(alpha: 0.6),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "₹${service['price'] ?? '0'}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => onServiceSelected(service),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(60, 36),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Book"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
