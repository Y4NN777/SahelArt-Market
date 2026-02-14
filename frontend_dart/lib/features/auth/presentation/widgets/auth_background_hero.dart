import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';

/// Modern hero background with gradient and decorative elements
class AuthBackgroundHero extends StatelessWidget {
  const AuthBackgroundHero({
    super.key,
    this.showPattern = true,
    this.backgroundImage,
    this.overlayOpacity = 0.7,
    this.imageScale = 1.0,
  });

  final bool showPattern;
  final String? backgroundImage;
  final double overlayOpacity;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image if provided
        if (backgroundImage != null)
          Image.asset(
            backgroundImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: AuthStyles.backgroundGradient(),
                ),
              );
            },
          )
        else
          // Fallback gradient
          Container(
            decoration: BoxDecoration(
              gradient: AuthStyles.backgroundGradient(),
            ),
          ),

        // Overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2 * overlayOpacity),
                Colors.black.withOpacity(0.5 * overlayOpacity),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    this.opacity = 0.1,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}
