import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/services/review_service.dart';

class ReviewDialog extends StatefulWidget {
  final String businessId;

  const ReviewDialog({super.key, required this.businessId});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _commentController = TextEditingController();
  final _reviewService = ReviewService();
  double _rating = 5.0;
  bool _isLoading = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final review = await _reviewService.getExistingReview(
        widget.businessId,
        user.uid,
      );
      if (review != null && mounted) {
        setState(() {
          _rating = (review['rating'] ?? 5.0).toDouble();
          _commentController.text = review['comment'] ?? '';
        });
      }
    }
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please login to review")),
          );
        }
        return;
      }

      await _reviewService.submitReview(
        businessId: widget.businessId,
        customerId: user.uid,
        customerName: user.displayName ?? 'Anonymous',
        rating: _rating,
        comment: _commentController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Checking previous reviews..."),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text("Write a Review"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Rate your experience:"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: "Share your thoughts...",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitReview,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Submit"),
        ),
      ],
    );
  }
}
