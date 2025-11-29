import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class UpcomingAppointmentsWidget extends StatelessWidget {
  const UpcomingAppointmentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('businessId', isEqualTo: uid)
          .orderBy('startAt')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Text(
            "No upcoming appointments.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConfig.adaptiveTextColor(
                context,
              ).withValues(alpha: 0.6),
            ),
          );
        }

        return isPhone
            ? Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final startAt =
                      (data['startAt'] as Timestamp?)?.toDate() ??
                      DateTime.now();
                  final timeStr = DateFormat('MMM d, h:mm a').format(startAt);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: AppDecorations.glassPanel(context),
                    child: ListTile(
                      title: Text(data['customerName'] ?? '-'),
                      subtitle: Text("${data['service']} at $timeStr"),
                      trailing: Text(
                        (data['status'] ?? '').toString(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Barber')),
                    DataColumn(label: Text('Service')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final startAt =
                        (data['startAt'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(DateFormat('MMM d, h:mm a').format(startAt)),
                        ),
                        DataCell(Text(data['customerName'] ?? '-')),
                        DataCell(Text(data['barberName'] ?? '-')),
                        DataCell(Text(data['service'] ?? '-')),
                        DataCell(Text(data['status'] ?? '-')),
                      ],
                    );
                  }).toList(),
                ),
              );
      },
    );
  }
}
