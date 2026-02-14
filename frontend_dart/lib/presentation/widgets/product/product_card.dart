import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../data/services/favorites_service.dart';
import '../../../features/products/domain/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    this.onTap,
    this.favoritesService,
    this.onFavoritesChanged,
  });

  final Product product;
  final VoidCallback onAdd;
  final VoidCallback? onTap;
  final FavoritesService? favoritesService;
  final VoidCallback? onFavoritesChanged;

  Widget _buildProductImage(String imageUrl) {
    // Check if it's a local asset or network URL
    final isAsset = imageUrl.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF2F2F2),
            child: const Icon(Icons.broken_image, size: 36, color: Color(0xFFBDBDBD)),
          );
        },
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF2F2F2),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF2F2F2),
          child: const Icon(Icons.broken_image, size: 36, color: Color(0xFFBDBDBD)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: product.imageUrl != null
                          ? _buildProductImage(product.imageUrl!)
                          : Container(
                              color: const Color(0xFFF2F2F2),
                              child: const Icon(Icons.image_outlined, size: 36, color: Color(0xFFBDBDBD)),
                            ),
                    ),
                  ),
                  if (favoritesService != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          await favoritesService!.toggleFavorite(product.id);
                          onFavoritesChanged?.call();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x20000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Icon(
                            favoritesService!.isFavorite(product.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: favoritesService!.isFavorite(product.id)
                                ? AppColors.primary
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} CFA',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      InkWell(
                        onTap: product.stock > 0 ? onAdd : null,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: product.stock > 0 ? AppColors.primary : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 14, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
