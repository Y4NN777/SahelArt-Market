import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../data/mock/products_mock.dart';
import '../../../data/services/favorites_service.dart';
import '../../../presentation/widgets/product/product_card.dart';
import '../../products/domain/product.dart';
import '../../products/presentation/product_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    super.key,
    required this.favoritesService,
    required this.onAddToCart,
    required this.onNavigateToHome,
    this.onFavoritesChanged,
  });

  final FavoritesService favoritesService;
  final void Function(Product product) onAddToCart;
  final VoidCallback? onNavigateToHome;
  final VoidCallback? onFavoritesChanged;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> get _favoriteProducts {
    final favoriteIds = widget.favoritesService.favorites;
    return ProductsMock.products
        .where((p) => favoriteIds.contains(p.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoriteProducts;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onNavigateToHome ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Mes Favoris',
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
      body: favorites.isEmpty ? _buildEmptyState() : _buildFavoritesList(favorites),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0x14EC7813),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun favori',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Les produits que vous aimez apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<Product> favorites) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ProductCard(
          product: product,
          onAdd: () => widget.onAddToCart(product),
          favoritesService: widget.favoritesService,
          onFavoritesChanged: () {
            widget.onFavoritesChanged?.call();
            if (mounted) setState(() {});
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsPage(
                  product: product,
                  onAddToCart: () => widget.onAddToCart(product),
                  favoritesService: widget.favoritesService,
                  onFavoritesChanged: () {
                    widget.onFavoritesChanged?.call();
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ).then((_) {
              if (mounted) setState(() {});
            });
          },
        );
      },
    );
  }
}
