import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

typedef FormatTimestamp = String Function(Timestamp ts);
typedef StatusColor = Color Function(String status);
typedef EditAppointmentCallback =
    Future<void> Function(String docId, Map<String, dynamic> data);

class AppointmentsTable extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final FormatTimestamp formatTimeStamp;
  final StatusColor statusColor;
  final EditAppointmentCallback editAppointment;
  final bool showActions; // Add parameter

  const AppointmentsTable({
    super.key,
    required this.docs,
    required this.formatTimeStamp,
    required this.statusColor,
    required this.editAppointment,
    this.showActions = true, // Default to true
  });

  // ... (methods)

  String _safeFormattedTime(Map<String, dynamic> data) {
    final dynamic maybeTs = data['startAt'];
    if (maybeTs is Timestamp) {
      try {
        return formatTimeStamp(maybeTs);
      } catch (_) {
        final d = maybeTs.toDate();
        return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
      }
    }

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
      return Padding(
        padding: AppConfig.padding,
        child: Text(
          "No appointments yet",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: AppDecorations.glassPanel(context),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppConfig.adaptiveSurface(context).withValues(alpha: 0.8),
          ),
          headingTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          dataTextStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 13),
          columns: [
            const DataColumn(label: Text('#')),
            const DataColumn(label: Text('Time')),
            const DataColumn(label: Text('Customer')),
            const DataColumn(label: Text('Barber')),
            const DataColumn(label: Text('Service')),
            const DataColumn(label: Text('Status')),
            if (showActions) const DataColumn(label: Text('Action')),
          ],
          rows: List<DataRow>.generate(docs.length, (index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>? ?? {};

            final timeText = _safeFormattedTime(data);
            final customer = (data['customerName'] ?? '-') as String;
            final barber =
                (data['barberName'] ?? data['barberId'] ?? '-') as String;
            final service =
                (data['serviceName'] ?? data['service'] ?? '-') as String;

            final status = _safeStatus(data);
            final color = statusColor(status);

            return DataRow(
              color: status == 'in_progress'
                  ? WidgetStateProperty.all(
                      AppColors.primary.withValues(alpha: 0.1),
                    )
                  : null,
              cells: [
                DataCell(Text("${index + 1}")),
                DataCell(Text(timeText)),
                DataCell(Text(customer)),
                DataCell(Text(barber)),
                DataCell(Text(service)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Text(
                      status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                if (showActions) DataCell(_buildActions(context, doc, status)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    QueryDocumentSnapshot doc,
    String status,
  ) {
    status = status.toLowerCase();
    final docId = doc.id;

    // 1. Pending -> Accept / Decline
    if (status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            tooltip: 'Accept',
            onPressed: () => editAppointment(docId, {'action': 'accept'}),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: 'Decline',
            onPressed: () => editAppointment(docId, {'action': 'decline'}),
          ),
        ],
      );
    }

    // 2. Confirmed / In Progress -> Open Session Timer
    if (status == 'confirmed' || status == 'in_progress') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: status == 'in_progress'
              ? Colors.orange
              : AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 32),
        ),
        onPressed: () =>
            editAppointment(docId, {'action': 'open_session', 'doc': doc}),
        child: Text(status == 'in_progress' ? 'Resume' : 'Start'),
      );
    }

    // 3. Completed -> View Summary (or just simple edit for now)
    // 4. Cancelled/NoShow -> Just Edit
    return IconButton(
      icon: const Icon(Icons.edit, size: 20),
      onPressed: () => editAppointment(docId, {}),
    );
  }
}
