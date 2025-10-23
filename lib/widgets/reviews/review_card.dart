import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/core/app_config.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: AppDecorations.glassPanel(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review["customerName"] ?? "Anonymous",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  (review["createdAt"] as Timestamp?) != null
                      ? review["createdAt"].toDate().toString().split(" ").first
                      : "",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppConfig.adaptiveTextColor(context).withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Barber
            Text(
              "Barber: ${review["barberName"] ?? "N/A"}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppConfig.adaptiveTextColor(context).withOpacity(0.7),
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
                  color: AppColors.warning,
                  size: 22,
                );
              }),
            ),
            const SizedBox(height: 10),

            // Comment
      Text(review["comment"] ?? "",
        style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),

            // Reply Section
            if (review["reply"] == null || review["reply"].toString().isEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onReply(reviewId),
                  icon: const Icon(Icons.reply, color: AppColors.secondary),
                  label: const Text("Reply"),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConfig.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.business, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Owner Reply:",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(review["reply"], style: Theme.of(context).textTheme.bodySmall),
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
