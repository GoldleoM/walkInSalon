import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/screens/business/business_details_page.dart';
import 'package:walkinsalonapp/screens/business/business_dashboard_page.dart';
import 'package:walkinsalonapp/screens/customer/home/customer_home_screen.dart';
import 'package:walkinsalonapp/screens/intro/intro_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getRoleBasedPage(User user) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!snapshot.exists) return const LoginPage();

      final role = snapshot.data()?['role'];

      if (role == 'business_pending') {
        return const BusinessDetailsPage();
      } else if (role == 'business') {
        return const BusinessDashboardPage();
      } else if (role == 'customer') {
        return const CustomerHomeScreen();
      } else {
        return const LoginPage();
      }
    } catch (e) {
      debugPrint('AuthWrapper error: $e');
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 While checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context, 'Checking login...');
        }

        // 🚫 Not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          // Changed from LoginPage() to IntroPage()
          return const IntroPage();
        }

        // ✅ Logged in — determine role
        return FutureBuilder<Widget>(
          future: _getRoleBasedPage(snapshot.data!),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen(context, 'Loading your dashboard...');
            } else if (roleSnapshot.hasError) {
              return Scaffold(
                backgroundColor: colors.surface,
                body: Center(
                  child: Text(
                    'Something went wrong!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            } else {
              return roleSnapshot.data!;
            }
          },
        );
      },
    );
  }

  /// 🌀 Centralized loading screen — matches your theme
  Widget _buildLoadingScreen(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎞️ Replace this with your loading GIF or logo animation later
            Image.asset(AppImages.logo, width: 100, height: 100),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
