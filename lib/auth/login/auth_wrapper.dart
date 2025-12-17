import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/providers/auth_provider.dart';
import 'package:walkinsalonapp/screens/business/business_dashboard_page.dart';
import 'package:walkinsalonapp/screens/business/business_details_page.dart';
import 'package:walkinsalonapp/screens/customer/home/customer_home_screen.dart';
import 'package:walkinsalonapp/screens/intro/intro_page.dart';
import 'login_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    // 1️⃣ Watch Auth State (Firebase User)
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // 🚫 Not logged in -> Show Intro
        if (user == null) {
          return const IntroPage();
        }

        // ✅ Logged in -> Check Role
        return ref.watch(currentUserRoleProvider).when(
          data: (role) {
            if (role == 'business_pending') {
              return const BusinessDetailsPage();
            } else if (role == 'business') {
              return const BusinessDashboardPage();
            } else if (role == 'customer') {
              return const CustomerHomeScreen();
            } else {
              // Role missing or unknown -> Login
              return const LoginPage();
            }
          },
          loading: () => _buildLoadingScreen(context, 'Loading dashboard...'),
          error: (err, stack) => Scaffold(
            backgroundColor: colors.surface,
            body: Center(child: Text('Error: $err')),
          ),
        );
      },
      loading: () => _buildLoadingScreen(context, 'Checking login...'),
      error: (err, stack) => Scaffold(
        backgroundColor: colors.surface,
        body: Center(child: Text('Auth Error: $err')),
      ),
    );
  }

  /// 🌀 Centralized loading screen
  Widget _buildLoadingScreen(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Image.asset(AppImages.logo, width: 100, height: 100),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
