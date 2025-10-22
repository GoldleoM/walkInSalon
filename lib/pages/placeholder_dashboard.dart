import 'package:flutter/material.dart';

class PlaceholderDashboard extends StatelessWidget {
  final String title;
  const PlaceholderDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text(
          'Customer Dashboard Coming Soon!',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
