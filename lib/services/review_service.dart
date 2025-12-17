import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submits a review and updates the business's average rating transactionally.
  /// Enforces one review per customer per business.
  Future<void> submitReview({
    required String businessId,
    required String customerId,
    required String customerName,
    required double rating,
    required String comment,
  }) async {
    final salonRef = _firestore.collection('businesses').doc(businessId);
    // Use composite ID to ensure uniqueness
    final reviewRef = _firestore
        .collection('reviews')
        .doc('${businessId}_$customerId');

    await _firestore.runTransaction((transaction) async {
      final salonDoc = await transaction.get(salonRef);
      final reviewDoc = await transaction.get(reviewRef);

      if (!salonDoc.exists) {
        throw Exception("Salon not found");
      }

      final currentAvg = (salonDoc.data()?['avgRating'] ?? 0).toDouble();
      final currentCount = (salonDoc.data()?['totalReviews'] ?? 0).toInt();

      if (reviewDoc.exists) {
        // Update existing review
        final oldRating = (reviewDoc.data()?['rating'] ?? 0).toDouble();

        // Calculate new average: (OldSum - OldRating + NewRating) / Count
        // OldSum = currentAvg * currentCount
        final newAvg =
            ((currentAvg * currentCount) - oldRating + rating) / currentCount;

        transaction.update(salonRef, {'avgRating': newAvg});

        transaction.update(reviewRef, {
          'rating': rating,
          'comment': comment,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new review
        final newCount = currentCount + 1;
        final newAvg = ((currentAvg * currentCount) + rating) / newCount;

        transaction.update(salonRef, {
          'avgRating': newAvg,
          'totalReviews': newCount,
        });

        transaction.set(reviewRef, {
          'businessId': businessId,
          'customerId': customerId,
          'customerName': customerName,
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Checks if a user has already reviewed a business.
  Future<Map<String, dynamic>?> getExistingReview(
    String businessId,
    String customerId,
  ) async {
    final doc = await _firestore
        .collection('reviews')
        .doc('${businessId}_$customerId')
        .get();
    return doc.exists ? doc.data() : null;
  }
}
