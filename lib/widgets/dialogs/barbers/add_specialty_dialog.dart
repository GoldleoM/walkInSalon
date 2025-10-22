import 'package:flutter/material.dart';

/// Dialog widget for adding a specialty to a barber.
/// Returns the specialty string if confirmed, otherwise null.
Future<String?> showAddSpecialtyDialog(BuildContext context, String barberName) {
  final specialtyController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Add Specialty for $barberName'),
      content: TextField(
        controller: specialtyController,
        decoration: const InputDecoration(hintText: 'Enter specialty'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (specialtyController.text.trim().isNotEmpty) {
              Navigator.pop(context, specialtyController.text.trim());
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
