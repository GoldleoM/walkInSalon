import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/booking_model.dart';
import 'package:walkinsalonapp/auth/login/login_page.dart';
import 'package:walkinsalonapp/widgets/review/review_dialog.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppConfig.adaptiveBackground(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: AppConfig.adaptiveTextColor(
                  context,
                ).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text("Login to see your bookings"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: AppConfig.adaptiveSurface(context),
        foregroundColor: AppConfig.adaptiveTextColor(context),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments') // ✅ Correct collection
            .where('customerId', isEqualTo: user.uid)
            .orderBy('startAt', descending: true) // ✅ Sort by new startAt field
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: AppConfig.adaptiveTextColor(
                      context,
                    ).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No bookings yet",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConfig.adaptiveTextColor(
                        context,
                      ).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final booking = BookingModel.fromMap(
                docs[index].data() as Map<String, dynamic>,
                docs[index].id,
              );
              final isCompleted = booking.status == 'completed';
              final isCancelled = booking.status == 'cancelled';
              final isPending = booking.status == 'pending';

              Color statusColor;
              if (isCompleted) {
                statusColor = AppColors.success;
              } else if (isCancelled) {
                statusColor = AppColors.error;
              } else if (isPending) {
                statusColor = AppColors.warning;
              } else {
                statusColor = AppColors.primary;
              }

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
                        Expanded(
                          child: Text(
                            booking.salonName.isNotEmpty
                                ? booking.salonName
                                : "Unknown Salon",
                            style: Theme.of(context).textTheme.titleMedium
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
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${booking.serviceName} • ₹${booking.totalPrice}",
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
                          "${DateFormat('MMM dd, yyyy').format(booking.date)} at ${booking.time}",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  ReviewDialog(businessId: booking.businessId),
                            );
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
          );
        },
      ),
    );
  }
}
