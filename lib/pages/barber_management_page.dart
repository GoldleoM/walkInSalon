import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/dialogs/barbers/barber_dialog.dart';
import '../widgets/barbers/barber_card.dart';

class BarberManagementPage extends StatefulWidget {
  const BarberManagementPage({super.key});

  @override
  State<BarberManagementPage> createState() => _BarberManagementPageState();
}

class _BarberManagementPageState extends State<BarberManagementPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Manage Barbers"),
        backgroundColor: const Color(0xFF023047),
        actions: [
          IconButton(
            onPressed: _showAddBarberDialog,
            icon: const Icon(Icons.add),
            color: Colors.white,
            tooltip: "Add Barber",
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
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No business data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final barbers = List<Map<String, dynamic>>.from(data['barbers'] ?? []);

          if (barbers.isEmpty) {
            return const Center(
              child: Text(
                "No barbers added yet.\nTap '+' to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: barbers.length,
            itemBuilder: (context, index) {
              final barber = barbers[index];
              return BarberCard(
                barber: barber,
                onEdit: () => _showAddBarberDialog(existingBarber: barber, index: index),
                onDelete: () => _deleteBarber(index, barber["name"]),
                onToggleAvailability: (v) => _toggleAvailability(index, v),
              );
            },
          );
        },
      ),
    );
  }

  // 🔹 Show Add/Edit Barber dialog
  void _showAddBarberDialog({Map<String, dynamic>? existingBarber, int? index}) {
    showDialog(
      context: context,
      builder: (_) => BarberDialog(
        userId: userId,
        existingBarber: existingBarber,
        index: index,
      ),
    );
  }

  // 🗑 Delete Barber
  Future<void> _deleteBarber(int index, String? name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${name ?? "this barber"}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('businesses').doc(userId);
      final doc = await docRef.get();
      List barbers = List.from(doc.data()?['barbers'] ?? []);

      if (index < barbers.length) {
        barbers.removeAt(index);
        await docRef.set({"barbers": barbers}, SetOptions(merge: true));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${name ?? "Barber"} deleted.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting barber: $e")));
    }
  }

  // 🔄 Toggle Availability
  Future<void> _toggleAvailability(int index, bool available) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('businesses').doc(userId);
      final doc = await docRef.get();
      List barbers = List.from(doc.data()?['barbers'] ?? []);

      if (index < barbers.length) {
        barbers[index]["isAvailable"] = available;
        barbers[index]["updatedAt"] = DateTime.now();
        await docRef.set({"barbers": barbers}, SetOptions(merge: true));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error updating availability: $e")));
    }
  }
}
