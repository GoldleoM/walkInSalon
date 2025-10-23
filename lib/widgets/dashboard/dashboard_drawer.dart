import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/pages/appointments_page.dart';
import 'package:walkinsalonapp/pages/reviews_page.dart';
import 'package:walkinsalonapp/pages/settings_page.dart';
import 'package:walkinsalonapp/pages/barber_management_page.dart';
import '../../buisness/discounts.dart';
import 'package:walkinsalonapp/widgets/dashboard/drawer_item.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class DashboardDrawer extends StatefulWidget {
  const DashboardDrawer({super.key});

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  Color _accentColor = AppColors.darkTextPrimary.withOpacity(0.12);

  Color _deriveSafeAccent(String imageUrl) {
    if (imageUrl.isEmpty) return AppColors.darkTextPrimary.withOpacity(0.12);
    int hash = 0;
    for (int i = 0; i < imageUrl.length; i++) {
      hash = (hash + imageUrl.codeUnitAt(i)) & 0xFFFFFFFF;
      hash = (hash + (hash << 10)) & 0xFFFFFFFF;
      hash ^= (hash >> 6);
    }
    hash = (hash + (hash << 3)) & 0xFFFFFFFF;
    hash ^= (hash >> 11);
    hash = (hash + (hash << 15)) & 0xFFFFFFFF;
    final r = 160 + (hash & 0x1F);
    final g = 150 + ((hash >> 5) & 0x1F);
    final b = 140 + ((hash >> 10) & 0x1F);
    return Color.fromARGB(50, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('businesses')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Drawer(
            child: Container(
              color: AppColors.darkTextPrimary.withOpacity(0.04),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final coverUrl = (data['coverImage'] ?? '') as String;
        final profileUrl = (data['profileImage'] ?? '') as String;
        final salonName = (data['salonName'] ?? 'Your Salon') as String;

        final version = (data['imageVersion'] ?? 0).toString();
        final bustedCoverUrl =
            coverUrl.isNotEmpty ? '$coverUrl?v=$version' : '';
        final bustedProfileUrl =
            profileUrl.isNotEmpty ? '$profileUrl?v=$version' : '';

        _accentColor = _deriveSafeAccent(bustedCoverUrl);

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width > 900 ? 340 : 300,
              decoration: BoxDecoration(
                color: _accentColor,
                border: Border.all(
                    color: AppColors.darkTextPrimary.withOpacity(0.18)),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(bustedCoverUrl, bustedProfileUrl, salonName),
                  Divider(
                      color: AppColors.darkTextPrimary.withOpacity(0.24),
                      indent: 12,
                      endIndent: 12),
                  buildDrawerItem(context, Icons.calendar_today_rounded,
                      "Appointments", const AppointmentsPage()),
                  buildDrawerItem(context, Icons.people_rounded,
                      "Barber Management", const BarberManagementPage()),
                  buildDrawerItem(context, Icons.discount_rounded, "Discounts",
                      const DiscountsPage()),
                  buildDrawerItem(context, Icons.reviews_rounded, "Reviews",
                      const ReviewsPage()),
                  buildDrawerItem(context, Icons.settings_rounded, "Settings",
                      const BusinessSettingsPage()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String coverUrl, String profileUrl, String salonName) {
    final Widget cover = coverUrl.isNotEmpty
        ? Image.network(coverUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Image.asset(AppConfig.images.defaultCover, fit: BoxFit.cover))
        : Image.asset(AppConfig.images.defaultCover, fit: BoxFit.cover);

    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                cover,
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black54],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'profile-avatar',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      backgroundImage: profileUrl.isNotEmpty
                          ? NetworkImage(profileUrl)
                          : null,
                      child: profileUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      salonName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 6)
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
