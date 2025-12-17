import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessDashboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 💾 Save or update business details
  Future<void> saveBusinessDetails(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No authenticated user");

    final businessId = user.uid;

    // Write to /businesses/{uid}
    await _firestore.collection('businesses').doc(businessId).set(
      {
        ...data,
        'businessId': businessId,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Also ensure /users/{uid} is updated to reflect business status
    await _firestore.collection('users').doc(businessId).set(
      {
        'role': 'business',
        'businessId': businessId,
        'businessSetupComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// ⭐ Recalculate and update the average rating for a business
  static Future<void> updateAverageRating(String businessId) async {
    final reviewsSnapshot = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reviews')
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    double total = 0;
    for (var doc in reviewsSnapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }

    final avg = total / reviewsSnapshot.docs.length;

    await _firestore.collection('businesses').doc(businessId).update({
      'avgRating': avg,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🏪 Toggle salon open/closed status
  static Future<void> toggleSalonStatus(String businessId, bool isOpen) async {
    await _firestore.collection('businesses').doc(businessId).update({
      'isOpen': isOpen,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
