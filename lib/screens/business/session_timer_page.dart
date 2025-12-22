import 'dart:async';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/models/booking_model.dart';
import 'package:walkinsalonapp/services/appointment_services.dart';

class SessionTimerPage extends StatefulWidget {
  final BookingModel booking;
  final String docId;

  const SessionTimerPage({
    super.key,
    required this.booking,
    required this.docId,
  });

  @override
  State<SessionTimerPage> createState() => _SessionTimerPageState();
}

class _SessionTimerPageState extends State<SessionTimerPage> {
  final AppointmentService _appointmentService = AppointmentService();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  void _initSession() {
    // If not already in progress or completed, start it
    if (widget.booking.status == 'confirmed' ||
        widget.booking.status == 'pending') {
      _startSession();
    } else if (widget.booking.status == 'in_progress') {
      // Calculate elapsed based on realStartTime
      if (widget.booking.realStartTime != null) {
        final start = widget.booking.realStartTime!;
        _elapsed = DateTime.now().difference(start);
        _startTimer();
      } else {
        // Fallback if realStartTime missing (shouldn't happen)
        _startSession();
      }
    } else if (widget.booking.status == 'completed') {
      _isCompleted = true;
      if (widget.booking.realStartTime != null &&
          widget.booking.realEndTime != null) {
        _elapsed = widget.booking.realEndTime!.difference(
          widget.booking.realStartTime!,
        );
      }
    }
  }

  Future<void> _startSession() async {
    try {
      await _appointmentService.startAppointment(widget.docId);
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error starting session: $e")));
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _endSession() async {
    setState(() => _isLoading = true);
    try {
      await _appointmentService.completeAppointment(widget.docId);
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error ending session: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildSuccessView();
    }

    return Scaffold(
      backgroundColor: Colors.black, // Cool dark theme for stopwatch
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    "SESSION IN PROGRESS",
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // Balance close button
                ],
              ),
            ),
            const Spacer(),

            // Customer Info
            Text(
              widget.booking.customerName?.toUpperCase() ?? "CUSTOMER",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              widget.booking.serviceName,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 60),

            // ⏱️ TIMER
            Text(
              _formatDuration(_elapsed),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w200,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),

            const Spacer(),

            // End Button
            Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _endSession,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "END SESSION",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                widget.booking.serviceName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "COMPLETED IN",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "${_elapsed.inMinutes} MINS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
