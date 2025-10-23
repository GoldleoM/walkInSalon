import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =======================================================
/// 🧩 APP CONFIGURATION CENTER
/// Central place for all colors, text styles, themes, images, etc.
/// =======================================================
class AppConfig {
static const appName = 'WalkInSalon';
static const slogan = 'Smart Bookings for Salons';
static const version = '1.0.0';

// Access colors, text, constants, and decorations
static var colors = AppColors();
static final text = AppTextTheme();
static const constants = AppConstants();
static const decorations = AppDecorations();
static var images = AppImages();

// =======================================================
// 🎨 APP THEMES
// =======================================================

/// 🌞 Light Theme
static ThemeData get themeLight => ThemeData(
brightness: Brightness.light,
primaryColor: AppColors.primary,
scaffoldBackgroundColor: AppColors.background,
fontFamily: GoogleFonts.inter().fontFamily,
textTheme: AppTextTheme().textTheme,
colorScheme: const ColorScheme.light(
primary: AppColors.primary,
secondary: AppColors.secondary,
surface: AppColors.surface,
error: AppColors.error,
),
appBarTheme: const AppBarTheme(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.all(
Radius.circular(AppConstants.borderRadius),
),
),
),
),
outlinedButtonTheme: OutlinedButtonThemeData(
style: OutlinedButton.styleFrom(
side: const BorderSide(color: AppColors.border),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
),
),
),
textButtonTheme: TextButtonThemeData(
style: TextButton.styleFrom(
foregroundColor: AppColors.secondary,
textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
),
),
);

/// 🌚 Dark Theme
static ThemeData get themeDark => ThemeData(
brightness: Brightness.dark,
primaryColor: AppColors.darkPrimary,
scaffoldBackgroundColor: AppColors.darkBackground,
fontFamily: GoogleFonts.inter().fontFamily,
textTheme: AppTextTheme()
.textTheme
.apply(bodyColor: AppColors.darkTextPrimary, displayColor: AppColors.darkTextPrimary),
colorScheme: const ColorScheme.dark(
primary: AppColors.darkPrimary,
secondary: AppColors.darkSecondary,
surface: AppColors.darkSurface,
error: AppColors.error,
),
appBarTheme: const AppBarTheme(
backgroundColor: AppColors.darkSurface,
foregroundColor: AppColors.darkTextPrimary,
elevation: 0,
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.darkPrimary,
foregroundColor: Colors.black,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.all(
Radius.circular(AppConstants.borderRadius),
),
),
),
),
outlinedButtonTheme: OutlinedButtonThemeData(
style: OutlinedButton.styleFrom(
side: const BorderSide(color: AppColors.darkBorder),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
),
),
),
textButtonTheme: TextButtonThemeData(
style: TextButton.styleFrom(
foregroundColor: AppColors.darkSecondary,
textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
),
),
);

// =======================================================
// 🌗 Adaptive Helpers
// =======================================================

static Color adaptiveTextColor(BuildContext context) =>
Theme.of(context).brightness == Brightness.dark
? AppColors.darkTextPrimary
: AppColors.textPrimary;

static Color adaptiveBackground(BuildContext context) =>
Theme.of(context).brightness == Brightness.dark
? AppColors.darkBackground
: AppColors.background;

static Color adaptiveSurface(BuildContext context) =>
Theme.of(context).brightness == Brightness.dark
? AppColors.darkSurface
: AppColors.surface;

static Color adaptiveBorder(BuildContext context) =>
Theme.of(context).brightness == Brightness.dark
? AppColors.darkBorder
: AppColors.border;

static TextStyle heading(BuildContext context) =>
Theme.of(context).textTheme.headlineMedium!;
static TextStyle body(BuildContext context) =>
Theme.of(context).textTheme.bodyMedium!;
static TextStyle label(BuildContext context) =>
Theme.of(context).textTheme.labelLarge!;

static EdgeInsets get padding => const EdgeInsets.all(AppConstants.padding);
static BorderRadius get borderRadius =>
BorderRadius.circular(AppConstants.borderRadius);

/// Responsive font scaling for adaptive UIs
static double scaleFont(BuildContext context, double baseSize) {
final width = MediaQuery.of(context).size.width;
if (width > 1200) return baseSize * 1.3;
if (width > 800) return baseSize * 1.15;
return baseSize;
}
}

/// =======================================================
/// 🎨 COLOR PALETTE
/// =======================================================
class AppColors {
// Light
static const Color primary = Color(0xFF4E342E); // dark brown
static const Color secondary = Color(0xFF8D6E63); // mid brown
static const Color background = Color(0xFFFAFAFA); // light cream
static const Color surface = Color(0xFFFFFFFF);
static const Color textPrimary = Color(0xFF1C1C1C);
static const Color textSecondary = Color(0xFF6D4C41);
static const Color border = Color(0xFFE0E0E0);
static const Color error = Color(0xFFB00020);
static const Color success = Color(0xFF388E3C);
static const Color warning = Color(0xFFFBC02D);

// Dark
static const Color darkPrimary = Color(0xFFD7CCC8); // beige accent
static const Color darkSecondary = Color(0xFFA1887F);
static const Color darkBackground = Color(0xFF121212);
static const Color darkSurface = Color(0xFF1E1E1E);
static const Color darkTextPrimary = Color(0xFFF5F5F5);
static const Color darkTextSecondary = Color(0xFFBCAAA4);
static const Color darkBorder = Color(0xFF2C2C2C);
}

/// =======================================================
/// 🖋️ TEXT THEME
/// =======================================================
class AppTextTheme {
final TextTheme textTheme = TextTheme(
headlineLarge: GoogleFonts.poppins(
fontWeight: FontWeight.w700,
color: AppColors.textPrimary,
),
headlineMedium: GoogleFonts.poppins(
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
titleLarge: GoogleFonts.poppins(
fontWeight: FontWeight.w500,
color: AppColors.textPrimary,
),
bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
labelLarge: GoogleFonts.inter(
fontSize: 14,
fontWeight: FontWeight.w600,
color: AppColors.textPrimary,
),
);
}

/// =======================================================
/// 🖼️ ASSETS
/// =======================================================
class AppImages {
static const String logo = 'lib/assets/images/logo.png';
static const String loginBackground = 'lib/assets/images/login_background.png';
final String placeholder = 'lib/assets/images/placeholder.png';
final String defaultProfile = 'lib/assets/images/default_profile.jpg';
final String defaultCover = 'lib/assets/images/default_cover.jpg';
final String onboarding1 = 'lib/assets/images/onboarding1.png';
final String onboarding2 = 'lib/assets/images/onboarding2.png';
final String onboarding3 = 'lib/assets/images/onboarding3.png';
}

/// =======================================================
/// 🧾 CONSTANTS
/// =======================================================
class AppConstants {
const AppConstants();
static const double padding = 16;
static const double borderRadius = 12;
static const double smallRadius = 8;
static const Duration animationDuration = Duration(milliseconds: 300);
static const double elevation = 2.0;

// 🧊 For glass & shadows
static const double blurSigma = 10.0;
static const double shadowBlur = 12.0;
static const double shadowOpacity = 0.08;
}

/// =======================================================
/// 💎 DECORATIONS
/// =======================================================
class AppDecorations {
const AppDecorations();

/// Lightweight glass-like panel that’s efficient on all devices
static BoxDecoration glassPanel(BuildContext context) {
final isDark = Theme.of(context).brightness == Brightness.dark;
return BoxDecoration(
color: isDark
? Colors.white.withOpacity(0.05)
: Colors.white.withOpacity(0.12),
borderRadius: BorderRadius.circular(AppConstants.borderRadius),
border: Border.all(
color: isDark
? Colors.white.withOpacity(0.15)
: Colors.white.withOpacity(0.25),
),
boxShadow: shadowSoft(isDark: isDark),
);
}

/// Gradient background that adapts to light/dark mode
static LinearGradient dynamicGradient(BuildContext context) {
final isDark = Theme.of(context).brightness == Brightness.dark;
return LinearGradient(
colors: isDark
? [const Color(0xFF1A1C1F), const Color(0xFF0F1115)]
: [Colors.white, const Color(0xFFF7F8FA)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
);
}

/// 🔮 Soft shadow
static List<BoxShadow> shadowSoft({bool isDark = false}) => [
BoxShadow(
color: isDark
? Colors.black.withOpacity(0.3)
: Colors.brown.withOpacity(0.1),
blurRadius: AppConstants.shadowBlur,
offset: const Offset(0, 3),
),
];

/// 🌑 Elevated shadow
static List<BoxShadow> shadowElevated({bool isDark = false}) => [
BoxShadow(
color: isDark
? Colors.black.withOpacity(0.5)
: Colors.brown.withOpacity(0.2),
blurRadius: AppConstants.shadowBlur * 1.5,
offset: const Offset(0, 6),
),
];

/// 🪞 Reusable glass scaffold
static Widget glassScaffold({
required BuildContext context,
required Widget child,
double sigma = AppConstants.blurSigma,
}) {
return Container(
decoration: BoxDecoration(
gradient: dynamicGradient(context),
),
child: ClipRRect(
borderRadius: BorderRadius.circular(AppConstants.borderRadius),
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
child: child,
),
),
);
}
}
