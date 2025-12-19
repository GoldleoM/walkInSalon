import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/models/booking_model.dart';
import 'package:intl/intl.dart';

class BusinessAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getAnalytics(String businessId) async {
    // 1. Fetch completed bookings
    final snapshot = await _firestore
        .collection('appointments')
        .where('businessId', isEqualTo: businessId)
        .where('status', isEqualTo: 'completed')
        .get();

    final bookings = snapshot.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList();

    // 2. Calculate Metrics

    // --- Unique Customers ---
    final uniqueCustomers = bookings.map((b) => b.customerId).toSet().length;

    // --- Total Revenue & AOV ---
    double totalRevenue = 0;
    for (var b in bookings) {
      totalRevenue += b.totalPrice;
    }
    final aov = bookings.isNotEmpty ? totalRevenue / bookings.length : 0.0;

    // --- Daily Earnings ---
    // Map<String, double>
    final Map<String, double> dailyEarnings = {};
    for (var b in bookings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(b.date);
      dailyEarnings[dateKey] = (dailyEarnings[dateKey] ?? 0) + b.totalPrice;
    }

    // --- Top Services ---
    final Map<String, int> serviceCounts = {};
    for (var b in bookings) {
      serviceCounts[b.serviceName] = (serviceCounts[b.serviceName] ?? 0) + 1;
    }
    // Sort and take top 5
    final topServices = serviceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // --- Peak Hours ---
    final Map<int, int> hourCounts = {};
    for (var b in bookings) {
      // Use startAt if available, else parse time string (fallback)
      int hour;
      if (b.startAt != null) {
        hour = b.startAt!.hour;
      } else {
        // Fallback parsing "10:00 AM" if startAt missing
        try {
          // Basic parse attempt
          hour = DateFormat.jm().parse(b.time).hour;
        } catch (_) {
          continue;
        }
      }
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    return {
      'uniqueCustomers': uniqueCustomers,
      'totalRevenue': totalRevenue,
      'aov': aov,
      'dailyEarnings': dailyEarnings,
      'topServices': topServices
          .take(5)
          .toList(), // List<MapEntry<String, int>>
      'peakHours': hourCounts,
      'totalBookings': bookings.length,
    };
  }
}
