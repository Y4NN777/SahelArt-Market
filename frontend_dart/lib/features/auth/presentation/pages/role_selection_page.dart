import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';
import '../widgets/auth_background_hero.dart';
import '../widgets/auth_branding_header.dart';

/// Role selection page - Choose between Customer and Vendor
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({
    super.key,
    required this.onRoleSelected,
    required this.onBackToLogin,
    this.onSkip,
  });

  final Function(String role) onRoleSelected;
  final VoidCallback onBackToLogin;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthStyles.warmTaupe,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackgroundHero(
            backgroundImage: 'assets/branding/login_overlay_background.png',
            overlayOpacity: 0.2,
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(AuthStyles.spacing16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onBackToLogin,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        tooltip: 'Retour',
                      ),
                      const SizedBox(width: AuthStyles.spacing8),
                      const AuthBrandingHeader(showPill: true),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AuthStyles.spacing24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title
                            const Text(
                              'Créer un compte',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AuthStyles.spacing12),
                            const Text(
                              'Choisissez le type de compte qui vous correspond',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: AuthStyles.spacing48),

                            // Role cards
                            _RoleCard(
                              title: 'Client',
                              subtitle: 'Je veux acheter de l\'artisanat authentique',
                              icon: Icons.shopping_bag_outlined,
                              onTap: () => onRoleSelected('customer'),
                            ),

                            const SizedBox(height: AuthStyles.spacing20),

                            _RoleCard(
                              title: 'Artisan / Vendeur',
                              subtitle: 'Je veux vendre mes créations artisanales',
                              icon: Icons.storefront_outlined,
                              onTap: () => onRoleSelected('vendor'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Guest mode option
                if (onSkip != null) ...[
                  const SizedBox(height: AuthStyles.spacing16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AuthStyles.spacing24),
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AuthStyles.spacing12),
                      ),
                      child: const Text(
                        'Continuer sans compte',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuthStyles.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AuthStyles.spacing24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AuthStyles.radiusLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AuthStyles.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AuthStyles.primary,
                ),
              ),

              const SizedBox(width: AuthStyles.spacing20),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: AuthStyles.spacing4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AuthStyles.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
