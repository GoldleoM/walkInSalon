import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestAddFirestoreDataPage extends StatefulWidget {
  const TestAddFirestoreDataPage({super.key});

  @override
  State<TestAddFirestoreDataPage> createState() =>
      _TestAddFirestoreDataPageState();
}

class _TestAddFirestoreDataPageState extends State<TestAddFirestoreDataPage> {
  String _selectedDeleteType = "appointments"; // default value

  // ✅ Add a test appointment
  Future<void> _addTestAppointment() async {
    try {
      const barberId = "841d3326-454e-4f9a-86d8-809adcb524e0";
      const businessId = "tEmFuUrdC2dX2PJvin2uA2DBmmp1";

      final appointmentData = {
        "barberId": barberId,
        "barberName": "Aaron",
        "businessId": businessId,
        "customerName": "Akshat Sharma",
        "service": "Haircut",
        "startAt": Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 1)),
        ),
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(), // ✅ ADD THIS
      };

      final docRef = await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Appointment added (ID: ${docRef.id})")),
      );
    } catch (e) {
      debugPrint("❌ Error adding appointment: $e");
    }
  }

  // ✅ Add a test review
  Future<void> _addTestReview() async {
    try {
      const barberName = "Aaron";
      const businessId = "tEmFuUrdC2dX2PJvin2uA2DBmmp1";
      const customerName = "Akshat Sharma";
      const userId = "customer_uid_test";

      final reviewData = {
        "barberName": barberName,
        "businessId": businessId,
        "customerName": customerName,
        "comment": "Amazing haircut! Very satisfied.",
        "rating": 5,
        "reply": "Thank you for your feedback!",
        "repliedAt": Timestamp.now(),
        "createdAt": Timestamp.now(),
        "userId": userId,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('reviews')
          .add(reviewData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Review added (ID: ${docRef.id})")),
      );
    } catch (e) {
      debugPrint("❌ Error adding review: $e");
    }
  }

  // ❌ Delete all documents in selected collection
  Future<void> _deleteSelectedCollection() async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection(
        _selectedDeleteType,
      );
      final snapshot = await collectionRef.get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🗑️ Deleted all documents in $_selectedDeleteType"),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error deleting $_selectedDeleteType: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Test Tool')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Add Section ---
            const Text(
              "➕ Add Test Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTestAppointment,
              child: const Text("Add Test Appointment"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addTestReview,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Add Test Review"),
            ),
            const SizedBox(height: 40),

            // --- Delete Section ---
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "🗑️ Delete Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Dropdown for selecting collection
            DropdownButton<String>(
              value: _selectedDeleteType,
              items: const [
                DropdownMenuItem(
                  value: "appointments",
                  child: Text("Appointments"),
                ),
                DropdownMenuItem(value: "reviews", child: Text("Reviews")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDeleteType = value);
                }
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _deleteSelectedCollection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete Selected Collection"),
            ),
          ],
        ),
      ),
    );
  }
}
