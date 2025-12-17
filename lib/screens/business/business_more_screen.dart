import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/screens/business/reviews_page.dart';
import 'package:walkinsalonapp/screens/business/settings_page.dart';
import 'package:walkinsalonapp/screens/business/discounts_page.dart';
import 'package:walkinsalonapp/auth/login/login_page.dart';

class BusinessMoreScreen extends StatelessWidget {
  const BusinessMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: Text(
          "More",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppConfig.adaptiveSurface(context),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMenuCard(
            context,
            title: "Reviews",
            icon: Icons.reviews_rounded,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewsPage()),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            title: "Discounts & Offers",
            icon: Icons.discount_rounded,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DiscountsPage()),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            title: "Business Settings",
            icon: Icons.settings_rounded,
            color: Colors.blueGrey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BusinessSettingsPage()),
            ),
          ),
          const SizedBox(height: 16),
          // 🛠️ Debug: Fix Ratings
          _buildMenuCard(
            context,
            title: "Recalculate Rating",
            icon: Icons.refresh_rounded,
            color: Colors.teal,
            onTap: () async {
              final scaffold = ScaffoldMessenger.of(context);
              scaffold.showSnackBar(
                const SnackBar(content: Text('Recalculating...')),
              );

              try {
                final uid = FirebaseAuth.instance.currentUser!.uid;

                // 1. Recalculate Ratings
                final reviewsSnapshot = await FirebaseFirestore.instance
                    .collection('reviews')
                    .where('businessId', isEqualTo: uid)
                    .get();

                final docs = reviewsSnapshot.docs;
                final totalReviews = docs.length;
                double sum = 0;
                for (var doc in docs) {
                  sum += (doc.data()['rating'] ?? 0).toDouble();
                }
                final avgRating = totalReviews > 0 ? sum / totalReviews : 0.0;

                // 2. Recalculate Business Stats (Bookings & Revenue)
                // Filter in-memory to match RevenueChart logic (safe against index lag/casing)
                final appointmentsSnapshot = await FirebaseFirestore.instance
                    .collection('appointments')
                    .where('businessId', isEqualTo: uid)
                    .get();

                final allAppts = appointmentsSnapshot.docs;
                int lifetimeBookings = 0;
                double totalRevenue = 0;

                for (var doc in allAppts) {
                  final data = doc.data();
                  // Lenient check: matches 'Completed' or 'completed'
                  final status = (data['status'] ?? '')
                      .toString()
                      .toLowerCase();
                  if (status == 'completed') {
                    lifetimeBookings++;
                    totalRevenue +=
                        (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
                  }
                }

                await FirebaseFirestore.instance
                    .collection('businesses')
                    .doc(uid)
                    .update({
                      'avgRating': avgRating,
                      'totalReviews': totalReviews,
                      'lifetimeBookings': lifetimeBookings,
                      'totalRevenue': totalRevenue,
                    });

                scaffold.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Updated: ${avgRating.toStringAsFixed(1)}⭐, $lifetimeBookings bookings, \$${totalRevenue.toStringAsFixed(0)}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 32),
          _buildMenuCard(
            context,
            title: "Log Out",
            icon: Icons.logout_rounded,
            color: AppColors.error,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: AppDecorations.glassPanel(context),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.error : null,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppConfig.adaptiveTextColor(context).withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
