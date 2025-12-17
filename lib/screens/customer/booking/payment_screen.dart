import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/booking_model.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:walkinsalonapp/screens/customer/booking/confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final SalonModel salon;
  final Map<String, dynamic> service;
  final DateTime date;
  final String time;
  final String? barberName;

  const PaymentScreen({
    super.key,
    required this.salon,
    required this.service,
    required this.date,
    required this.time,
    this.barberName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0: Card, 1: Cash
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: AppConfig.adaptiveSurface(context),
        foregroundColor: AppConfig.adaptiveTextColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧾 Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.glassPanel(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Summary",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow("Salon", widget.salon.salonName),
                  _buildSummaryRow(
                    "Service",
                    widget.service['name'] ?? "Unknown",
                  ),
                  _buildSummaryRow(
                    "Date",
                    DateFormat('MMM dd, yyyy').format(widget.date),
                  ),
                  _buildSummaryRow("Time", widget.time),
                  if (widget.barberName != null)
                    _buildSummaryRow("Barber", widget.barberName!),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${widget.service['price'] ?? '0'}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 💳 Payment Method
            Text(
              "Payment Method",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(0, "Credit/Debit Card", Icons.credit_card),
            const SizedBox(height: 12),
            _buildPaymentOption(1, "Pay at Salon", Icons.store),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to book an appointment")),
        );
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('appointments').doc();

      // Parse time to create startAt
      DateTime? startAt;
      try {
        final timeFormat = DateFormat("hh:mm a"); // e.g., 09:00 AM
        final timeDate = timeFormat.parse(widget.time);
        startAt = DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          timeDate.hour,
          timeDate.minute,
        );
      } catch (e) {
        debugPrint("Error parsing time: $e");
      }

      final booking = BookingModel(
        id: docRef.id,
        customerId: user.uid,
        businessId: widget.salon.uid,
        barberId: widget.barberName ?? '',
        serviceId: widget.service['id'] ?? '',
        serviceName: widget.service['name'] ?? '',
        date: widget.date,
        time: widget.time,
        startAt: startAt, // ✅ Correct field for business dashboard sorting
        status: 'pending',
        totalPrice: (widget.service['price'] is int)
            ? (widget.service['price'] as int).toDouble()
            : (widget.service['price'] as double? ?? 0.0),
      );

      await docRef.set(booking.toMap());

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
          (route) => route.isFirst, // Go back to home or keep home in stack?
          // ConfirmationScreen has a "Back to Home" button that does pushAndRemoveUntil.
          // So here we can just push.
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to book: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConfig.adaptiveTextColor(
                context,
              ).withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int value, String label, IconData icon) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppConfig.adaptiveSurface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppConfig.adaptiveTextColor(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppConfig.adaptiveTextColor(context),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
