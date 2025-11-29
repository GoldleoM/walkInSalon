import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedSalons() async {
    final List<Map<String, dynamic>> dummySalons = [
      {
        'salonName': 'Luxe Salon & Spa',
        'address': '123 Fashion Ave, New York',
        'avgRating': 4.8,
        'image':
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'isOpen': true,
        'role': 'business',
        'services': [
          {'name': 'Men\'s Haircut', 'price': 30, 'duration': 30},
          {'name': 'Beard Trim', 'price': 20, 'duration': 20},
          {'name': 'Full Facial', 'price': 50, 'duration': 45},
        ],
        'barbers': [
          {
            'name': 'John Doe',
            'image': 'https://randomuser.me/api/portraits/men/1.jpg',
          },
          {
            'name': 'Jane Smith',
            'image': 'https://randomuser.me/api/portraits/women/2.jpg',
          },
        ],
      },
      {
        'salonName': 'Urban Cuts',
        'address': '456 Metro St, Brooklyn',
        'avgRating': 4.5,
        'image':
            'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'isOpen': true,
        'role': 'business',
        'services': [
          {'name': 'Haircut', 'price': 25, 'duration': 30},
          {'name': 'Shave', 'price': 15, 'duration': 15},
        ],
        'barbers': [
          {
            'name': 'Mike Ross',
            'image': 'https://randomuser.me/api/portraits/men/3.jpg',
          },
        ],
      },
      {
        'salonName': 'Glamour Studio',
        'address': '789 Broadway, Manhattan',
        'avgRating': 4.9,
        'image':
            'https://images.unsplash.com/photo-1521590832896-7bbc1e741d66?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'isOpen': false,
        'role': 'business',
        'services': [
          {'name': 'Hair Styling', 'price': 60, 'duration': 60},
          {'name': 'Makeup', 'price': 80, 'duration': 60},
        ],
        'barbers': [
          {
            'name': 'Sarah Lee',
            'image': 'https://randomuser.me/api/portraits/women/4.jpg',
          },
          {
            'name': 'Emily Blunt',
            'image': 'https://randomuser.me/api/portraits/women/5.jpg',
          },
        ],
      },
    ];

    try {
      final user = FirebaseAuth.instance.currentUser;
      print('Seeding data as user: ${user?.uid}');

      for (var salon in dummySalons) {
        await _firestore.collection('businesses').add(salon);
      }
      print('Seeding completed successfully');
    } catch (e) {
      print('Error seeding data: $e');
      rethrow;
    }
  }

  Future<void> seedReviews(String businessId) async {
    final List<Map<String, dynamic>> dummyReviews = [
      {
        'businessId': businessId,
        'customerName': 'Alice Johnson',
        'rating': 5.0,
        'comment': 'Amazing service! The best haircut I have ever had.',
        'createdAt': Timestamp.now(),
        'barberName': 'John Doe',
      },
      {
        'businessId': businessId,
        'customerName': 'Bob Smith',
        'rating': 4.0,
        'comment': 'Great atmosphere, but the wait was a bit long.',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'barberName': 'Jane Smith',
      },
      {
        'businessId': businessId,
        'customerName': 'Charlie Brown',
        'rating': 3.0,
        'comment': 'It was okay, nothing special.',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'barberName': 'Mike Ross',
      },
      {
        'businessId': businessId,
        'customerName': 'Diana Prince',
        'rating': 5.0,
        'comment': 'Absolutely loved it! Highly recommend.',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        'barberName': 'Sarah Lee',
      },
    ];

    try {
      print('Seeding reviews for business: $businessId');
      for (var review in dummyReviews) {
        await _firestore.collection('reviews').add(review);
      }
      print('Reviews seeding completed successfully');
    } catch (e) {
      print('Error seeding reviews: $e');
      rethrow;
    }
  }
}
