import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/services/customer_auth_service.dart';

// 1. Service Provider (Dependency Injection)
final authServiceProvider = Provider<CustomerAuthService>((ref) {
  return CustomerAuthService();
});

// 2. Auth State Provider (Stream of User?)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 3. User Role Provider (Async Value of Role String)
final currentUserRoleProvider = FutureProvider.autoDispose<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) return null;
    return snapshot.data()?['role'] as String?;
  } catch (e) {
    return null;
  }
});
