import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 📦 Pages
import 'package:walkinsalonapp/pages/appointments_page.dart';
import 'barber_management_page.dart';
import '../buisness/discounts.dart';
import 'reviews_page.dart';
import 'settings_page.dart';

// 🧩 Widgets
import 'package:walkinsalonapp/widgets/dashboard/drawer_item.dart';
import 'package:walkinsalonapp/widgets/dashboard/dashboard_cards.dart';
import 'package:walkinsalonapp/widgets/dashboard/appointments_dashboard_table.dart';

// ⚙️ Services
import 'package:walkinsalonapp/services/business_dashboard_service.dart';

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key});

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    BusinessDashboardService.updateAverageRating(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 165, 243),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('businesses')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            return Text('${data['salonName'] ?? 'Your Salon'}');
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('businesses')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final imageUrl = data['profileImage'] ?? '';

                return CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                );
              },
            ),
          ),
        ],
      ),

      // 📱 Drawer Section
      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final coverUrl = data['coverImage'] ?? '';
          final profileUrl = data['profileImage'] ?? '';
          final salonName = data['salonName'] ?? 'Your Salon';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      coverUrl.isNotEmpty
                          ? Image.network(coverUrl, fit: BoxFit.cover)
                          : Container(color: Colors.black),
                      Container(color: Colors.black.withOpacity(0.25)),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1.7, sigmaY: 1.7),
                            child: Container(
                              color: Colors.black.withOpacity(0.35),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: profileUrl.isNotEmpty
                                        ? NetworkImage(profileUrl)
                                        : null,
                                    child: profileUrl.isEmpty
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      salonName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                buildDrawerItem(context, Icons.calendar_today, "Appointments",
                    const AppointmentsPage()),
                buildDrawerItem(context, Icons.people, "Barber Management",
                    const BarberManagementPage()),
                buildDrawerItem(context, Icons.discount, "Discounts",
                    const DiscountsPage()),
                buildDrawerItem(context, Icons.reviews, "Reviews",
                    const ReviewsPage()),
                buildDrawerItem(context, Icons.settings, "Settings",
                    const BusinessSettingsPage()),
              ],
            ),
          );
        },
      ),

      // 📊 Dashboard Body
      body: StreamBuilder<DocumentSnapshot>(
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, $salonName 👋",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // 🔢 Stats Section
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('businessId', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, bookingSnapshot) {
                      final totalBookings =
                          bookingSnapshot.data?.docs.length ?? 0;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          buildStatCard("Total Bookings", "$totalBookings",
                              Icons.calendar_today, Colors.blue),
                          buildStatCard("Avg Rating",
                              "${avgRating.toStringAsFixed(1)} ⭐", Icons.star, Colors.orange),
                          buildStatCard("Total Barbers", "${barbers.length}",
                              Icons.people, Colors.teal),
                          buildStatusCard(isSalonOpen, (val) async {
                            await BusinessDashboardService.toggleSalonStatus(
                                uid, val);
                          }),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // 💈 Barber Availability
                  const Text(
                    "Barber Availability",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (barbers.isEmpty)
                    const Text(
                      "No barbers added yet.",
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: barbers.length,
                      itemBuilder: (context, index) {
                        final barber = barbers[index] as Map<String, dynamic>;
                        final isAvailable = barber["available"] ?? true;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Text(
                                (barber["name"] ?? "?")[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(barber["name"] ?? "Unnamed"),
                            subtitle: Text(
                              (barber["specialties"] is List)
                                  ? (barber["specialties"] as List).join(", ")
                                  : "No speciality",
                            ),
                            trailing: Switch(
                              value: isAvailable,
                              activeThumbColor: Colors.green,
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

                  // 📅 Upcoming Appointments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Upcoming Appointments",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                          foregroundColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  buildAppointmentsTable(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
