import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_form.dart';
import 'package:walkinsalonapp/pages/placeholder_dashboard.dart';

class CustomerPanel extends StatefulWidget {
  const CustomerPanel({super.key});

  @override
  State<CustomerPanel> createState() => _CustomerPanelState();
}

class _CustomerPanelState extends State<CustomerPanel> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUpCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PlaceholderDashboard(title: 'Customer Dashboard'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    }
  }

  Future<void> _loginCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer logged in successfully!')),
      );

      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PlaceholderDashboard(title: 'Customer Dashboard'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginPanelForm(
      formKey: _formKey,
      title: 'CUSTOMER',
      emailController: _emailController,
      passwordController: _passwordController,
      buttonText: _isLoading ? 'Processing...' : 'SIGN UP AS CUSTOMER',
      buttonColor: Colors.blueAccent,
      footerText: 'Already have an account? Log in',
      onButtonPressed: _isLoading ? null : _signUpCustomer,
      onFooterPressed: _isLoading ? null : _loginCustomer,
    );
  }
}
