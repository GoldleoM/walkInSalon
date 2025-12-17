import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/providers/auth_provider.dart';
import 'package:walkinsalonapp/utils/validators.dart';
import 'package:walkinsalonapp/auth/signup/customer_signup_screen.dart';
import 'package:walkinsalonapp/auth/password/forgot_password_screen.dart';
import 'package:walkinsalonapp/auth/login/auth_wrapper.dart';

class CustomerPanel extends ConsumerStatefulWidget {
  const CustomerPanel({super.key});

  @override
  ConsumerState<CustomerPanel> createState() => _CustomerPanelState();
}

class _CustomerPanelState extends ConsumerState<CustomerPanel> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final result = await authService.loginCustomer(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      // 🔄 Force refresh role & navigate to AuthWrapper to re-route
      ref.invalidate(currentUserRoleProvider);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset to AuthWrapper to handle routing based on new state
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Form(
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
              color: colors.onSurface.withValues(alpha: 0.7),
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
              hintStyle: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: colors.primary.withValues(alpha: 0.8),
              ),
              filled: true,
              fillColor: colors.surface.withValues(alpha: 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),

          // 🔒 Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: colors.primary.withValues(alpha: 0.8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              filled: true,
              fillColor: colors.surface.withValues(alpha: 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required';
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.inter(color: colors.primary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerSignupScreen(),
                      ),
                    );
                  },
            child: Text(
              "New here? Sign up",
              style: GoogleFonts.inter(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
