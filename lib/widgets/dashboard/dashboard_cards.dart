import 'package:flutter/material.dart';

Widget buildStatCard(String title, String value, IconData icon, Color color) {
  return Container(
    width: 180,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget buildStatusCard(bool isSalonOpen, ValueChanged<bool> onToggle) {
  return Container(
    width: 180,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.access_time, color: Colors.green, size: 30),
        const SizedBox(height: 10),
        const Text("Salon Status", style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSalonOpen ? "OPEN" : "CLOSED",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSalonOpen ? Colors.green : Colors.red,
              ),
            ),
            Switch(
              value: isSalonOpen,
              onChanged: onToggle,
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ],
    ),
  );
}
