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

  const AppointmentsTable({
    super.key,
    required this.docs,
    required this.formatTimeStamp,
    required this.statusColor,
    required this.editAppointment,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDark
                          ? AppColors.darkSecondary
                          : AppColors.primary,
                    ),
                    onPressed: () => editAppointment(id, data),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
