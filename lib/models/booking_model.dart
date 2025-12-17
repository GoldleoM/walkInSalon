import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String businessId;
  final String barberId;
  final String serviceId;
  final String serviceName;
  final DateTime date;
  final String time; // e.g. "10:00 AM"
  final DateTime? startAt; // Combined Date + Time for efficient sorting
  final String status; // pending, confirmed, completed, cancelled
  final double totalPrice;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.barberId,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    this.startAt,
    required this.status,
    required this.totalPrice,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      customerId: map['customerId'] ?? '',
      businessId: map['businessId'] ?? '',
      barberId: map['barberId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      startAt: map['startAt'] != null ? (map['startAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'businessId': businessId,
      'barberId': barberId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
      if (startAt != null) 'startAt': Timestamp.fromDate(startAt!),
    };
  }
}
