import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

/// Design tokens and constants for authentication screens
class AuthStyles {
  AuthStyles._();

  // Spacing system
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusPill = 999.0;

  // Breakpoints
  static const double breakpointTablet = 600.0;
  static const double breakpointDesktop = 900.0;

  // Card constraints
  static const double maxCardWidth = 460.0;
  static const double maxMobileSheetHeight = 680.0;

  // Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);
  static const Curve animationCurve = Curves.easeInOutCubic;

  // Colors - Use AppColors constants
  static const Color primary = AppColors.primary;
  static const Color primaryDark = Color(0xFFB85A0A);
  static const Color primaryLight = Color(0xFFFF9844);
  static const Color warmTaupe = Color(0xFFF4F1DE);
  static const Color deepOrange = Color(0xFF8B3A0A);

  // Gradient overlays
  static LinearGradient heroGradientOverlay({double opacity = 0.7}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.2 * opacity),
        Colors.black.withOpacity(0.6 * opacity),
      ],
      stops: const [0.0, 1.0],
    );
  }

  static LinearGradient backgroundGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFEC7813), // primary orange
        Color(0xFF8B3A0A), // deepOrange
      ],
    );
  }

  // Shadows
  static List<BoxShadow> cardShadow({double elevation = 1.0}) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08 * elevation),
        blurRadius: 16 * elevation,
        offset: Offset(0, 8 * elevation),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04 * elevation),
        blurRadius: 4 * elevation,
        offset: Offset(0, 2 * elevation),
      ),
    ];
  }

  static List<BoxShadow> glassShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }

  // Text styles
  static const TextStyle heroTitle = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  static const TextStyle heroSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Colors.white70,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Color(0xFF1F2937),
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B7280),
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF374151),
  );

  // Input decoration theme
  static InputDecorationTheme inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.0),
      ),
      labelStyle: labelText,
      floatingLabelStyle: const TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
