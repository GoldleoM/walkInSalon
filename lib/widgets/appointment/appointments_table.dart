// lib/widgets/appointments_table.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef FormatTimestamp = String Function(Timestamp ts);
typedef StatusColor = Color Function(String status);
typedef EditAppointmentCallback = Future<void> Function(String docId, Map<String, dynamic> data);

class AppointmentsTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final FormatTimestamp formatTimeStamp;
  final StatusColor statusColor;
  final EditAppointmentCallback editAppointment;

  const AppointmentsTable({
    Key? key,
    required this.docs,
    required this.formatTimeStamp,
    required this.statusColor,
    required this.editAppointment,
  }) : super(key: key);

  String _safeFormattedTime(Map<String, dynamic> data) {
    final dynamic maybeTs = data['startAt'];
    if (maybeTs is Timestamp) {
      try {
        return formatTimeStamp(maybeTs);
      } catch (_) {
        // fallback formatting if user function throws
        final d = maybeTs.toDate();
        return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
      }
    }

    // If there is a separate field name used in some documents, try it:
    final dynamic alt = data['startTime'] ?? data['time'] ?? data['start_at'];
    if (alt is Timestamp) {
      final d = alt.toDate();
      return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
    }

    return "N/A";
  }

  String _safeStatus(Map<String, dynamic> data) {
    final s = data['status'];
    if (s is String && s.isNotEmpty) return s;
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No appointments yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Barber')),
          DataColumn(label: Text('Service')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Action')),
        ],
        rows: List<DataRow>.generate(docs.length, (index) {
          final doc = docs[index];
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final id = doc.id;

          final timeText = _safeFormattedTime(data);
          final customer = (data['customerName'] ?? '-') as String;
          final barber = (data['barberName'] ?? '-') as String;
          final service = (data['service'] ?? '-') as String;
          final status = _safeStatus(data);
          final color = statusColor(status);

          return DataRow(
            cells: [
              DataCell(Text("${index + 1}")),
              DataCell(Text(timeText)),
              DataCell(Text(customer)),
              DataCell(Text(barber)),
              DataCell(Text(service)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => editAppointment(id, data),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
