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
  /// If status changes to 'completed', updates business stats (lifetime bookings, revenue).
  Future<void> updateAppointment({
    required String docId,
    required DateTime newTime,
    required String status,
    String? barberId, // New
    String? barberName, // New
  }) async {
    final apptRef = _firestore.collection('appointments').doc(docId);

    await _firestore.runTransaction((transaction) async {
      final apptDoc = await transaction.get(apptRef);
      if (!apptDoc.exists) throw Exception("Appointment not found");

      final oldStatus = apptDoc.data()?['status'] as String?;
      final businessId = apptDoc.data()?['businessId'] as String;
      final price = (apptDoc.data()?['totalPrice'] ?? 0).toDouble();

      // Update Appointment
      final Map<String, dynamic> updateData = {
        'startAt': Timestamp.fromDate(newTime),
        'status': status,
      };

      if (barberId != null) updateData['barberId'] = barberId;
      if (barberName != null) updateData['barberName'] = barberName;

      transaction.update(apptRef, updateData);

      // Update Business Stats if completing for the first time
      // ... (rest of the logic)

      // Update Business Stats if completing for the first time
      if (status == 'completed' && oldStatus != 'completed') {
        final businessRef = _firestore.collection('businesses').doc(businessId);
        transaction.update(businessRef, {
          'lifetimeBookings': FieldValue.increment(1),
          'totalRevenue': FieldValue.increment(price),
        });
      }
    });
  }

  /// 🚀 Start the sessions
  Future<void> startAppointment(String docId) async {
    await _firestore.collection('appointments').doc(docId).update({
      'status': 'in_progress',
      'realStartTime': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Complete status and record end time
  Future<void> completeAppointment(String docId) async {
    final apptRef = _firestore.collection('appointments').doc(docId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(apptRef);
      if (!snapshot.exists) return; // Should not happen

      final data = snapshot.data()!;
      final oldStatus = data['status'];
      final price = (data['totalPrice'] ?? 0).toDouble();
      final businessId = data['businessId'];

      transaction.update(apptRef, {
        'status': 'completed',
        'realEndTime': FieldValue.serverTimestamp(),
      });

      // Update Business Stats (Only if not already completed)
      if (oldStatus != 'completed') {
        final businessRef = _firestore.collection('businesses').doc(businessId);
        transaction.update(businessRef, {
          'lifetimeBookings': FieldValue.increment(1),
          'totalRevenue': FieldValue.increment(price),
        });
      }
    });
  }

  /// ❌ Mark as No Show
  Future<void> markAsNoShow(String docId) async {
    await _firestore.collection('appointments').doc(docId).update({
      'status': 'no_show', // Treated as cancelled for availability
    });
  }

  /// ✅ Accept Appointment (Pending -> Confirmed)
  Future<void> acceptAppointment(String docId) async {
    await _firestore.collection('appointments').doc(docId).update({
      'status': 'confirmed',
    });
  }

  /// ❌ Decline Appointment (Pending -> Cancelled)
  Future<void> declineAppointment(String docId) async {
    await _firestore.collection('appointments').doc(docId).update({
      'status': 'cancelled',
    });
  }

  /// 🔹 Optional: Delete appointment (if needed later)
  Future<void> deleteAppointment(String docId) async {
    await _firestore.collection('appointments').doc(docId).delete();
  }
}
