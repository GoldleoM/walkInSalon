import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/auth/login/login_page.dart';
import 'package:walkinsalonapp/screens/customer/home/customer_home_screen.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CustomerHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section (Full Screen)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: Image.asset(
                      AppImages.loginBackground,
                      fit: BoxFit.cover,
                    ).animate().fadeIn(duration: 800.ms),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Bar (Business Login)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _navigateToLogin(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                "Sign In / Business",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Image.asset(
                                  AppImages.logo,
                                  height: 60,
                                  width: 60,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 24),

                          // Title
                          Text(
                                "Book Your Next\nStyle Instantly",
                                style: GoogleFonts.poppins(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 16),

                          // Slogan
                          Text(
                                "Discover top-rated salons, book appointments in seconds, and skip the wait.",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 600.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 48),

                          // CTA Button
                          SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _navigateToHome(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    "Get Started",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 800.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 20),

                          // Scroll Indicator
                          Center(
                            child:
                                Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      size: 30,
                                    )
                                    .animate(onPlay: (c) => c.repeat())
                                    .moveY(
                                      begin: 0,
                                      end: 10,
                                      duration: 1000.ms,
                                      curve: Curves.easeInOut,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. What We Do Section
            Container(
              color: colors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                children: [
                  _SectionHeader(
                    title: "What We Do",
                    subtitle: "Simplifying your salon experience",
                  ),
                  const SizedBox(height: 40),
                  _FeatureCard(
                    icon: Icons.calendar_today_rounded,
                    title: "Instant Booking",
                    description:
                        "Book appointments anytime, anywhere. No more phone calls or waiting on hold.",
                    delay: 0,
                  ),
                  const SizedBox(height: 24),
                  _FeatureCard(
                    icon: Icons.location_on_rounded,
                    title: "Discover Nearby",
                    description:
                        "Find the best salons and stylists in your area with real-time availability.",
                    delay: 200,
                  ),
                  const SizedBox(height: 24),
                  _FeatureCard(
                    icon: Icons.star_rounded,
                    title: "Trusted Reviews",
                    description:
                        "Read verified reviews from other customers to choose the perfect stylist for you.",
                    delay: 400,
                  ),
                ],
              ),
            ),

            // 3. Who We Are Section
            Container(
              width: double.infinity,
              color: colors.primary.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                children: [
                  _SectionHeader(
                    title: "Who We Are",
                    subtitle: "Passionate about style & convenience",
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "We are a team of tech enthusiasts and beauty lovers dedicated to modernizing the salon industry. Our mission is to bridge the gap between talented stylists and clients looking for their next great look.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      color: colors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "WalkInSalon empowers businesses to grow and customers to look their best, effortlessly.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Contact Section
            Container(
              color: const Color(0xFF1A1A1A), // Dark footer background
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                children: [
                  Text(
                    "Get in Touch",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Have questions or need support? We're here to help.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _ContactRow(
                    icon: Icons.email_outlined,
                    text: "support@walkinsalon.com",
                  ),
                  const SizedBox(height: 16),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    text: "+1 (555) 123-4567",
                  ),
                  const SizedBox(height: 16),
                  _ContactRow(
                    icon: Icons.location_on_outlined,
                    text: "123 Style Avenue, New York, NY",
                  ),
                  const SizedBox(height: 48),

                  // Footer CTA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => _navigateToLogin(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text("Join Us Today"),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Copyright
                  Text(
                    "© ${DateTime.now().year} WalkInSalon. All rights reserved.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideY(begin: 0.1, end: 0);
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
