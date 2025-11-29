import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountsPage extends StatefulWidget {
  const DiscountsPage({super.key});

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  final List<Map<String, dynamic>> discounts = [
    {
      "title": "10% Off Haircuts",
      "description": "Enjoy 10% off all haircut services this week!",
      "percentage": 10,
      "validUntil": DateTime(2025, 10, 25),
    },
    {
      "title": "20% Off Beard Trims",
      "description": "Exclusive offer for first-time customers.",
      "percentage": 20,
      "validUntil": DateTime(2025, 10, 15),
    },
  ];

  final DateFormat dateFormatter = DateFormat('dd MMM yyyy');

  void _addOrEditDiscount({Map<String, dynamic>? existingDiscount, int? index}) {
    final TextEditingController titleController =
        TextEditingController(text: existingDiscount?['title'] ?? '');
    final TextEditingController descController =
        TextEditingController(text: existingDiscount?['description'] ?? '');
    final TextEditingController percentageController = TextEditingController(
        text: existingDiscount?['percentage']?.toString() ?? '');
    DateTime? selectedDate = existingDiscount?['validUntil'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingDiscount == null
            ? "Add New Discount"
            : "Edit Discount"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Discount Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: percentageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Discount Percentage (%)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(selectedDate == null
                        ? "Valid Until: Not selected"
                          : "Valid Until: ${dateFormatter.format(selectedDate!)}"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  descController.text.isEmpty ||
                  percentageController.text.isEmpty ||
                  selectedDate == null) {
                return;
              }

              final newDiscount = {
                "title": titleController.text.trim(),
                "description": descController.text.trim(),
                "percentage": int.parse(percentageController.text.trim()),
                "validUntil": selectedDate!,
              };

              setState(() {
                if (existingDiscount == null) {
                  discounts.add(newDiscount);
                } else {
                  discounts[index!] = newDiscount;
                }
              });

              Navigator.pop(context);
            },
            child: Text(existingDiscount == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  void _deleteDiscount(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Discount"),
        content: const Text("Are you sure you want to delete this discount?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                discounts.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Discount Offers"),
        backgroundColor: const Color(0xFF023047),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditDiscount(),
          ),
        ],
      ),
      body: discounts.isEmpty
          ? const Center(
              child: Text(
                "No discounts available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: discounts.length,
                itemBuilder: (context, index) {
                  final discount = discounts[index];
                  final isExpired =
                      discount["validUntil"].isBefore(DateTime.now());

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                discount["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isExpired
                                      ? Colors.red.shade100
                                      : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isExpired ? "Expired" : "Active",
                                  style: TextStyle(
                                    color: isExpired
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 6),

                          Text(
                            discount["description"],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            "Discount: ${discount["percentage"]}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text(
                            "Valid Until: ${dateFormatter.format(discount["validUntil"])}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _addOrEditDiscount(
                                    existingDiscount: discount, index: index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDiscount(index),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
