import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../products/domain/product.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onAddToCart;

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
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      backgroundColor: Color(0x55FFFFFF),
                      child: Icon(Icons.favorite_border, color: Colors.white),
                    ),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuD5i93IoC_AqPFK--DoBWLHox9f5Mz85EIe-KY4QAiIHjpxqKsVjlZJuaFi8ecXLpYWFr8ULEDnt8GHbjBATTuA6aeoO17eLL-6CFlkc-hhZkifLuZQdJBlM7N3CKkxmLV2aCWIdWSpNTJmM-qim8T9Nkm25sjbsQ3U0Po1792RjUTcUsApeJmmatWELOUgsOBa0NV1JQOhEpEqIZYLICS0LurIKO-U5rvf3-1LHK5RVcp1PeShDmi0L9DTxwl9KqG5K2iEUWhtE8rK',
                    fit: BoxFit.cover,
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
                        children: const [
                          _Badge(text: 'Only 2 left'),
                          Row(
                            children: [
                              Icon(Icons.star, size: 18, color: Color(0xFFF59E0B)),
                              SizedBox(width: 4),
                              Text('4.9 (128)', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CFA ${product.price.toStringAsFixed(0)}',
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
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Crafted by', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                                  Text('Fatoumata Diallo', style: TextStyle(fontWeight: FontWeight.w800)),
                                  Text('Segou, Mali', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('The Story', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text(
                        'This authentic Bogolanfini is hand-dyed using fermented mud and plant leaves, a tradition passed down through generations.',
                        style: TextStyle(color: Color(0xFF4B5563), height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      const Text('Specifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total Price', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text('CFA 45k', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w700)),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
