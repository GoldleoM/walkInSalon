import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Cancelled":
        return Colors.redAccent;
      default:
        return Colors.grey;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: const Color(0xFF023047),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentService.getAppointments(businessId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No appointments yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
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
