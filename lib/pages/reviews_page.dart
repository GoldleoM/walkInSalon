import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walkinsalonapp/widgets/reviews/review_card.dart';
import 'package:walkinsalonapp/widgets/dialogs/reviews/reply_dialog.dart';

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
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _reviews = snapshot.docs;
      });
    } catch (e) {
      debugPrint("Error loading reviews: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load reviews: $e")),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post reply: $e")),
      );
    }
  }

  void _openReplyDialog(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => ReplyDialog(
        onSubmit: (reply) async {
          await _replyToReview(reviewId, reply);
          await _loadReviews();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reply posted!")),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Customer Reviews"),
        backgroundColor: const Color(0xFF023047),
      ),
      body: _reviews.isEmpty
          ? const Center(child: Text("No reviews yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
