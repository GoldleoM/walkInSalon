import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class AppointmentCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Function(String, Map<String, dynamic>) onAction;

  const AppointmentCard({super.key, required this.doc, required this.onAction});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blueAccent;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
      case 'no_show':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('MMM d, yyyy').format(ts.toDate());
  }

  String _formatTime(Map<String, dynamic> data) {
    if (data['startAt'] is Timestamp) {
      return DateFormat(
        'h:mm a',
      ).format((data['startAt'] as Timestamp).toDate());
    }
    return data['time'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final status = (data['status'] as String? ?? 'pending').toLowerCase();
    final statusColor = _getStatusColor(status);
    final isHistory = ['completed', 'cancelled', 'no_show'].contains(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppConfig.adaptiveSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: status == 'in_progress'
              ? Colors.blueAccent.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟢 Header: Time & Status
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(data),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "•  ${_formatDate(data['startAt'])}",
                      style: TextStyle(
                        color: statusColor.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📝 Body: Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Customer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['customerName'] ?? 'Guest Customer',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (data['serviceName'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                data['serviceName'],
                                style: TextStyle(
                                  color: AppConfig.adaptiveTextColor(
                                    context,
                                  ).withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Price
                    Text(
                      "₹${data['totalPrice'] ?? 0}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Barber Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConfig.adaptiveBackground(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SPECIALIST",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                data['barberName'] ??
                                    data['barberId'] ??
                                    'Any Professional',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (data['isAutoAssigned'] == true)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "Auto",
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 🔘 Actions (Only for non-history)
                if (!isHistory) ...[
                  const SizedBox(height: 20),
                  _buildActions(context, status, doc.id),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, String status, String docId) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => onAction(docId, {'action': 'decline'}),
              icon: const Icon(Icons.close),
              label: const Text("Decline"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onAction(docId, {'action': 'accept'}),
              icon: const Icon(Icons.check),
              label: const Text("Accept"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () =>
              onAction(docId, {'action': 'open_session', 'doc': doc}),
          icon: const Icon(Icons.play_arrow),
          label: const Text("Start Session"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () =>
              onAction(docId, {'action': 'open_session', 'doc': doc}),
          icon: const Icon(Icons.timer),
          label: const Text("Return to Timer (In Progress)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // distinct color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
