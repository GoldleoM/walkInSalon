import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:intl/intl.dart';

class NotificationOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(int) onDismiss;
  final VoidCallback markAllRead;
  final Function(Map<String, dynamic>) onOpen;

  const NotificationOverlay({
    super.key,
    required this.notifications,
    required this.onDismiss,
    required this.markAllRead,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: AppDecorations.glassPanel(context).copyWith(
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.shadowElevated(
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Divider(
              height: 1,
              color: AppConfig.adaptiveTextColor(
                context,
              ).withValues(alpha: 0.3),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No new notifications"),
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        final read = n['read'] ?? false;
                        final type = n['type'] ?? '';
                        final title = n['title'] ?? 'Update';
                        final time = n['time'] != null
                            ? DateFormat('MMM d, h:mm a').format(n['time'])
                            : '';

                        return Dismissible(
                          key: Key(index.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => onDismiss(index),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppColors.error.withValues(alpha: 0.7),
                            child: const Icon(
                              Icons.delete,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              type == 'Review'
                                  ? Icons.star_rounded
                                  : Icons.calendar_today_rounded,
                              color: type == 'Review'
                                  ? AppColors.warning
                                  : AppColors.secondary,
                            ),
                            title: Text(
                              title,
                              style: TextStyle(
                                fontWeight: read
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              type == 'Review'
                                  ? "New review received"
                                  : "New appointment booked",
                            ),
                            trailing: Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConfig.adaptiveTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                            ),
                            onTap: () => onOpen(n),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Notifications",
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: markAllRead,
            child: const Text(
              "Mark all as read",
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
