import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/screens/customer/home/customer_home_screen.dart';
import 'package:walkinsalonapp/screens/intro/widgets/glass_pill.dart';
import 'package:walkinsalonapp/screens/intro/widgets/infinite_marquee.dart';
import 'package:walkinsalonapp/screens/intro/widgets/fluid_background.dart';
import 'package:walkinsalonapp/screens/intro/widgets/nebula_background.dart';
import 'package:walkinsalonapp/screens/intro/widgets/particle_overlay.dart';
import 'package:walkinsalonapp/widgets/auth/login_modal.dart';
import 'package:walkinsalonapp/widgets/custom_loader.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _isLoading = true;
  bool _isMarqueeActive = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _simulateLoading();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.offset > 50 &&
        !_isMarqueeActive) {
      setState(() {
        _isMarqueeActive = true;
      });
    }
  }

  Future<void> _simulateLoading() async {
    // Artificial delay to mask initial lag and ensure smooth entrance
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _showLoginModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const LoginModal(fromIntro: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CustomLoader(
            size: 100, // Slightly larger for the intro
            isOverlay: false,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // 1. Hero Section (Immersive & Premium)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // Cinematic Background (Ken Burns Effect)
                    Positioned.fill(
                      child:
                          Image.asset(AppImages.salonHeroBg, fit: BoxFit.cover)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(
                                begin: 1.0,
                                end: 1.15,
                                duration: 20.seconds,
                                curve: Curves.easeInOut,
                              ) // Slow subtle zoom
                              .animate()
                              .fadeIn(duration: 1200.ms, curve: Curves.easeOut),
                    ),

                    // Premium Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                              Colors.black,
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Floating Service Chips (Background Elements - Safe Zones)
                    // 1. Top Left (Very High - Safe)
                    Positioned(
                      top: 60,
                      left: 20,
                      child: GlassPill(text: "Haircuts ✂️")
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -10, duration: 4.seconds)
                          .moveX(begin: 0, end: 5, duration: 5.seconds),
                    ),

                    // 2. Right Side (Mid-Upper)
                    Positioned(
                      top: 180,
                      right: -10,
                      child: GlassPill(text: "Spa & Facial 🧖‍♀️")
                          .animate(
                            delay: 800.ms,
                            onPlay: (c) => c.repeat(reverse: true),
                          )
                          .moveY(begin: 0, end: 12, duration: 5.seconds)
                          .moveX(begin: 0, end: -8, duration: 4.5.seconds),
                    ),

                    // 3. Right Side (Lower, but clear of Left text)
                    Positioned(
                      top: 280,
                      right: 40,
                      child: GlassPill(text: "Makeup 💄", isSmall: true)
                          .animate(
                            delay: 1.5.seconds,
                            onPlay: (c) => c.repeat(reverse: true),
                          )
                          .moveY(begin: 0, end: -15, duration: 6.seconds)
                          .rotate(begin: -0.05, end: 0.05, duration: 7.seconds),
                    ),

                    // 4. Top Right (Clumped for depth)
                    Positioned(
                      top: 90,
                      right: 80,
                      child: GlassPill(text: "Massage 💆‍♂️", isSmall: true)
                          .animate(
                            delay: 2.seconds,
                            onPlay: (c) => c.repeat(reverse: true),
                          )
                          .moveY(begin: 0, end: 8, duration: 4.seconds),
                    ),

                    // 5. Top Center (High up)
                    Positioned(
                      top: 40,
                      left: 160,
                      child:
                          Opacity(
                                opacity: 0.6,
                                child: GlassPill(
                                  text: "Nails 💅",
                                  isSmall: true,
                                ),
                              )
                              .animate(
                                delay: 300.ms,
                                onPlay: (c) => c.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.0, 1.0),
                                duration: 5.seconds,
                              )
                              .moveY(begin: 0, end: -5, duration: 3.seconds),
                    ),

                    // Gold Dust Particles (Floating Magic)
                    const Positioned.fill(
                      child: ParticleOverlay(), // Custom particle system
                    ),

                    // Business Login (Top Right)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _GlassButton(
                            label: "Login/SignUp",
                            onPressed: () => _showLoginModal(context),
                          ),
                        ),
                      ),
                    ),

                    // Main Hero Content (Bottom Left)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Glass Logo Badge with Gold Glow
                              Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37),
                                        width: 1.5,
                                      ), // Gold border
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFD4AF37,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 30,
                                          spreadRadius: 2,
                                          offset: const Offset(
                                            0,
                                            0,
                                          ), // Center glow
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(26),
                                      child: Image.asset(
                                        AppImages.logo,
                                        height: 130,
                                        width: 130,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scaleXY(
                                    begin: 1.0,
                                    end: 1.05,
                                    duration: 2000.ms,
                                    curve: Curves.easeInOut,
                                  ) // Breathing effect
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .slide(begin: const Offset(0, 0.2)),

                              const SizedBox(height: 24),

                              // Dynamic Headline
                              // Dynamic Headline with Gold Accent
                              RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 64, // Larger font
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.0,
                                        letterSpacing: -1.0,
                                      ),
                                      children: [
                                        const TextSpan(text: "Style.\nBook.\n"),
                                        TextSpan(
                                          text: "Repeat.",
                                          style: TextStyle(
                                            color: const Color(
                                              0xFFD4AF37,
                                            ), // Gold accent
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 200.ms)
                                  .slide(begin: const Offset(0, 0.1)),

                              const SizedBox(height: 16),

                              // Subheading
                              Text(
                                "Your favorite salons, instantly available at your fingertips.",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.5,
                                  fontWeight: FontWeight.w300,
                                ),
                              ).animate().fadeIn(
                                duration: 800.ms,
                                delay: 400.ms,
                              ),

                              const SizedBox(height: 40),

                              // Primary Action Button (Premium Glow)
                              Container(
                                    width: double.infinity,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: const Color(
                                            0xFFD4AF37,
                                          ).withValues(alpha: 0.2), // Gold tint
                                          blurRadius: 30,
                                          spreadRadius: -5,
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _navigateToHome(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Get Started",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 600.ms)
                                  .slide(begin: const Offset(0, 0.2)),

                              const SizedBox(height: 32),

                              // Social Proof (Avatar Stack)
                              Row(
                                    children: [
                                      SizedBox(
                                        height: 36,
                                        width: 100,
                                        child: Stack(
                                          children: [
                                            for (int i = 0; i < 4; i++)
                                              Positioned(
                                                left: i * 24.0,
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        [
                                                          AppConfig
                                                              .images
                                                              .defaultProfile,
                                                          AppImages
                                                              .featureStylist,
                                                          AppImages
                                                              .featureBooking,
                                                          AppConfig
                                                              .images
                                                              .defaultProfile,
                                                        ][i],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Color(0xFFD4AF37),
                                                size: 16,
                                              ),
                                              Text(
                                                " 4.9",
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "from 2k+ happy clients",
                                            style: GoogleFonts.inter(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                  .animate()
                                  .fadeIn(duration: 800.ms, delay: 800.ms)
                                  .slide(begin: const Offset(0, 0.1)),

                              const SizedBox(height: 10),

                              // Scroll indicator
                              Center(
                                child:
                                    Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                        )
                                        .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true),
                                        )
                                        .moveY(
                                          begin: 0,
                                          end: 5,
                                          duration: 1200.ms,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 1.5 Infinite Marquee (Divider)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 20, bottom: 0),
                child: InfiniteMarquee(
                  text:
                      "STYLE  •  ELEGANCE  •  CONVENIENCE  •  BEAUTY  •  ARTISTRY",
                  speed: 40,
                  active: _isMarqueeActive,
                ),
              ),

              // 2. Value Proposition (Fluid Motion)
              Stack(
                children: [
                  // Background Motion
                  const Positioned.fill(child: FluidBackground()),

                  // Content
                  Container(
                    // color: Colors.white, // REMOVED to show fluid bg
                    padding: const EdgeInsets.symmetric(
                      vertical: 60,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        _SectionTitle(
                          title: "Redefining Beauty",
                          subtitle:
                              "Experience a seamless journey from discovery to the chair.",
                          isDark: false,
                        ),
                        const SizedBox(height: 60),

                        // Features Grid (Staggered-ish look via Column)
                        Column(
                          children: [
                            // Feature 1: Zero Wait Time (with Image)
                            _VisualFeatureRow(
                              imagePath: AppImages.featureBooking,
                              title: "Zero Wait Time",
                              description:
                                  "Real-time availability means you walk in, not wait.",
                              isLeft: true,
                            ),
                            const SizedBox(height: 40),

                            // Feature 2: Top Stylists (with Image)
                            _VisualFeatureRow(
                              imagePath: AppImages.featureStylist,
                              title: "Top Stylists",
                              description:
                                  "Curated professionals verified by real community reviews.",
                              isLeft: false,
                            ),
                            const SizedBox(height: 40),

                            // Feature 3: Personalized Care
                            _VisualFeatureRow(
                              imagePath: AppImages.featurePersonalCare,
                              title: "Personalized Care",
                              description:
                                  "Services tailored specifically to your style and preferences.",
                              isLeft: true,
                            ),
                            const SizedBox(height: 40),

                            // Feature 4: Premium Ambience
                            _VisualFeatureRow(
                              imagePath: AppImages.featureAmbience,
                              title: "Premium Ambience",
                              description:
                                  "Relax in environments designed for comfort and luxury.",
                              isLeft: false,
                            ),
                            const SizedBox(height: 40),

                            // Feature 5: Hygiene & Safety
                            _VisualFeatureRow(
                              imagePath: AppImages.featureHygiene,
                              title: "Hygiene & Safety",
                              description:
                                  "Top-tier sanitation standards for your peace of mind.",
                              isLeft: true,
                            ),
                            const SizedBox(height: 40),

                            // Feature 6: Instant Booking (Icon)
                            _FeatureRow(
                              icon: Icons.flash_on_rounded,
                              title: "Instant Booking",
                              description:
                                  "Secure your spot in seconds. No calls required.",
                              isLeft: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 3. Vision Section (Dark Theme + Nebula)
              Stack(
                children: [
                  const Positioned.fill(child: NebulaBackground()),
                  Container(
                    width: double.infinity,
                    // Remove solid color, handled by Nebula
                    padding: const EdgeInsets.symmetric(
                      vertical: 80,
                      horizontal: 32,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Our Vision".toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "We believe beauty should be effortless. WalkInSalon connects you with the artistry you desire, exactly when you need it.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _GlassButton(
                          label: "Explore Stylists",
                          onPressed: () => _navigateToHome(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 4. Contact Footer (Minimalist)
              Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "WalkInSalon",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {}, // Social link placeholder
                          icon: const Icon(Icons.share, color: Colors.white),
                          tooltip: "Share",
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Contact Grid
                    Wrap(
                      spacing: 40,
                      runSpacing: 20,
                      children: [
                        _ContactItem(
                          icon: Icons.email_outlined,
                          label: "support@walkinsalon.com",
                        ),
                        _ContactItem(
                          icon: Icons.location_on_outlined,
                          label: "Jaipur, Rajasthan, India",
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "© ${DateTime.now().year} WalkInSalon. Designed for elegance.",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GlassButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withValues(alpha: 0.1),
          height: 40, // Fixed height for consistency
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        Container(width: 40, height: 2, color: const Color(0xFFD4AF37))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .custom(
              duration: 2.seconds,
              builder: (context, value, child) {
                return Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFD4AF37,
                        ).withValues(alpha: 0.5 * value),
                        blurRadius: (10 * value).toDouble(),
                        spreadRadius: (2 * value).toDouble(),
                      ),
                    ],
                  ),
                );
              },
            ) // Glowing pulse
            .custom(
              duration: 3.seconds,
              builder: (context, value, child) {
                return Container(
                  width: 40 + (value * 20), // Expand and contract
                  height: 2,
                  color: const Color(0xFFD4AF37),
                  child: child,
                );
              },
            ), // Gold accent
        const SizedBox(height: 16),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: color.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _VisualFeatureRow extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isLeft;

  const _VisualFeatureRow({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isLeft) const Spacer(),
        Expanded(
          flex: 4, // Take up more space for content
          child: _HoverInteractive(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: isLeft
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (isLeft) ...[
                  _ImageBox(imagePath: imagePath),
                  const SizedBox(width: 24),
                ],

                Flexible(
                  child: Column(
                    crossAxisAlignment: isLeft
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        textAlign: isLeft ? TextAlign.left : TextAlign.right,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isLeft) ...[
                  const SizedBox(width: 24),
                  _ImageBox(imagePath: imagePath),
                ],
              ],
            ),
          ),
        ),
        if (isLeft) const Spacer(),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2);
  }
}

class _ImageBox extends StatelessWidget {
  final String imagePath;
  const _ImageBox({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(imagePath, fit: BoxFit.cover)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 4.seconds,
            ) // Breathing effect
            .shimmer(
              duration: 3.seconds,
              delay: 2.seconds,
              color: Colors.white.withValues(alpha: 0.2),
            ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLeft;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isLeft) const Spacer(),
        Expanded(
          flex: 2, // Take up more space for content
          child: _HoverInteractive(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isLeft
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (isLeft) ...[
                  _IconBox(icon: icon),
                  const SizedBox(width: 20),
                ],

                Flexible(
                  child: Column(
                    crossAxisAlignment: isLeft
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        textAlign: isLeft ? TextAlign.left : TextAlign.right,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isLeft) ...[
                  const SizedBox(width: 20),
                  _IconBox(icon: icon),
                ],
              ],
            ),
          ),
        ),
        if (isLeft) const Spacer(),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2);
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black, size: 28)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 2.seconds,
          ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}

// --- New Interactive Wrapper ---
class _HoverInteractive extends StatefulWidget {
  final Widget child;
  const _HoverInteractive({required this.child});

  @override
  State<_HoverInteractive> createState() => _HoverInteractiveState();
}

class _HoverInteractiveState extends State<_HoverInteractive> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovering ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
