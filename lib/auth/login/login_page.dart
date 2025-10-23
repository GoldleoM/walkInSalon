import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'customer_panel.dart';
import 'owner_panel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
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
              Colors.black.withOpacity(isDark ? 0.5 : 0.25),
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
                        // 🖼️ Logo
                        Image.asset(
                              AppImages
                                  .logo, // Make sure this path is in pubspec.yaml
                              height: 90,
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

                        // 🧠 App Name with Outline Effect
                        Text(
                          AppConfig.appName,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.4),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 8),

                        // ✨ Slogan / Subtitle
                        Text(
                          AppConfig.slogan,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    )
                    .animate(onPlay: (controller) => controller.forward())
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slide(
                      begin: const Offset(0, -0.05),
                      end: Offset.zero,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 40),

                // 🧩 Panels Area
                Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.glassPanel(context),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 👤 Customer Panel
                            Expanded(
                              child: const CustomerPanel()
                                  .animate(delay: 100.ms)
                                  .fadeIn(
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slide(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  ),
                            ),

                            Container(
                              width: 1,
                              height: 500,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              color: Colors.white.withOpacity(0.25),
                            ),

                            // 💈 Owner Panel
                            Expanded(
                              child: const OwnerPanel()
                                  .animate(delay: 250.ms)
                                  .fadeIn(
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slide(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const CustomerPanel()
                                .animate(delay: 100.ms)
                                .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                                .slide(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                  duration: 400.ms,
                                  curve: Curves.easeOut,
                                ),

                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 28),
                              color: Colors.white.withOpacity(0.25),
                            ),

                            const OwnerPanel()
                                .animate(delay: 250.ms)
                                .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                                .slide(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                  duration: 400.ms,
                                  curve: Curves.easeOut,
                                ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
