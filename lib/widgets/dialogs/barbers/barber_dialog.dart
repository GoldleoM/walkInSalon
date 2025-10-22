import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BarberDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? existingBarber;
  final int? index;

  const BarberDialog({
    super.key,
    required this.userId,
    this.existingBarber,
    this.index,
  });

  @override
  State<BarberDialog> createState() => _BarberDialogState();
}

class _BarberDialogState extends State<BarberDialog> {
  final _uuid = const Uuid();
  final nameController = TextEditingController();
  final specialityController = TextEditingController();
  List<String> specialties = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.existingBarber?["name"] ?? "";
    specialties = List<String>.from(widget.existingBarber?["specialties"] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingBarber == null ? "Add Barber" : "Edit Barber"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: specialityController,
                    decoration: const InputDecoration(labelText: "Add Specialty"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: addSpecialty,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: specialties
                  .map((s) => Chip(
                        label: Text(s),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => removeSpecialty(s),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveBarber,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.existingBarber == null ? "Add" : "Save"),
        ),
      ],
    );
  }

  void addSpecialty() {
    final text = specialityController.text.trim();
    if (text.isNotEmpty && !specialties.contains(text)) {
      setState(() => specialties.add(text));
      specialityController.clear();
    }
  }

  void removeSpecialty(String s) {
    setState(() => specialties.remove(s));
  }

  Future<void> _saveBarber() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('businesses').doc(widget.userId);
      final doc = await docRef.get();
      List barbers = List.from(doc.data()?['barbers'] ?? []);

      final barberData = {
        "barberId": widget.existingBarber?["barberId"] ?? _uuid.v4(),
        "name": name,
        "specialties": specialties,
        "isAvailable": widget.existingBarber?["isAvailable"] ?? true,
        "rating": widget.existingBarber?["rating"] ?? 0.0,
        "updatedAt": DateTime.now(),
      };

      if (widget.index != null) {
        barbers[widget.index!] = barberData;
      } else {
        barbers.add(barberData);
      }

      await docRef.set({"barbers": barbers}, SetOptions(merge: true));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving barber: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
