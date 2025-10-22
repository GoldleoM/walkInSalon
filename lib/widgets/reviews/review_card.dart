import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final String reviewId;
  final Function(String) onReply;

  const ReviewCard({
    super.key,
    required this.review,
    required this.reviewId,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review["customerName"] ?? "Anonymous",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  (review["createdAt"] as Timestamp?) != null
                      ? review["createdAt"].toDate().toString().split(" ").first
                      : "",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Barber
            Text(
              "Barber: ${review["barberName"] ?? "N/A"}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),

            // Stars
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < (review["rating"] ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 22,
                );
              }),
            ),
            const SizedBox(height: 10),

            // Comment
            Text(review["comment"] ?? "", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),

            // Reply Section
            if (review["reply"] == null || review["reply"].toString().isEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onReply(reviewId),
                  icon: const Icon(Icons.reply, color: Colors.blue),
                  label: const Text("Reply"),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.business, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Owner Reply:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(review["reply"], style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
