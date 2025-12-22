import 'package:intl/intl.dart';
import 'package:walkinsalonapp/models/booking_model.dart';
import 'package:walkinsalonapp/models/salon_model.dart';
import 'package:flutter/material.dart';

class TimeSlotService {
  /// Generate available time slots for a given date, salon, and service duration.
  ///
  /// [date]: The selected date for booking.
  /// [salon]: The salon model containing operating hours and barbers.
  /// [serviceDurationMinutes]: The duration of the selected service.
  /// [existingBookings]: A list of existing bookings for that date.
  /// [selectedBarberId]: The ID (name) of the selected barber, or null for "Any".
  static List<String> generateAvailableSlots({
    required DateTime date,
    required SalonModel salon,
    required int serviceDurationMinutes,
    required List<BookingModel> existingBookings,
    String? selectedBarberId,
  }) {
    List<String> availableSlots = [];

    // 1. Parse Opening & Closing Times
    // Default to 09:00 - 20:00 if not specified
    final openTime = _parseTime(salon.openingTime);
    final closeTime = _parseTime(salon.closingTime);

    if (openTime == null || closeTime == null) {
      debugPrint("Error parsing operating hours");
      return [];
    }

    // 2. Define Start and End DateTimes for the selected day
    DateTime startTime = DateTime(
      date.year,
      date.month,
      date.day,
      openTime.hour,
      openTime.minute,
    );

    final DateTime endTime = DateTime(
      date.year,
      date.month,
      date.day,
      closeTime.hour,
      closeTime.minute,
    );

    // 3. Define Buffer Time (e.g., 15 minutes between appointments for cleaning/delays)
    const int bufferTimeMinutes = 10;
    final int slotInterval = serviceDurationMinutes + bufferTimeMinutes;

    // 4. Iterate and generate slots
    // We check if the potential slot + service duration is within closing time.
    while (startTime
            .add(Duration(minutes: serviceDurationMinutes))
            .isBefore(endTime) ||
        startTime
            .add(Duration(minutes: serviceDurationMinutes))
            .isAtSameMomentAs(endTime)) {
      final String timeString = DateFormat('hh:mm a').format(startTime);

      // 5. Check Availability against overlapping bookings
      if (_isSlotAvailable(
        slotStart: startTime,
        durationMinutes: serviceDurationMinutes,
        existingBookings: existingBookings,
        salon: salon,
        selectedBarberId: selectedBarberId,
      )) {
        availableSlots.add(timeString);
      }

      // Move to next slot
      startTime = startTime.add(Duration(minutes: slotInterval));
    }

    return availableSlots;
  }

  static TimeOfDay? _parseTime(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      // Normalize: Replace non-breaking spaces (U+202F, U+00A0) with standard space
      // Also trim
      String cleanTime = timeStr
          .replaceAll('\u202F', ' ')
          .replaceAll('\u00A0', ' ')
          .trim();

      // Try parsing with DateFormat
      // "jm" is the skeleton for "5:00 PM" or "17:00" depending on locale,
      // but here we just try explicit common formats.

      try {
        // Try 12-hour format with AM/PM (flexible hour space)
        // 'h:mm a' handles "9:00 AM" and "10:00 AM"
        final dt = DateFormat("h:mm a").parse(cleanTime);
        return TimeOfDay.fromDateTime(dt);
      } catch (_) {}

      try {
        // Try 24-hour format "HH:mm" or "H:mm"
        final dt = DateFormat("H:mm").parse(cleanTime);
        return TimeOfDay.fromDateTime(dt);
      } catch (_) {}

      // Manual fallback for simple "HH:mm" if DateFormat fails or weird separators
      if (cleanTime.contains(":")) {
        final parts = cleanTime.split(":");
        final h = int.tryParse(parts[0].trim());
        final m = int.tryParse(
          parts[1].split(" ")[0].trim(),
        ); // handle "00 PM" if split failed above
        if (h != null && m != null) {
          // Handle 12-hour adjustment manually if PM exists
          if (cleanTime.toUpperCase().contains("PM") && h < 12) {
            return TimeOfDay(hour: h + 12, minute: m);
          }
          if (cleanTime.toUpperCase().contains("AM") && h == 12) {
            return TimeOfDay(hour: 0, minute: m);
          }
          return TimeOfDay(hour: h, minute: m);
        }
      }

      return null;
    } catch (e) {
      debugPrint("Error parsing time '$timeStr': $e");
      return null;
    }
  }

  static bool _isSlotAvailable({
    required DateTime slotStart,
    required int durationMinutes,
    required List<BookingModel> existingBookings,
    required SalonModel salon,
    String? selectedBarberId,
  }) {
    final DateTime slotEnd = slotStart.add(Duration(minutes: durationMinutes));

    // A booking overlaps if:
    // (BookingStart < SlotEnd) AND (BookingEnd > SlotStart)
    final overlappingBookings = existingBookings.where((booking) {
      if (booking.startAt == null) return false;

      // 1. Ignore Cancelled / No Show
      if (booking.status == 'cancelled' || booking.status == 'no_show') {
        return false;
      }

      // 2. Handle Completed Bookings (Use realEndTime if available)
      DateTime bookingEnd;
      if (booking.status == 'completed' && booking.realEndTime != null) {
        bookingEnd = booking.realEndTime!;
      } else {
        // Default: Scheduled End Time
        final duration = booking.durationMinutes > 0
            ? booking.durationMinutes
            : 30;
        bookingEnd = booking.startAt!.add(Duration(minutes: duration));
      }

      // 3. Handle In Progress (Strictly busy)
      // If in_progress, it blocks everything until it ends (which we don't know yet, so assume scheduled or strictly active)
      // But for generating *future* slots, we mainly care if a past/current booking overlaps the *target* slot.

      return booking.startAt!.isBefore(slotEnd) &&
          bookingEnd.isAfter(slotStart);
    }).toList();

    // If no overlaps at all, it's free!
    if (overlappingBookings.isEmpty) return true;

    // Implementation for Specific Barber Selection
    if (selectedBarberId != null) {
      // If ANY overlapping booking is for this barber, the slot is blocked.
      final isBarberBusy = overlappingBookings.any(
        (b) => b.barberId == selectedBarberId,
      );
      if (isBarberBusy) {
        // debugPrint("Slot $slotStart blocked for $selectedBarberId");
      }
      return !isBarberBusy;
    }

    // Implementation for "Any" Barber Selection
    int totalBarbers = salon.barbers.length;
    if (totalBarbers == 0) totalBarbers = 1;

    // Count busy resources
    // 1. Specific barbers who are busy
    final busySpecificBarbers = overlappingBookings
        .where((b) => b.barberId.isNotEmpty)
        .map((b) => b.barberId)
        .toSet();

    // 2. Unassigned bookings (barberId is empty) - each takes 1 capacity
    final unassignedCount = overlappingBookings
        .where((b) => b.barberId.isEmpty)
        .length;

    final totalBusy = busySpecificBarbers.length + unassignedCount;

    return totalBusy < totalBarbers;
  }

  /// 🕵️‍♂️ Find the first available barber for a specific slot
  static Map<String, dynamic>? findFirstAvailableBarber({
    required DateTime slotStart,
    required int durationMinutes,
    required List<BookingModel> existingBookings,
    required SalonModel salon,
  }) {
    if (salon.barbers.isEmpty) return null;

    final DateTime slotEnd = slotStart.add(Duration(minutes: durationMinutes));

    // Find all barbers who have a conflict
    final busyBarberIds = existingBookings
        .where((booking) {
          if (booking.startAt == null) return false;
          // Ignore checks
          if (booking.status == 'cancelled' || booking.status == 'no_show') {
            return false;
          }

          // Determine End Time
          DateTime bookingEnd;
          if (booking.status == 'completed' && booking.realEndTime != null) {
            bookingEnd = booking.realEndTime!;
          } else {
            final d = booking.durationMinutes > 0
                ? booking.durationMinutes
                : 30;
            bookingEnd = booking.startAt!.add(Duration(minutes: d));
          }

          // Check Overlap
          return booking.startAt!.isBefore(slotEnd) &&
              bookingEnd.isAfter(slotStart);
        })
        .map((b) => b.barberId)
        .toSet();

    // Return the first barber NOT in the busy list
    try {
      return salon.barbers.firstWhere(
        (barber) => !busyBarberIds.contains(
          barber['name'],
        ), // Assuming barber['name'] is used as ID based on user context
      );
    } catch (e) {
      return null; // All busy
    }
  }
}
