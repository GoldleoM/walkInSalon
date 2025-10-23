import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/pages/buisness_details_page.dart';
import 'package:walkinsalonapp/pages/business_dashboard_page.dart';

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

  Future<void> _signUpOwner() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'role': 'business_pending',
        'subscriptionActive': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Complete your business details.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessDetailsPage()),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginOwner() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = cred.user!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final businessDoc =
          await FirebaseFirestore.instance.collection('businesses').doc(uid).get();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (userDoc['role'] == 'business_pending' ||
          !businessDoc.exists ||
          (businessDoc.data()?['salonName'] == null ||
              (businessDoc.data()?['salonName'] as String).isEmpty)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessDetailsPage()),
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => userDoc['role'] == 'business_pending' ||
                      !businessDoc.exists ||
                      (businessDoc.data()?['salonName'] == null ||
                          (businessDoc.data()?['salonName'] as String).isEmpty)
                  ? const BusinessDetailsPage()
                  : const BusinessDashboardPage(),
            ),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 500)),
              SlideEffect(
                begin: Offset(0, 0.05),
                duration: Duration(milliseconds: 400),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: AppDecorations.glassPanel(context),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Business Owner",
                      style: GoogleFonts.poppins(
                        fontSize: isWide ? 26 : 22,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage your salon effortlessly",
                      style: GoogleFonts.inter(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ✉️ Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: "you@business.com",
                        hintStyle:
                            TextStyle(color: colors.onSurface.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: colors.primary.withOpacity(0.8)),
                        filled: true,
                        fillColor: colors.surface.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.smallRadius),
                          borderSide: BorderSide(
                            color: colors.outline.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.smallRadius),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email required';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(v)) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 🔒 Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle:
                            TextStyle(color: colors.onSurface.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: colors.primary.withOpacity(0.8)),
                        filled: true,
                        fillColor: colors.surface.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.smallRadius),
                          borderSide: BorderSide(
                            color: colors.outline.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.smallRadius),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password required';
                        }
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 🧾 Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpOwner,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.smallRadius),
                          ),
                          elevation: AppConstants.elevation,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Sign Up as Business",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Existing partner link
                    TextButton(
                      onPressed: _isLoading ? null : _loginOwner,
                      child: Text(
                        "Existing partner? Log in",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: colors.onSurface.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
