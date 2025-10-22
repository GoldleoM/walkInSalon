import 'package:flutter/material.dart';
import 'customer_panel.dart';
import 'owner_panel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 61, 174, 255),
              Color.fromARGB(255, 70, 173, 79),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: CustomerPanel()),
                        SizedBox(width: 24),
                        VerticalDivider(thickness: 1, width: 40),
                        SizedBox(width: 24),
                        Expanded(child: OwnerPanel()),
                      ],
                    )
                  : Column(
                      children: const [
                        CustomerPanel(),
                        Divider(thickness: 1, height: 40),
                        OwnerPanel(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
