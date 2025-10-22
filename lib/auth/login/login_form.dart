import 'package:flutter/material.dart';

class LoginPanelForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String buttonText;
  final String footerText;
  final Color buttonColor;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onFooterPressed;

  const LoginPanelForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.emailController,
    required this.passwordController,
    required this.buttonText,
    required this.footerText,
    required this.buttonColor,
    required this.onButtonPressed,
    required this.onFooterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(139, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email required';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(v)) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onFooterPressed,
                child: Text(footerText, style: const TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
