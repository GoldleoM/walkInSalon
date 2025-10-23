import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';

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
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: AppConstants.elevation,
      color: colors.surface.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(color: colors.outline.withOpacity(0.1)),
      ),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
              ),
              const SizedBox(height: 18),

              // ✉️ Email field
              TextFormField(
                controller: emailController,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: colors.surface.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                    borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
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

              const SizedBox(height: 14),

              // 🔒 Password field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: colors.surface.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                    borderSide: BorderSide(color: colors.outline.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // 🧩 Login button
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                  ),
                  textStyle: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white),
                ),
                child: Text(buttonText),
              ),

              const SizedBox(height: 8),

              // 🔗 Footer action
              TextButton(
                onPressed: onFooterPressed,
                child: Text(
                  footerText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colors.onSurface.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
