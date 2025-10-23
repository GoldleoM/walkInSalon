import 'package:flutter/material.dart';

class BarberCard extends StatelessWidget {
  final Map<String, dynamic> barber;
  final VoidCallback onAddSpecialty;
  final Function(String) onDeleteSpecialty;

  const BarberCard({
    super.key,
    required this.barber,
    required this.onAddSpecialty,
    required this.onDeleteSpecialty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  barber['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: onAddSpecialty,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: (barber['specialties'] as List<String>).map((spec) {
                return Chip(
                  label: Text(spec),
                  onDeleted: () => onDeleteSpecialty(spec),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
