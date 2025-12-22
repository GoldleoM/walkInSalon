import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/services/appointment_services.dart';
import 'package:walkinsalonapp/widgets/dialogs/appointments/edit_appointment_dialog.dart';
import 'package:walkinsalonapp/widgets/appointment/appointment_card.dart';
import 'package:walkinsalonapp/screens/business/session_timer_page.dart';
import 'package:walkinsalonapp/models/booking_model.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final String businessId;
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    businessId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _editAppointment(String docId, Map<String, dynamic> data) async {
    if (data.containsKey('action')) {
      final action = data['action'];

      try {
        if (action == 'accept') {
          await _appointmentService.acceptAppointment(docId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Appointment Accepted!")),
            );
          }
        } else if (action == 'decline') {
          // In a real app, maybe show a confirmation dialog first
          await _appointmentService.declineAppointment(docId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Appointment Declined.")),
            );
          }
        } else if (action == 'open_session') {
          // Navigate to Stopwatch Page
          final doc = data['doc'] as DocumentSnapshot;
          final booking = BookingModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionTimerPage(booking: booking, docId: docId),
            ),
          );
        } else if (action == 'complete') {
          // Fallback for direct "End" from table if needed, though Timer Page handles this mostly now
          await _appointmentService.completeAppointment(docId);
        } else if (action == 'no_show') {
          await _appointmentService.markAsNoShow(docId);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Marked as No Show.")));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
      return;
    }

    // Default: Open Edit Dialog
    await showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(docId: docId, data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: AppConfig.adaptiveSurface(context),
        foregroundColor: AppConfig.adaptiveTextColor(context),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentService.getAppointments(businessId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No appointments yet",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          final allDocs = snapshot.data!.docs;

          // Split into Active (Pending, Confirmed, In Progress) and Past (Completed, Cancelled, No Show)
          final activeDocs = allDocs.where((doc) {
            final s = (doc['status'] as String? ?? '').toLowerCase();
            return s == 'pending' || s == 'confirmed' || s == 'in_progress';
          }).toList();

          final pastDocs = allDocs.where((doc) {
            final s = (doc['status'] as String? ?? '').toLowerCase();
            return s == 'completed' || s == 'cancelled' || s == 'no_show';
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔴 Active Appointments
                Text(
                  "UPCOMING & ACTIVE",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                if (activeDocs.isNotEmpty)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: activeDocs.length,
                    itemBuilder: (context, index) {
                      return AppointmentCard(
                        doc: activeDocs[index],
                        onAction: _editAppointment,
                      );
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 40,
                            color: colors.onSurface.withOpacity(0.2),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "No active appointments.\nRelax and wait for walk-ins!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // ⚫ Past Appointments
                if (pastDocs.isNotEmpty) ...[
                  Text(
                    "PAST HISTORY",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: pastDocs.length,
                    itemBuilder: (context, index) {
                      return Opacity(
                        opacity: 0.7,
                        child: AppointmentCard(
                          doc: pastDocs[index],
                          onAction: _editAppointment,
                        ),
                      );
                    },
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No past history.",
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
