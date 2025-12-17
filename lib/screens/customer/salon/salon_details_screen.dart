import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:walkinsalonapp/screens/customer/salon/widgets/barber_selector.dart';
import 'package:walkinsalonapp/screens/customer/salon/widgets/service_list.dart';
import 'package:walkinsalonapp/screens/customer/booking/booking_screen.dart';
import 'package:walkinsalonapp/auth/login/login_page.dart';

class SalonDetailsScreen extends StatelessWidget {
  final SalonModel salon;

  const SalonDetailsScreen({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      body: CustomScrollView(
        slivers: [
          // 🖼️ Hero Image App Bar
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.width < 600
                ? MediaQuery.of(context).size.width * 9 / 16
                : 400,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: salon.imageUrl != null
                  ? Image.network(salon.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.secondary,
                      child: const Center(
                        child: Icon(Icons.store, size: 60, color: Colors.white),
                      ),
                    ),
            ),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ℹ️ Salon Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConfig.adaptiveBackground(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🖼️ Profile Image (Left of Name)
                      if (salon.profileImageUrl != null &&
                          salon.profileImageUrl!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppConfig.adaptiveSurface(context),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 35, // Bigger size (70px)
                            backgroundImage: NetworkImage(
                              salon.profileImageUrl!,
                            ),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salon.salonName,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    salon.rating.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.warning,
                                          fontSize: 14,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppConfig.adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          salon.address,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppConfig.adaptiveTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 💈 Barbers
                  BarberSelector(
                    barbers: salon.barbers,
                    onBarberSelected: (barber) {
                      // Show barber details or filter services?
                    },
                  ),
                  const SizedBox(height: 24),

                  // ✂️ Services Header
                  Text(
                    "Services",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 📋 Services List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return ServiceList(
                  services: salon.services,
                  onServiceSelected: (service) {
                    _handleBooking(context, service);
                  },
                );
              }
              return null;
            }, childCount: 1),
          ),

          // Extra padding at bottom
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConfig.adaptiveSurface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              _showServiceSelection(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Book Appointment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBooking(BuildContext context, Map<String, dynamic> service) {
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(salon: salon, service: service),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Required"),
          content: const Text(
            "You need to log in or sign up to book an appointment.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Log In / Sign Up"),
            ),
          ],
        ),
      );
    }
  }

  void _showServiceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConfig.adaptiveSurface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select a Service",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (salon.services.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No services available for booking."),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: salon.services.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final service = salon.services[index];
                      return ListTile(
                        title: Text(service['name'] ?? 'Unknown Service'),
                        subtitle: Text(
                          "₹${service['price'] ?? '0'} • ${service['duration'] ?? '30'} min",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context); // Close modal
                          _handleBooking(context, service);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
