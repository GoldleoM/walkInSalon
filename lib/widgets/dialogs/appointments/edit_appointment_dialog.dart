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

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.fromDateTime(widget.data["startAt"].toDate());
    status = widget.data["status"];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Appointment"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          DropdownButtonFormField<String>(
            initialValue: status,
            items: ["Pending", "Confirmed", "Cancelled"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => status = v!),
            decoration: const InputDecoration(labelText: "Status"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final date = widget.data["startAt"].toDate();
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
            );

            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
