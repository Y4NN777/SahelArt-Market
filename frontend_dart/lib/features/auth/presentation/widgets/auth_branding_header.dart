import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';

/// Branding header component for authentication screens
class AuthBrandingHeader extends StatelessWidget {
  const AuthBrandingHeader({
    super.key,
    this.logoAsset = 'assets/branding/favicon_filled.png',
    this.showPill = true,
  });

  final String logoAsset;
  final bool showPill;

  @override
  Widget build(BuildContext context) {
    if (showPill) {
      return _BrandingPill(logoAsset: logoAsset);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Logo(logoAsset: logoAsset, size: 28),
        const SizedBox(width: AuthStyles.spacing12),
        const Text(
          'SahelArt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class _BrandingPill extends StatelessWidget {
  const _BrandingPill({required this.logoAsset});

  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuthStyles.spacing16,
        vertical: AuthStyles.spacing12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AuthStyles.radiusPill),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Logo(logoAsset: logoAsset, size: 20),
          const SizedBox(width: AuthStyles.spacing8),
          const Text(
            'SahelArt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({
    required this.logoAsset,
    required this.size,
  });

  final String logoAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AuthStyles.radiusSmall),
      child: Image.asset(
        logoAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: AuthStyles.primary,
            child: const Icon(
              Icons.image,
              color: Colors.white,
              size: 12,
            ),
          );
        },
      ),
    );
  }
}
