import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BusinessSubscriptionPage extends StatefulWidget {
  const BusinessSubscriptionPage({super.key});

  @override
  State<BusinessSubscriptionPage> createState() =>
      _BusinessSubscriptionPageState();
}

class _BusinessSubscriptionPageState extends State<BusinessSubscriptionPage> {
  bool isSubscribed = true;
  DateTime expiryDate = DateTime.now().add(const Duration(days: 12));
  final double monthlyFee = 1499.0; // fixed monthly fee (INR)

  void _renewSubscription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Renew Subscription"),
        content: Text(
          "You will be charged ₹$monthlyFee for 30 more days of registration.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isSubscribed = true;
                expiryDate = DateTime.now().add(const Duration(days: 30));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Subscription renewed successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Confirm Payment"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final bool isExpired = DateTime.now().isAfter(expiryDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Subscription"),
        backgroundColor: const Color(0xFF023047),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isExpired ? Colors.red.shade50 : Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSubscribed
                          ? (isExpired
                              ? "Subscription Expired"
                              : "Active Subscription")
                          : "Not Subscribed",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isExpired ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Monthly Fee: ₹$monthlyFee",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isExpired
                          ? "Expired on: ${dateFormatter.format(expiryDate)}"
                          : "Valid until: ${dateFormatter.format(expiryDate)}",
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    if (isExpired)
                      const Text(
                        "⚠️ Your salon is hidden from customers until renewed.",
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isExpired ? Colors.redAccent : const Color(0xFF023047),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: Text(
                  isExpired ? "Renew Subscription" : "Extend by 1 Month",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: _renewSubscription,
              ),
            ),
            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),
            const Text(
              "Subscription Details",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF023047)),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Stay listed on customer booking page"),
            ),
            const ListTile(
              leading: Icon(Icons.people, color: Colors.green),
              title: Text("Allow customer appointments"),
            ),
            const ListTile(
              leading: Icon(Icons.reviews, color: Colors.green),
              title: Text("Customers can rate and review your salon"),
            ),
            const ListTile(
              leading: Icon(Icons.trending_up, color: Colors.green),
              title: Text("Get ranked in nearby recommendations"),
            ),
          ],
        ),
      ),
    );
  }
}
