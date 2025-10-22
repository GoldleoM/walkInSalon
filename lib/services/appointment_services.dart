import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Stream appointments for a given business
  Stream<QuerySnapshot> getAppointments(String businessId) {
    return _firestore
        .collection('appointments')
        .where('businessId', isEqualTo: businessId)
        .orderBy('startAt')
        .snapshots();
  }

  /// 🔹 Update appointment details (time & status)
  Future<void> updateAppointment({
    required String docId,
    required DateTime newTime,
    required String status,
  }) async {
    await _firestore.collection('appointments').doc(docId).update({
      'startAt': Timestamp.fromDate(newTime),
      'status': status,
    });
  }

  /// 🔹 Optional: Delete appointment (if needed later)
  Future<void> deleteAppointment(String docId) async {
    await _firestore.collection('appointments').doc(docId).delete();
  }
}
