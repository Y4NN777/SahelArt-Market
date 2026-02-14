import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../data/services/favorites_service.dart';
import '../../../presentation/widgets/common/confirmation_modal.dart';
import '../../products/domain/product.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.favoritesService,
    this.onFavoritesChanged,
  });

  final Product product;
  final VoidCallback onAddToCart;
  final FavoritesService? favoritesService;
  final VoidCallback? onFavoritesChanged;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  Widget _buildProductImage(String imageUrl) {
    final isAsset = imageUrl.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFF2F2F2),
          child: const Icon(Icons.broken_image, size: 80, color: Color(0xFFBDBDBD)),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF2F2F2),
        child: const Icon(Icons.broken_image, size: 80, color: Color(0xFFBDBDBD)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const CircleAvatar(
                    backgroundColor: Color(0x55FFFFFF),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: widget.favoritesService != null
                          ? () async {
                              await widget.favoritesService!.toggleFavorite(widget.product.id);
                              setState(() {});
                              widget.onFavoritesChanged?.call();
                            }
                          : null,
                      child: CircleAvatar(
                        backgroundColor: widget.favoritesService?.isFavorite(widget.product.id) ?? false
                            ? Colors.white
                            : const Color(0x55FFFFFF),
                        child: Icon(
                          widget.favoritesService?.isFavorite(widget.product.id) ?? false
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.favoritesService?.isFavorite(widget.product.id) ?? false
                              ? AppColors.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.product.imageUrl != null
                      ? _buildProductImage(widget.product.imageUrl!)
                      : Container(
                          color: const Color(0xFFF2F2F2),
                          child: const Icon(Icons.image_outlined, size: 80, color: Color(0xFFBDBDBD)),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Badge(text: 'Only ${widget.product.stock} left'),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 18, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.product.rating} (${widget.product.reviewsCount})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CFA ${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x14EC7813),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuA_urE2kK8zcLSp27hdF1ltbVdh2Mb3genieEMmX7181vUxmBvMoFXSYjXKKcXiJLaXM-ZC8WpLAd4g1Erm7N9_bcQ_Zf_Cju7n48nhbQGyNrIbNDG244FymVCXUMWqoGyCKChsxTx0vVUh4r4dzWTQBHthUhdPcPiQALpBPEj31dgyEcNFZgp3QfP9W5yiVbPRT_T4Prbrjo9b1nKPiGL24QTco6ZYr0JlbUc5VIF_piF4aKlG3L3cEPEFVDeoNztQ3nTS5nJtsXSW',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Crafted by',
                                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                                  ),
                                  Text(
                                    widget.product.artisan?.name ?? 'Fatoumata Diallo',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    widget.product.artisan?.location ?? 'Segou, Mali',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'The Story',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description ?? 'This authentic Bogolanfini is hand-dyed using fermented mud and plant leaves, a tradition passed down through generations.',
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Specifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.4,
                        children: const [
                          _Spec(label: 'Material', value: '100% Organic Cotton'),
                          _Spec(label: 'Dimensions', value: '145cm x 210cm'),
                          _Spec(label: 'Origin', value: 'Mali, West Africa'),
                          _Spec(label: 'Weight', value: '0.8 kg'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    // Quantity Selector - Plus compact
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                            child: Container(
                              width: 32,
                              height: 44,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.remove,
                                size: 18,
                                color: _quantity > 1
                                    ? AppColors.textPrimary
                                    : const Color(0xFFD1D5DB),
                              ),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _quantity < widget.product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                            child: Container(
                              width: 32,
                              height: 44,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: _quantity < widget.product.stock
                                    ? AppColors.textPrimary
                                    : const Color(0xFFD1D5DB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Total Price - Plus compact
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${((widget.product.price * _quantity) / 1000).toStringAsFixed(0)}k CFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bouton Ajouter - Plus compact
                    FilledButton(
                      onPressed: () {
                        for (int i = 0; i < _quantity; i++) {
                          widget.onAddToCart();
                        }

                        // Afficher modal de confirmation stylé
                        ConfirmationModalHelper.showAddedToCart(
                          context,
                          productName: widget.product.name,
                          quantity: _quantity,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        minimumSize: const Size(90, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x14EC7813),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
