import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/screens/business/reviews_page.dart';
import 'package:walkinsalonapp/screens/business/settings_page.dart';
import '../../business_logic/discounts.dart';

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
          const SizedBox(height: 32),
          _buildMenuCard(
            context,
            title: "Log Out",
            icon: Icons.logout_rounded,
            color: AppColors.error,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
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
