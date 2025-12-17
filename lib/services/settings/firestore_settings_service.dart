import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadBusinessData(String userId) async {
    final doc = await _firestore.collection('businesses').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<Map<String, dynamic>> loadUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<void> saveBusinessData({
    required String userId,
    required String salonName,
    required String phone,
    required String address,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? coverUrl,
    List<Map<String, dynamic>>? services,
  }) async {
    await _firestore.collection('businesses').doc(userId).set({
      'salonName': salonName,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'profileImage': logoUrl,
      'coverImage': coverUrl,
      if (services != null) 'services': services,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveUserEmail(String userId, String email) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
    }, SetOptions(merge: true));
  }
}
