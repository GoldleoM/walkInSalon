import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for now
    final bookings = [
      {
        "salonName": "Luxe Salon",
        "service": "Haircut",
        "date": "Nov 25, 2023",
        "time": "10:00 AM",
        "status": "Confirmed",
        "price": "25",
      },
      {
        "salonName": "Urban Cuts",
        "service": "Beard Trim",
        "date": "Oct 12, 2023",
        "time": "02:00 PM",
        "status": "Completed",
        "price": "15",
      },
    ];

    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: AppConfig.adaptiveSurface(context),
        foregroundColor: AppConfig.adaptiveTextColor(context),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final isCompleted = booking['status'] == 'Completed';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppDecorations.glassPanel(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['salonName']!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking['status']!,
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${booking['service']} • \$${booking['price']}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppConfig.adaptiveTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${booking['date']} at ${booking['time']}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConfig.adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // Rate & Review
                      },
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text("Rate & Review"),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
