import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

/// Dialog widget for adding a new barber.
/// Returns a Map<String, dynamic> if confirmed, otherwise null.
Future<Map<String, dynamic>?> showAddBarberDialog(BuildContext context) async {
  final nameController = TextEditingController();

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add Barber'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(hintText: 'Enter barber name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'barberId': _uuid.v4(),
                'name': nameController.text.trim(),
                'isAvailable': true,
                'specialties': <String>[],
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
