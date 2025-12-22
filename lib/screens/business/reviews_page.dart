import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/widgets/reviews/review_card.dart';
import 'package:walkinsalonapp/widgets/dialogs/reviews/reply_dialog.dart';
import 'package:walkinsalonapp/services/database_seeder.dart';
import 'package:walkinsalonapp/widgets/custom_loader.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late String businessId;
  bool _isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      businessId = user.uid;

      final snapshot = await _firestore
          .collection('reviews')
          .where('businessId', isEqualTo: businessId)
          .get();

      final docs = snapshot.docs;
      // Client-side sort to avoid missing index issues
      docs.sort((a, b) {
        final t1 = a.data()['createdAt'] as Timestamp?;
        final t2 = b.data()['createdAt'] as Timestamp?;
        if (t1 == null) return 1;
        if (t2 == null) return -1;
        return t2.compareTo(t1); // Descending
      });

      setState(() {
        _reviews = docs;
      });
    } catch (e) {
      debugPrint("Error loading reviews: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load reviews: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _replyToReview(String reviewId, String replyText) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'reply': replyText,
        'repliedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to reply: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post reply: $e")));
    }
  }

  void _openReplyDialog(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => ReplyDialog(
        onSubmit: (reply) async {
          await _replyToReview(reviewId, reply);
          await _loadReviews();
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Reply posted!")));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: const Center(child: CustomLoader(size: 80, isOverlay: false)),
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          "Customer Reviews",
          style: textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            tooltip: 'Seed Reviews',
            onPressed: () async {
              if (businessId.isEmpty) return;
              setState(() => _isLoading = true);
              try {
                await DatabaseSeeder().seedReviews(businessId);
                await _loadReviews();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reviews seeded successfully!"),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to seed reviews: $e")),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
          ),
        ],
      ),
      body: _reviews.isEmpty
          ? Center(
              child: Text(
                "No reviews yet",
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.padding),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final reviewDoc = _reviews[index];
                return ReviewCard(
                  review: reviewDoc.data(),
                  reviewId: reviewDoc.id,
                  onReply: _openReplyDialog,
                );
              },
            ),
    );
  }
}
