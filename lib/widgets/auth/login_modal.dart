import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/providers/auth_provider.dart';
import 'package:walkinsalonapp/utils/validators.dart';

import 'package:walkinsalonapp/auth/login/auth_wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:walkinsalonapp/auth/password/forgot_password_screen.dart';
import 'package:walkinsalonapp/screens/business/business_dashboard_page.dart';
import 'package:walkinsalonapp/screens/business/business_details_page.dart';

class LoginModal extends ConsumerStatefulWidget {
  final bool fromIntro;
  const LoginModal({super.key, this.fromIntro = false});

  @override
  ConsumerState<LoginModal> createState() => _LoginModalState();
}

enum _ModalView { menu, emailLogin, emailSignup, businessLogin }

class _LoginModalState extends ConsumerState<LoginModal> {
  // Default to email login as requested
  _ModalView _currentView = _ModalView.emailLogin;

  void _switchView(_ModalView view) {
    setState(() => _currentView = view);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getHeaderTitle(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Animated Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentView(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (_currentView) {
      case _ModalView.menu:
        return "Get Started";
      case _ModalView.emailLogin:
        return "Login"; // Simplified title
      case _ModalView.emailSignup:
        return "Sign Up";
      case _ModalView.businessLogin:
        return "Business Login";
    }
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case _ModalView.menu:
        return _buildMenuView(); // Kept if we need to switch back, but default is emailLogin
      case _ModalView.emailLogin:
        return _EmailLoginForm(
          onBack: () => _switchView(_ModalView.menu),
          onSignup: () => _switchView(_ModalView.emailSignup),
          onLoginSuccess: () {
            if (widget.fromIntro) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          onBusinessLogin: () => _switchView(_ModalView.businessLogin),
        );
      case _ModalView.emailSignup:
        return _EmailSignupForm(
          onBack: () => _switchView(_ModalView.menu),
          onLogin: () => _switchView(_ModalView.emailLogin),
        );
      case _ModalView.businessLogin:
        return _BusinessLoginForm(
          onBack: () => _switchView(_ModalView.menu),
          onLoginSuccess: () {
            if (widget.fromIntro) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        );
    }
  }

  Widget _buildMenuView() {
    // This view might be unreachable now if we jump straight to emailLogin,
    // but useful if we want a back button from login to a main menu.
    // For now, let's keep it simple.
    return Column(
      key: const ValueKey('menu'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SocialButton(
          icon: Icons.email_outlined,
          label: "Continue with Email",
          onTap: () => _switchView(_ModalView.emailLogin),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          icon: Icons.g_mobiledata,
          label: "Continue with Google",
          onTap: _handleGoogleLogin,
        ),
        // Removed Phone Login as requested
      ],
    );
  }

  Future<void> _handleGoogleLogin() async {
    final authService = ref.read(authServiceProvider);

    // Show loading indicator if needed, or handle within the button if we want to make it stateful
    // For simplicity, we'll just show a loading dialog or reuse the modal state if possible.
    // But _buildMenuView is stateless essentially.
    // Let's us show a loading indicator on top or just await.

    try {
      final result = await authService.signInWithGoogle();

      if (!mounted) return;

      if (result['success']) {
        ref.invalidate(currentUserRoleProvider);
        if (widget.fromIntro) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pop();
        }
      } else {
        if (result['message'] != 'Sign in cancelled by user') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        foregroundColor: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          if (!compact) ...[
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmailLoginForm extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSignup;
  final VoidCallback onLoginSuccess;
  final VoidCallback? onBusinessLogin; // Callback for Business Login switch

  const _EmailLoginForm({
    required this.onBack,
    required this.onSignup,
    required this.onLoginSuccess,
    this.onBusinessLogin,
  });

  @override
  ConsumerState<_EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends ConsumerState<_EmailLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
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
      ref.invalidate(currentUserRoleProvider);
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleGoogleLoginInternal() async {
    print('LoginModal: Starting Google Login...');
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    try {
      print('LoginModal: Calling authService.signInWithGoogle...');
      final result = await authService.signInWithGoogle();
      print('LoginModal: authService.signInWithGoogle returned: $result');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success']) {
        ref.invalidate(currentUserRoleProvider);
        widget.onLoginSuccess();
      } else {
        if (result['message'] != 'Sign in cancelled by user') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('LoginModal: Error caught in _handleGoogleLoginInternal: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('emailLogin'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Removed explicit Back button here as this is now the default view
        // Maybe keep it if user wants to go to menu?
        // User requested "login with email is default", so we likely don't need a back button to menu.
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                autofocus: true, // Auto focus as requested
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Password required" : null,
                textInputAction: TextInputAction.done, // Submit on Enter
                onFieldSubmitted: (_) => _login(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),

        // Social Logins
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.g_mobiledata, // Placeholder
                label: "Google",
                onTap: () {
                  // Call the method from the parent state?
                  // Or finding the parent state is messy.
                  // We probably should move _handleGoogleLogin to be accessible or pass it down.
                  // Since _EmailLoginForm is a separate widget, it needs access.
                  // The easiest way is to duplicate the logic or pass it as a callback.
                  // Or just read the provider directly here since it is a ConsumerStatefulWidget!
                  _handleGoogleLoginInternal();
                },
                compact: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SocialButton(
                icon: Icons.facebook,
                label: "Facebook",
                onTap: () {
                  // TODO: Facebook Login
                },
                compact: true,
              ),
            ),
            // Apple if needed? User said "google , facebook" specifically.
          ],
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            TextButton(
              onPressed: widget.onSignup,
              child: const Text("Sign Up"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: widget.onBusinessLogin,
          child: Text(
            "Login as Business",
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmailSignupForm extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogin;

  const _EmailSignupForm({required this.onBack, required this.onLogin});

  @override
  ConsumerState<_EmailSignupForm> createState() => _EmailSignupFormState();
}

class _EmailSignupFormState extends ConsumerState<_EmailSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final result = await authService.signUpCustomer(
      email: _emailController.text,
      password: _passwordController.text,
      name: Validators.sanitizeName(_nameController.text),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(); // Close modal on success
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
    return Column(
      key: const ValueKey('signup'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Back"),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone (Optional)",
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    Validators.validatePhoneNumber(v, required: false),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: Validators.validatePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.validateConfirmPassword(
                  v,
                  _passwordController.text,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signUp(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (v) =>
                        setState(() => _acceptedTerms = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      "I agree to the Terms and Conditions",
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account?"),
            TextButton(onPressed: widget.onLogin, child: const Text("Log In")),
          ],
        ),
      ],
    );
  }
}

class _BusinessLoginForm extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLoginSuccess;

  const _BusinessLoginForm({
    required this.onBack,
    required this.onLoginSuccess,
  });

  @override
  State<_BusinessLoginForm> createState() => _BusinessLoginFormState();
}

class _BusinessLoginFormState extends State<_BusinessLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _processAuth(bool isSignup) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (isSignup) {
        // Signup Logic
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
            content: Text('Account created! Complete your details.'),
          ),
        );

        // Navigate to Details
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BusinessDetailsPage()),
          (route) => false, // Clear all previous routes
        );
      } else {
        // Login Logic
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final uid = cred.user!.uid;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final businessDoc = await FirebaseFirestore.instance
            .collection('businesses')
            .doc(uid)
            .get();

        if (!mounted) return;

        // Check if pending setup
        bool needsSetup =
            userDoc['role'] == 'business_pending' ||
            !businessDoc.exists ||
            (businessDoc.data()?['salonName'] as String?)?.isEmpty == true;

        if (needsSetup) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BusinessDetailsPage()),
            (route) => false, // Clear all previous routes
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BusinessDashboardPage()),
          );
        }
      }
      // Close modal is handled by replacement if we succeed, strictly speaking we are navigating AWAY.
      // If we just want to close modal and let parent handle it, we might need different logic,
      // but business flow usually goes to dashboard, which is a full screen replacement usually.
      // Actually, OwnerPanel used pushReplacement from the PARENT context.
      // Here we are in a Dialog. pushReplacement on the dialog context will replace the Dialog Route?
      // Or the route under it?
      // Dialog is a route. pushReplacement replaces the Dialog with the new page. That's fine.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('businessParams'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text("Back"),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Business Access",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("Manage your salon", style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Business Email",
                  prefixIcon: Icon(Icons.storefront),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v?.length ?? 0) < 6 ? "Min 6 chars" : null,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _processAuth(false), // Enter = Login
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _processAuth(false),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
                          "Login as Business",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : () => _processAuth(true),
                child: const Text("New partner? Create an account"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
