import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/widgets/dialogs/barbers/barber_dialog.dart';
import 'package:walkinsalonapp/widgets/barbers/barber_card.dart';

class BarberManagementPage extends StatefulWidget {
  const BarberManagementPage({super.key});

  @override
  State<BarberManagementPage> createState() => _BarberManagementPageState();
}

class _BarberManagementPageState extends State<BarberManagementPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text("Manage Barbers"),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _showAddBarberDialog,
            icon: const Icon(Icons.add),
            tooltip: "Add Barber",
            color: Colors.white,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No business data found.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final barbers = List<Map<String, dynamic>>.from(
            data['barbers'] ?? [],
          );

          if (barbers.isEmpty) {
            return Center(
              child: Text(
                "No barbers added yet.\nTap '+' to add one.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.padding),
            itemCount: barbers.length,
            itemBuilder: (context, index) {
              final barber = barbers[index];
              return BarberCard(
                barber: barber,
                onEdit: () =>
                    _showAddBarberDialog(existingBarber: barber, index: index),
                onDelete: () => _deleteBarber(index, barber["name"]),
                onToggleAvailability: (v) => _toggleAvailability(index, v),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔹 Show Add/Edit Barber dialog
  void _showAddBarberDialog({
    Map<String, dynamic>? existingBarber,
    int? index,
  }) {
    showDialog(
      context: context,
      builder: (_) => BarberDialog(
        userId: userId,
        existingBarber: existingBarber,
        index: index,
      ),
    );
  }

  /// 🗑 Delete Barber
  Future<void> _deleteBarber(int index, String? name) async {
    final colors = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          "Confirm Delete",
          style: TextStyle(color: colors.onSurface),
        ),
        content: Text(
          "Are you sure you want to delete ${name ?? "this barber"}?",
          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('businesses')
          .doc(userId);
      final doc = await docRef.get();
      List barbers = List.from(doc.data()?['barbers'] ?? []);

      if (index < barbers.length) {
        barbers.removeAt(index);
        await docRef.set({"barbers": barbers}, SetOptions(merge: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${name ?? "Barber"} deleted."),
              backgroundColor: colors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting barber: $e")));
      }
    }
  }

  /// 🔄 Toggle Barber Availability
  Future<void> _toggleAvailability(int index, bool available) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('businesses')
          .doc(userId);
      final doc = await docRef.get();
      List barbers = List.from(doc.data()?['barbers'] ?? []);

      if (index < barbers.length) {
        barbers[index]["isAvailable"] = available;
        barbers[index]["updatedAt"] = DateTime.now();
        await docRef.set({"barbers": barbers}, SetOptions(merge: true));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating availability: $e")),
        );
      }
    }
  }
}
