import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/business_dashboard_service.dart';
import 'package:walkinsalonapp/pages/appointments_page.dart';
import 'upcoming_appointments_widget.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  Future<void> _onRefresh() async {
    // Simulate a short refresh delay and trigger rebuild.
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('businesses')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final salonName = data['salonName'] ?? 'Your Salon';
        final avgRating = (data['avgRating'] ?? 0).toDouble();
        final isSalonOpen = data['isOpen'] ?? true;
        final barbers = (data['barbers'] as List?) ?? [];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            displacement: 60,
            backgroundColor: AppConfig.adaptiveSurface(context),
            color: AppColors.secondary,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, $salonName 👋",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // 📊 Stats cards with blur
                  _buildStats(context, uid, avgRating, barbers.length, isSalonOpen),

                  const SizedBox(height: 40),

                  // 💈 Barber Availability Section
                  Text(
                    "Barber Availability",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (barbers.isEmpty)
                    Text(
                      "No barbers added yet.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: AppConfig
                                  .adaptiveTextColor(context)
                                  .withOpacity(0.6)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: barbers.length,
                      itemBuilder: (context, index) {
                        final barber = barbers[index] as Map<String, dynamic>;
                        final isAvailable = barber["available"] ?? true;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: AppDecorations.glassPanel(context),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: Text(
                                (barber["name"] ?? "?")[0].toUpperCase(),
                                style: TextStyle(color: AppColors.darkTextPrimary),
                              ),
                            ),
                            title: Text(barber["name"] ?? "Unnamed"),
                            subtitle: Text(
                              (barber["specialties"] is List)
                                  ? (barber["specialties"] as List).join(", ")
                                  : "No speciality",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppConfig.adaptiveTextColor(context).withOpacity(0.6)),
                            ),
                            trailing: Switch(
                              value: isAvailable,
                              activeThumbColor: AppColors.success,
                              onChanged: (val) async {
                                final newList = [...barbers];
                                newList[index]["available"] = val;
                                await FirebaseFirestore.instance
                                    .collection('businesses')
                                    .doc(uid)
                                    .update({"barbers": newList});
                              },
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  // 📅 Upcoming Appointments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Appointments",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppointmentsPage(),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        label: const Text("View All"),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 📋 Responsive Upcoming Appointments
                  const UpcomingAppointmentsWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // (keep your _buildStats, _glassStatCard, _glassStatusCard unchanged)
}


  // === GLASS STATS CARDS ===
  Widget _buildStats(
    BuildContext context,
    String uid,
    double avgRating,
    int barbersCount,
    bool isOpen,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('businessId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final totalBookings = snapshot.data?.docs.length ?? 0;

        final cards = [
          _glassStatCard(
            context: context,
            title: "Total Bookings",
            value: "$totalBookings",
            icon: Icons.calendar_today,
            color: AppColors.primary,
          ),
          _glassStatCard(
            context: context,
            title: "Avg Rating",
            value: "${avgRating.toStringAsFixed(1)} ⭐",
            icon: Icons.star,
            color: AppColors.warning,
          ),
          _glassStatCard(
            context: context,
            title: "Total Barbers",
            value: "$barbersCount",
            icon: Icons.people,
            color: AppColors.secondary,
          ),
          _glassStatusCard(context, uid, isOpen),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            final crossAxisCount =
                isWide ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
            final cardWidth =
                (constraints.maxWidth / crossAxisCount) - 20;

            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: cards
                  .map((c) => SizedBox(width: cardWidth, child: c))
                  .toList(),
            );
          },
        );
      },
    );
  }

  // === REUSABLE GLASS CARD ===
  Widget _glassStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: AppDecorations.glassPanel(context),
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    AppConfig.adaptiveTextColor(context).withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  // === GLASS SALON STATUS CARD ===
  Widget _glassStatusCard(BuildContext context, String uid, bool isOpen) {
    return Container(
      decoration: AppDecorations.glassPanel(context),
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.padding, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Salon Status",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                isOpen ? "Salon is Open 🟢" : "Salon is Closed 🔴",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isOpen ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          Switch(
            value: isOpen,
            activeThumbColor: AppColors.success,
            inactiveThumbColor: AppColors.error,
            onChanged: (val) async {
              await BusinessDashboardService.toggleSalonStatus(uid, val);
            },
          ),
        ],
      ),
    );
  }
  
