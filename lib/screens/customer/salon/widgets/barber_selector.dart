import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class BarberSelector extends StatelessWidget {
  final List<Map<String, dynamic>> barbers;
  final Function(Map<String, dynamic>) onBarberSelected;

  const BarberSelector({
    super.key,
    required this.barbers,
    required this.onBarberSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (barbers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Meet the Team",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: barbers.length,
            itemBuilder: (context, index) {
              final barber = barbers[index];
              return GestureDetector(
                onTap: () => onBarberSelected(barber),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.secondary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: barber['image'] != null
                            ? NetworkImage(barber['image'])
                            : null,
                        child: barber['image'] == null
                            ? Text(
                                (barber['name'] ?? "?")[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        barber['name'] ?? "Unknown",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
