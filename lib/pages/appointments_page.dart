import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/services/appointment_services.dart';
import 'package:walkinsalonapp/widgets/dialogs/appointments/edit_appointment_dialog.dart';
import 'package:walkinsalonapp/widgets/appointment/appointments_table.dart';

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

  Color _statusColor(String status) {
    switch (status) {
      case "Confirmed":
        return AppColors.success;
      case "Pending":
        return AppColors.warning;
      case "Cancelled":
        return AppColors.error;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null || ts is! Timestamp) return "No time set";
    final date = ts.toDate();
    return DateFormat('MMM d, yyyy – hh:mm a').format(date);
  }

  Future<void> _editAppointment(String docId, Map<String, dynamic> data) async {
    await showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(docId: docId, data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
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
                      color: colors.onSurface.withOpacity(0.6),
                    ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AppointmentsTable(
                  docs: docs,
                  formatTimeStamp: _formatTimestamp,
                  statusColor: _statusColor,
                  editAppointment: _editAppointment,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
