import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/pages/buisness_details_page.dart';
import 'package:walkinsalonapp/pages/dashboard_buisness.dart';
import 'login_form.dart';

class OwnerPanel extends StatefulWidget {
  const OwnerPanel({super.key});

  @override
  State<OwnerPanel> createState() => _OwnerPanelState();
}

class _OwnerPanelState extends State<OwnerPanel> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // 🧾 Step 1: Sign up → Create Firebase user + mark as business_pending
  Future<void> _signUpOwner() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = cred.user!.uid;

      // 🔹 Mark user as pending business until they fill details
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'role': 'business_pending',
        'subscriptionActive': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Complete your business details.')),
      );

      // 🔹 Redirect to Business Details setup page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BusinessDetailsPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🧾 Step 2: Login → Check if business details exist
  Future<void> _loginOwner() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = cred.user!.uid;

      // Get both user role and business details
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final businessDoc =
          await FirebaseFirestore.instance.collection('businesses').doc(uid).get();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      // 🔹 Case 1: User hasn’t filled business details yet
      if (userDoc['role'] == 'business_pending' ||
          !businessDoc.exists ||
          (businessDoc.data()?['salonName'] == null ||
              (businessDoc.data()?['salonName'] as String).isEmpty)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessDetailsPage()),
        );
      } 
      // 🔹 Case 2: User already has completed setup
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessDashboardPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginPanelForm(
      formKey: _formKey,
      title: 'BUSINESS OWNER',
      emailController: _emailController,
      passwordController: _passwordController,
      buttonText: _isLoading ? 'Processing...' : 'SIGN UP AS BUSINESS',
      buttonColor: Colors.green,
      footerText: 'Existing partner? Log in',
      onButtonPressed: _isLoading ? null : _signUpOwner,
      onFooterPressed: _isLoading ? null : _loginOwner,
    );
  }
}
