import 'package:flutter/material.dart';

class BarberCard extends StatelessWidget {
  final Map<String, dynamic> barber;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleAvailability;

  const BarberCard({
    super.key,
    required this.barber,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    final specialties = (barber['specialties'] is List)
        ? (barber['specialties'] as List).join(', ')
        : "No specialty";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF023047),
          backgroundImage: barber["profileImage"] != null
              ? NetworkImage(barber["profileImage"])
              : null,
          child: barber["profileImage"] == null
              ? Text(
                  (barber["name"] ?? "?")[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          barber["name"] ?? "Unnamed Barber",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(specialties),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: onDelete),
            Switch(
              value: barber["isAvailable"] ?? true,
              onChanged: onToggleAvailability,
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
