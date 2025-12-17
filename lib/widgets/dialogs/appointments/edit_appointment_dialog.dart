import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/services/appointment_services.dart';

class EditAppointmentDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const EditAppointmentDialog({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  final AppointmentService _appointmentService = AppointmentService();

  late TimeOfDay selectedTime;
  late String status;

  // Barber Selection
  String? selectedBarberId;
  String? selectedBarberName;
  List<Map<String, dynamic>> barbers = [];
  bool isLoadingBarbers = true;

  @override
  void initState() {
    super.initState();
    final d = widget.data["startAt"];
    if (d is Timestamp) {
      selectedTime = TimeOfDay.fromDateTime(d.toDate());
    } else {
      selectedTime = const TimeOfDay(hour: 9, minute: 0);
    }

    status = widget.data["status"] ?? 'pending';
    selectedBarberId = widget.data["barberId"];
    selectedBarberName = widget.data["barberName"];

    _fetchBarbers();
  }

  Future<void> _fetchBarbers() async {
    try {
      final businessId = widget.data['businessId'];
      if (businessId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(businessId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['barbers'] is List) {
          setState(() {
            barbers = List<Map<String, dynamic>>.from(data['barbers']);
            isLoadingBarbers = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching barbers: $e");
    }
    if (mounted) setState(() => isLoadingBarbers = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Appointment"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⏰ TIME PICKER
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Time"),
              subtitle: Text(selectedTime.format(context)),
              trailing: const Icon(Icons.access_time, color: Colors.blue),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (pickedTime != null) {
                  setState(() => selectedTime = pickedTime);
                }
              },
            ),
            const SizedBox(height: 12),

            // 🏷️ STATUS
            DropdownButtonFormField<String>(
              value:
                  [
                    "pending",
                    "confirmed",
                    "completed",
                    "cancelled",
                    "no_show",
                    "in_progress",
                  ].contains(status.toLowerCase())
                  ? status.toLowerCase()
                  : "pending",
              items:
                  [
                        "pending",
                        "confirmed",
                        "completed",
                        "cancelled",
                        "no_show",
                        "in_progress",
                      ]
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => status = v!),
              decoration: const InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 💈 BARBER SELECTION
            if (isLoadingBarbers)
              const Center(child: LinearProgressIndicator())
            else if (barbers.isNotEmpty)
              DropdownButtonFormField<String>(
                value: barbers.any((b) => b['name'] == selectedBarberId)
                    ? selectedBarberId
                    : null,
                items: barbers.map((b) {
                  final name = b['name'] as String;
                  return DropdownMenuItem(
                    value: name, // Using name as ID per current app structure
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    selectedBarberId = v;
                    selectedBarberName = v; // Same for now
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Assigned Barber",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              )
            else
              const Text(
                "No barbers found",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            // Reconstruct DateTime
            final rawDate = widget.data["startAt"];
            final date = rawDate is Timestamp
                ? rawDate.toDate()
                : DateTime.now();

            final updatedDate = DateTime(
              date.year,
              date.month,
              date.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            await _appointmentService.updateAppointment(
              docId: widget.docId,
              newTime: updatedDate,
              status: status,
              barberId: selectedBarberId,
              barberName: selectedBarberName,
            );

            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Save Changes"),
        ),
      ],
    );
  }
}
