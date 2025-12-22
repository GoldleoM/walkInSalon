import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:walkinsalonapp/screens/customer/booking/payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walkinsalonapp/widgets/auth/login_modal.dart';
import 'package:walkinsalonapp/models/booking_model.dart';
import 'package:walkinsalonapp/services/time_slot_service.dart';

class BookingScreen extends StatefulWidget {
  final SalonModel salon;
  final Map<String, dynamic> service;

  const BookingScreen({super.key, required this.salon, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedBarberId;
  List<String> _availableTimeSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  Future<void> _fetchAvailableSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _selectedTime = null; // Reset selection when slots change
    });

    try {
      // 1. Fetch existing bookings for this date and salon
      // We'll fetch the whole day's bookings to be safe
      final startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('businessId', isEqualTo: widget.salon.uid)
          .where('startAt', isGreaterThanOrEqualTo: startOfDay)
          .where('startAt', isLessThan: endOfDay)
          //.where('status', whereIn: ['pending', 'confirmed']) // REMOVED: Fetch all to let Service handle 'completed' logic
          .get();

      final existingBookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();

      // 2. Generate slots
      final slots = TimeSlotService.generateAvailableSlots(
        date: _selectedDate,
        salon: widget.salon,
        serviceDurationMinutes:
            int.tryParse(widget.service['duration'].toString()) ?? 30,
        existingBookings: existingBookings,
        selectedBarberId: _selectedBarberId,
      );

      if (mounted) {
        setState(() {
          _availableTimeSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching slots: $e");
      if (mounted) {
        setState(() {
          _availableTimeSlots = [];
          _isLoadingSlots = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: AppConfig.adaptiveSurface(context),
        foregroundColor: AppConfig.adaptiveTextColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 Date Selection
            Text(
              "Select Date",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected =
                      date.day == _selectedDate.day &&
                      date.month == _selectedDate.month;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = null; // Reset time on date change
                        _fetchAvailableSlots();
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppConfig.adaptiveSurface(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppConfig.adaptiveTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppConfig.adaptiveTextColor(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 💈 Barber Selection
            if (widget.salon.barbers.isNotEmpty) ...[
              Text(
                "Select Professional",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.salon.barbers.length + 1, // +1 for "Any"
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // "Any Professional" Option
                      final isSelected = _selectedBarberId == null;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBarberId = null;
                          });
                          _fetchAvailableSlots();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppConfig.adaptiveSurface(context),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.people,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Any",
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppConfig.adaptiveTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final barber = widget.salon.barbers[index - 1];
                    final isSelected = _selectedBarberId == barber['name'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBarberId = barber['name'];
                        });
                        _fetchAvailableSlots();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConfig.adaptiveSurface(context),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  barber['profileImage'] ??
                                      'https://ui-avatars.com/api/?name=${barber['name']}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            barber['name'] ?? "Unknown",
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppConfig.adaptiveTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ⏰ Time Selection
            Text(
              "Select Time",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _isLoadingSlots
                ? const Center(child: CircularProgressIndicator())
                : _availableTimeSlots.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "No available slots for this date/barber.",
                      style: TextStyle(
                        color: AppConfig.adaptiveTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _availableTimeSlots.length,
                    itemBuilder: (context, index) {
                      final time = _availableTimeSlots[index];
                      final isSelected = time == _selectedTime;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppConfig.adaptiveSurface(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppConfig.adaptiveTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConfig.adaptiveSurface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConfig.adaptiveTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    "₹${widget.service['price'] ?? '0'}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedTime != null
                    ? () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          // Not logged in -> Show Login Modal
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withValues(alpha: 0.8),
                            builder: (context) =>
                                const LoginModal(fromIntro: false),
                          ).then((_) {
                            // After modal closes, check if user logged in
                            if (FirebaseAuth.instance.currentUser != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Login successful! You can now proceed.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              // Trigger a rebuild to enable the button
                              setState(() {});
                            }
                          });
                        } else {
                          // Allow booking
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                salon: widget.salon,
                                service: widget.service,
                                date: _selectedDate,
                                time: _selectedTime!,
                                barberName: _selectedBarberId,
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
