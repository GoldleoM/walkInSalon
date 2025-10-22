import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pages/dashboard_buisness.dart';
import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/pages/placeholder_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getLandingPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    // Check Firestore role
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!snapshot.exists) {
      return const LoginPage();
    }

    final role = snapshot.data()?['role'];

    if (role == 'business') {
      return const BusinessDashboardPage();
    } else if (role == 'customer') {
      return const PlaceholderDashboard(title: 'Customer Dashboard');
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getLandingPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}
