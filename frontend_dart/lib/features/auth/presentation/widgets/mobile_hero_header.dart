import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';

/// Hero header for mobile login screen with logo highlight
class MobileHeroHeader extends StatelessWidget {
  const MobileHeroHeader({
    super.key,
    this.title = 'Découvrez\nl\'Art du Sahel',
    this.subtitle = 'Connectez-vous avec les artisans, soutenez les talents locaux',
    this.logoAsset = 'assets/branding/logo.png',
  });

  final String title;
  final String subtitle;
  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AuthStyles.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo proéminent avec border radius et shadow
          ClipRRect(
            borderRadius: BorderRadius.circular(AuthStyles.radiusLarge),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 3,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                logoAsset,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuthStyles.spacing24,
                      vertical: AuthStyles.spacing16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AuthStyles.radiusLarge),
                    ),
                    child: const Text(
                      'SahelArt',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AuthStyles.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AuthStyles.spacing40),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.5,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AuthStyles.spacing16),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
