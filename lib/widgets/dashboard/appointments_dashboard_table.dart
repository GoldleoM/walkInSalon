import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget buildAppointmentsTable() {
  final businessId = FirebaseAuth.instance.currentUser!.uid;

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('appointments')
        .where('businessId', isEqualTo: businessId)
        .orderBy('startAt')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No upcoming appointments.",
            style: TextStyle(color: Colors.black54),
          ),
        );
      }

      final docs = snapshot.data!.docs;

      return Container(
        width: double.infinity,
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
            final startAt = (data['startAt'] as Timestamp).toDate();
            final formattedTime =
                "${startAt.hour.toString().padLeft(2, '0')}:${startAt.minute.toString().padLeft(2, '0')}";

            return DataRow(cells: [
              DataCell(Text(formattedTime)),
              DataCell(Text(data['customerName'] ?? '-')),
              DataCell(Text(data['barberName'] ?? '-')),
              DataCell(Text(data['service'] ?? '-')),
              DataCell(Text(data['status'] ?? '-')),
            ]);
          }).toList(),
        ),
      );
    },
  );
}
