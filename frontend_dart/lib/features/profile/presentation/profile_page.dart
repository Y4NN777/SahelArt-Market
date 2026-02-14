import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.onLogout,
    this.isGuest = false,
    this.onLogin,
    this.isVendor = false,
    this.onNavigateToHome,
  });

  final Future<void> Function() onLogout;
  final bool isGuest;
  final VoidCallback? onLogin;
  final bool isVendor;
  final VoidCallback? onNavigateToHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: onNavigateToHome ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF1ECE7),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (isGuest) _buildGuestHeader() else _buildProfileHeader(),
            const SizedBox(height: 24),
            if (!isGuest && isVendor) ...[
              _buildSection(
                title: 'Ma Boutique',
                items: [
                  _MenuItem(
                    icon: Icons.storefront_outlined,
                    label: 'Mes Produits',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.add_business_outlined,
                    label: 'Ajouter un Produit',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Statistiques',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Commandes Reçues',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else if (!isGuest) ...[
              _buildSection(
                title: 'Mes Achats',
                items: [
                  _MenuItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Mes Commandes',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.favorite_border,
                    label: 'Mes Favoris',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Adresses de Livraison',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _buildSection(
              title: 'Paramètres',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Informations Personnelles',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  label: 'Sécurité',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.language_outlined,
                  label: 'Langue',
                  trailing: 'Français',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Support',
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Centre d\'Aide',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'À Propos',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.policy_outlined,
                  label: 'Politique de Confidentialité',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isGuest)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annuler'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.danger,
                          ),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await onLogout();
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Se Déconnecter',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0x14EC7813),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mode Invité',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connectez-vous pour accéder à toutes les fonctionnalités',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login),
              label: const Text(
                'Se Connecter',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ou continuez à parcourir en mode invité',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFF9B278)],
              ),
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 33,
                backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA_urE2kK8zcLSp27hdF1ltbVdh2Mb3genieEMmX7181vUxmBvMoFXSYjXKKcXiJLaXM-ZC8WpLAd4g1Erm7N9_bcQ_Zf_Cju7n48nhbQGyNrIbNDG244FymVCXUMWqoGyCKChsxTx0vVUh4r4dzWTQBHthUhdPcPiQALpBPEj31dgyEcNFZgp3QfP9W5yiVbPRT_T4Prbrjo9b1nKPiGL24QTco6ZYr0JlbUc5VIF_piF4aKlG3L3cEPEFVDeoNztQ3nTS5nJtsXSW',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVendor ? 'Fatoumata Diallo' : 'Amadou Traoré',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVendor ? 'artisan.diallo@sahelart.com' : 'amadou.traore@example.com',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x14EC7813),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isVendor ? 'Artisan' : 'Client',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_MenuItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.map((item) {
            final isLast = item == items.last;
            return _buildMenuItem(item, isLast: isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, {required bool isLast}) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFF3F4F6)),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(item.icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (item.trailing != null)
              Text(
                item.trailing!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
}
