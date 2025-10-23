import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: AppDecorations.glassPanel(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage: barber["profileImage"] != null
              ? NetworkImage(barber["profileImage"])
              : null,
          child: barber["profileImage"] == null
              ? Text(
                  (barber["name"] ?? "?")[0].toUpperCase(),
                  style: TextStyle(color: AppColors.darkTextPrimary),
                )
              : null,
        ),
        title: Text(
          barber["name"] ?? "Unnamed Barber",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(specialties, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: AppColors.secondary), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: AppColors.error), onPressed: onDelete),
            Switch(
              value: barber["isAvailable"] ?? true,
              onChanged: onToggleAvailability,
              activeThumbColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
