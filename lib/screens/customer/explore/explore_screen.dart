import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:walkinsalonapp/providers/explore_provider.dart';
import 'package:walkinsalonapp/screens/customer/explore/widgets/post_card.dart';
import 'package:walkinsalonapp/screens/customer/salon/salon_details_screen.dart';

class ExploreScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(explorePostsProvider);

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: postsAsync.when(
        data: (posts) {
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
              // Invalidate to refresh (re-listen) if needed, basically a no-op for stream
              // but good for UX feel or forcing a reconnect if stream died
              return ref.refresh(explorePostsProvider.future);
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
