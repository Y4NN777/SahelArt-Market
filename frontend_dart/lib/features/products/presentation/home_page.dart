import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../presentation/widgets/common/error_widget.dart';
import '../../../presentation/widgets/common/loading_indicator.dart';
import '../../../presentation/widgets/product/product_card.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/product.dart';
import '../../../core/network/api_client.dart';
import 'product_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.apiClient,
    required this.cart,
    required this.onLogout,
    required this.onAddToCart,
    required this.onUpdateQuantity,
    required this.onCheckout,
  });

  final ApiClient apiClient;
  final List<CartItem> cart;
  final Future<void> Function() onLogout;
  final void Function(Product product) onAddToCart;
  final void Function(Product product, int quantity) onUpdateQuantity;
  final Future<String> Function() onCheckout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  String? _error;
  List<Product> _products = [];

  static const _categories = ['All', 'Pottery', 'Textiles', 'Jewelry', 'Woodwork'];
  int _activeCategory = 0;

  /// Get filtered products based on active category
  List<Product> get _filteredProducts {
    if (_activeCategory == 0) {
      return _products; // "All" category
    }
    final categoryName = _categories[_activeCategory];
    return _products.where((p) => p.category == categoryName).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await widget.apiClient.fetchProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildCategories(),
                    _buildArtisans(),
                    const SizedBox(height: 12),
                    _buildProductsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: Color(0x1AEC7813))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              const Text(
                'SahelArt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications - Coming soon!')),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search pottery, masks, textiles...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final active = index == _activeCategory;
          return ChoiceChip(
            selected: active,
            label: Text(_categories[index]),
            onSelected: (_) => setState(() => _activeCategory = index),
            selectedColor: AppColors.primary,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: active ? Colors.white : const Color(0xFF4B5563),
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: active ? AppColors.primary : const Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          );
        },
        separatorBuilder: (_, separatorIndex) => const SizedBox(width: 8),
        itemCount: _categories.length,
      ),
    );
  }

  Widget _buildArtisans() {
    final artisans = [
      ('Amadou K.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuC9rRbI1EVmhh-eeYiKKQKNGVbxNIdjfDRKC0ye6Kvnu0YnMyDOWFWMjByy5sI-eP7NeDzvtZRe6m_4QCXpzLUvByUXmax4GGZL81CT5IAXah9m9beSQu2DiGjQf4wcYR7uIal4AIADxWfhiQ5100HDXdsfXoAQZydEMIX_4v5dS32R07RuKzEM2BoZPIuyEzhU8xPqcWJzSFwP0AFi60-d2gzdyx8xBGT4Pss700UWQSs5fHbeiFImPAhdlATchQAgrjJtvBcJWC_2'),
      ('Fatou D.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCsocr7zlwnoNh7A08sl7OhZ5ZcFf1fUzfJC6NwMzEcwQSIX-cq8DEQop0BOCS6zo8haWtDN2F7V4F0b12OmkFbKevvABNqpUd2tNXPigwjsQVDMw-h5gEm6WJpUuxO2SXwb_Om9khBoTovlpb2a6qF_u_Pi4a7C8WBdaA-pj1SjW0edAkmXVzd5GIwxfgDFOBDX5lWdRQUDtZ6tocj-p0n7J_SgRRiRarRpZs15_NvlIB3ulWMm3H-NRLWfGFJxDcYCHS2ZNqWTzJq'),
      ('Kofi M.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuA4pHyxA90tKlnNKN_XgEJKFq1GZyeitdBl1TBRmI7dkr77JkCSUEZ9hZCP-2suwjByVf-FEWm_-g8P__kWsPNeNA68nNDuxgcp6T1PMS16CUFhJTb7Gn-Ph_bmRxXz0Bh0AN2E-FzuX0kj9yG3r7PONl6-Vw7mlHcEPQFj2r2GNDZqedaZV3Yu1BmNTHODdLg9AMalZIzO7v7R89idO4c1iab3l_oP1bwCdfbq44v4CjoEoF2XVGUEjGs9L1ultWuyMgC-By7Kf4lf'),
      ('Amina S.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDIySzn2Q_kHHImajEOhqCI-LuXkYhXi6-v0Ft7NbETEv5kOX58tGgSMWXV02Wv7H_CBDlt8PKxRjVfVPLnRp_7ua6kp_mfHxtoXXGAfRT0F77WUnHO9hWty7sFBLSRwv_O92zhLcSCJfWbJyHYrQFQ8xPU4elr2Cx44WBHJXsEmPnCYeK5zpd3svhM_QHd8pbjWcEWimCmTmkeqbxSeVfgD7yXXQyolNGhsF9hO2hCHW44S1JwD4He4xRHQt4q-5dmZnmK8CEDNkSw'),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Featured Artisans',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final artisan = artisans[index];
                return SizedBox(
                  width: 74,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.primary, Color(0xFFF9B278)]),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(artisan.$2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        artisan.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, separatorIndex) => const SizedBox(width: 8),
              itemCount: artisans.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    if (_loading) {
      return const SizedBox(height: 320, child: LoadingIndicator());
    }
    if (_error != null) {
      return SizedBox(height: 320, child: AppErrorWidget(message: _error!));
    }
    if (_products.isEmpty) {
      return const SizedBox(height: 260, child: Center(child: Text('Aucun produit disponible.')));
    }

    final filteredProducts = _filteredProducts;

    if (filteredProducts.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Aucun produit dans cette catégorie',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Trending Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Icon(Icons.tune_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            itemBuilder: (_, index) {
              final product = filteredProducts[index];
              return ProductCard(
                product: product,
                onAdd: () => widget.onAddToCart(product),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(
                        product: product,
                        onAddToCart: () => widget.onAddToCart(product),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

}
