import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/colors.dart';
import '../../data/services/favorites_service.dart';
import '../../features/cart/domain/cart_item.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/favorites/presentation/favorites_page.dart';
import '../../features/products/domain/product.dart';
import '../../features/products/presentation/home_page.dart';
import '../../features/profile/presentation/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({
    super.key,
    required this.apiClient,
    required this.cart,
    required this.onLogout,
    required this.onAddToCart,
    required this.onUpdateQuantity,
    required this.onCheckout,
    required this.favoritesService,
    this.isGuest = true,
    this.onLogin,
    this.onFavoritesChanged,
  });

  final ApiClient apiClient;
  final List<CartItem> cart;
  final Future<void> Function() onLogout;
  final void Function(Product product) onAddToCart;
  final void Function(Product product, int quantity) onUpdateQuantity;
  final Future<String> Function() onCheckout;
  final FavoritesService favoritesService;
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onFavoritesChanged;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  bool _checkoutLoading = false;

  int get _cartQty => widget.cart.fold(0, (sum, item) => sum + item.quantity);

  void _navigateToHome() {
    setState(() => _currentIndex = 0);
  }

  void _navigateToCart() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            apiClient: widget.apiClient,
            cart: widget.cart,
            onLogout: widget.onLogout,
            onAddToCart: widget.onAddToCart,
            onUpdateQuantity: widget.onUpdateQuantity,
            onCheckout: widget.onCheckout,
            favoritesService: widget.favoritesService,
            onFavoritesChanged: widget.onFavoritesChanged,
          ),
          CartPage(
            cart: widget.cart,
            onUpdateQuantity: widget.onUpdateQuantity,
            onCheckout: _handleCheckout,
            checkoutLoading: _checkoutLoading,
            onNavigateToHome: _navigateToHome,
          ),
          FavoritesPage(
            favoritesService: widget.favoritesService,
            onAddToCart: widget.onAddToCart,
            onNavigateToHome: _navigateToHome,
            onFavoritesChanged: widget.onFavoritesChanged,
          ),
          ProfilePage(
            isGuest: widget.isGuest,
            onLogin: widget.onLogin,
            onLogout: widget.onLogout,
            isVendor: false,
            onNavigateToHome: _navigateToHome,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1ECE7))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              active: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavItem(
              icon: Icons.category_outlined,
              activeIcon: Icons.category,
              label: 'Browse',
              active: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Browse - Coming soon!')),
                );
              },
            ),
            _CenterCartFab(
              itemCount: _cartQty,
              onTap: _navigateToCart,
            ),
            _NavItemWithBadge(
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              label: 'Saved',
              active: _currentIndex == 2,
              badgeCount: widget.favoritesService.count,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              active: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _handleCheckout() async {
    setState(() => _checkoutLoading = true);
    try {
      final orderId = await widget.onCheckout();
      return orderId;
    } finally {
      if (mounted) {
        setState(() {
          _checkoutLoading = false;
          _currentIndex = 0; // Return to home after checkout
        });
      }
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemWithBadge extends StatelessWidget {
  const _NavItemWithBadge({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(active ? activeIcon : icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CenterCartFab extends StatelessWidget {
  const _CenterCartFab({
    required this.itemCount,
    required this.onTap,
  });

  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -18),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55EC7813),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 26,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 99 ? '99+' : '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
