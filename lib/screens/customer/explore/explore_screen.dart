import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/post_model.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:walkinsalonapp/screens/customer/explore/widgets/post_card.dart';
import 'package:walkinsalonapp/screens/customer/salon/salon_details_screen.dart';
import 'package:walkinsalonapp/services/post_service.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  Future<void> _navigateToSalon(BuildContext context, String salonId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(salonId)
          .get();

      if (context.mounted) Navigator.pop(context); // Hide loading

      if (doc.exists && context.mounted) {
        final salon = SalonModel.fromMap(doc.data()!, doc.id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SalonDetailsScreen(salon: salon)),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Salon not found')));
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      debugPrint('Error fetching salon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for media feed
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        // Force hamburger/back visible on dark background if needed,
        // usually default is okay but styling helps
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: PostService().getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore_off,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet. check back later!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Stream updates automatically, but we can delay slightly to show interaction
              await Future.delayed(const Duration(seconds: 1));
            },
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  post: post,
                  onSalonTap: () => _navigateToSalon(context, post.salonId),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
