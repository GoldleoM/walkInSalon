import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String salonId;
  final String salonName;
  final String salonLocation;
  final String userId; // The business owner user ID
  final String imageUrl;
  final String description;
  final List<String> likes; // List of user IDs who liked the post
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.salonLocation,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.likes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'salonName': salonName,
      'salonLocation': salonLocation,
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      id: docId,
      salonId: map['salonId'] ?? '',
      salonName: map['salonName'] ?? '',
      salonLocation: map['salonLocation'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
