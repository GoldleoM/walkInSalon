import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String customerId;
  final String businessId;
  final String salonName;
  final String salonAddress;
  final String barberId;
  final String? barberName; // New field
  final String serviceId;
  final String serviceName;
  final DateTime date;
  final String time; // e.g. "10:00 AM"
  final DateTime? startAt; // Combined Date + Time for efficient sorting
  final String status; // pending, confirmed, completed, cancelled
  final double totalPrice;
  final String? customerName;
  final String? customerPhoneNumber;
  final int durationMinutes;
  final DateTime? realStartTime;
  final DateTime? realEndTime;
  final bool isAutoAssigned; // New field

  BookingModel({
    required this.id,
    required this.customerId,
    required this.businessId,
    this.salonName = '',
    this.salonAddress = '',
    required this.barberId,
    this.barberName,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    this.startAt,
    required this.status,
    required this.totalPrice,
    this.customerName,
    this.customerPhoneNumber,
    this.durationMinutes = 30,
    this.realStartTime,
    this.realEndTime,
    this.isAutoAssigned = false,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      customerId: map['customerId'] ?? '',
      businessId: map['businessId'] ?? '',
      salonName: map['salonName'] ?? '',
      salonAddress: map['salonAddress'] ?? '',
      barberId: map['barberId'] ?? '',
      barberName: map['barberName'],
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      customerName: map['customerName'],
      customerPhoneNumber: map['customerPhoneNumber'],
      durationMinutes: map['durationMinutes'] ?? 30,
      startAt: map['startAt'] != null
          ? (map['startAt'] as Timestamp).toDate()
          : null,
      realStartTime: map['realStartTime'] != null
          ? (map['realStartTime'] as Timestamp).toDate()
          : null,
      realEndTime: map['realEndTime'] != null
          ? (map['realEndTime'] as Timestamp).toDate()
          : null,
      isAutoAssigned: map['isAutoAssigned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'businessId': businessId,
      'salonName': salonName,
      'salonAddress': salonAddress,
      'barberId': barberId,
      'barberName': barberName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'totalPrice': totalPrice,
      'customerName': customerName,
      'customerPhoneNumber': customerPhoneNumber,
      'durationMinutes': durationMinutes,
      'createdAt': FieldValue.serverTimestamp(),
      'isAutoAssigned': isAutoAssigned, // Save it
      if (startAt != null) 'startAt': Timestamp.fromDate(startAt!),
      if (realStartTime != null)
        'realStartTime': Timestamp.fromDate(realStartTime!),
      if (realEndTime != null) 'realEndTime': Timestamp.fromDate(realEndTime!),
    };
  }
}
