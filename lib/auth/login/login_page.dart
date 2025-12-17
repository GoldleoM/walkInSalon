import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'customer_panel.dart';
import 'owner_panel.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isBusiness = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.loginBackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: isDark ? 0.7 : 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌟 Logo + Branding Header
                Column(
                      children: [
                        Image.asset(
                              AppImages.logo,
                              height: 80,
                              fit: BoxFit.contain,
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 12),
                        Text(
                          AppConfig.appName,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConfig.slogan,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    )
                    .animate(onPlay: (controller) => controller.forward())
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(begin: -0.1, end: 0, duration: 350.ms),

                const SizedBox(height: 32),

                // 🧩 Unified Card with Toggle
                Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      padding: const EdgeInsets.all(24),
                      decoration: AppDecorations.glassPanel(context),
                      child: Column(
                        children: [
                          // 🎚️ Toggle Switch
                          _LoginToggle(
                            isBusiness: _isBusiness,
                            onChanged: (val) =>
                                setState(() => _isBusiness = val),
                          ),
                          const SizedBox(height: 32),

                          // 🔄 Animated Panel Switcher
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _isBusiness
                                ? OwnerPanel(
                                    key: const ValueKey('owner'),
                                    onLoginSuccess: widget.onLoginSuccess,
                                  )
                                : CustomerPanel(
                                    key: const ValueKey('customer'),
                                    onLoginSuccess: widget.onLoginSuccess,
                                  ),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginToggle extends StatelessWidget {
  final bool isBusiness;
  final ValueChanged<bool> onChanged;

  const _LoginToggle({required this.isBusiness, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          // Animated Background Indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isBusiness
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Clickable Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: !isBusiness ? Colors.white : colors.onSurface,
                      ),
                      child: const Text("Customer"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: isBusiness ? Colors.white : colors.onSurface,
                      ),
                      child: const Text("Business"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
