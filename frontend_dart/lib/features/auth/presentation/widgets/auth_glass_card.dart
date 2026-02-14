import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';

/// Modern glassmorphism card for authentication forms
class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10.0,
    this.opacity = 0.95,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthStyles.radiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AuthStyles.spacing32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(AuthStyles.radiusXLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: AuthStyles.glassShadow(),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Simple white card alternative (for mobile bottom sheet)
class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AuthStyles.spacing24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: borderRadius ??
            BorderRadius.circular(AuthStyles.radiusXLarge),
        boxShadow: AuthStyles.cardShadow(elevation: 0.5),
      ),
      child: child,
    );
  }
}
