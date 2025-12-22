import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkinsalonapp/models/post_model.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/screens/customer/explore/widgets/post_card.dart';
import 'package:walkinsalonapp/screens/customer/salon/salon_details_screen.dart';
import 'package:walkinsalonapp/widgets/custom_loader.dart';

class FeedScreen extends ConsumerWidget {
  final int initialIndex;
  final List<PostModel> posts;

  const FeedScreen({
    super.key,
    required this.initialIndex,
    required this.posts,
  });

  Future<void> _navigateToSalon(BuildContext context, String salonId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) =>
          const Center(child: CustomLoader(size: 60, isOverlay: true)),
    );

    try {
      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(salonId)
          .get();

      if (context.mounted) Navigator.pop(context);

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
    final pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: pageController,
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
  }
}
