import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/services/business_dashboard_service.dart';

// 1. Service Provider
final businessServiceProvider = Provider<BusinessDashboardService>((ref) {
  // BusinessDashboardService has static methods, so we might just use it as a utility 
  // or wrap it if we want to mock it later. 
  // For now, we return an instance if we made it non-static, 
  // but since it's static, we can just use the provider to semantic meaning.
  return BusinessDashboardService();
});

// 2. Business Info Stream
final businessInfoProvider = StreamProvider.autoDispose<DocumentSnapshot?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('businesses')
      .doc(user.uid)
      .snapshots();
});
