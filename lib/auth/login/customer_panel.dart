import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';

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

  Future<void> _loginCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // Placeholder simulation
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customer login coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 500)),
              SlideEffect(begin: Offset(0, 0.05), duration: Duration(milliseconds: 400)),
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
                      "Customer Login",
                      style: GoogleFonts.poppins(
                        fontSize: isWide ? 26 : 22,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Access your appointments & favorites",
                      style: GoogleFonts.inter(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // ✉️ Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: "you@example.com",
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.email_outlined, color: colors.primary.withOpacity(0.8)),
                        filled: true,
                        fillColor: colors.surface.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                          borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                          borderSide: BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email required';
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(v)) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 🔒 Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.lock_outline, color: colors.primary.withOpacity(0.8)),
                        filled: true,
                        fillColor: colors.surface.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                          borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                          borderSide: BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 🔘 Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginCustomer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
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
                            : const Text(
                                "Login as Customer",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🧾 Sign Up link
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Customer sign-up coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        "New here? Sign up",
                        style: GoogleFonts.inter(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
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
