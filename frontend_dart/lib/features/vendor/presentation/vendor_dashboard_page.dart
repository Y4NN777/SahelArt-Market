import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAr1ykeR5xUu-KEV9N4hsaLLaZZv29vaFlKfavWlSBKwkrcJeKRyfQvZjV0hxU1u7XivWX0NOI3n9Yh3aDu9VLNNx90uXvXQhV1eZeCKmhTF7sOB21bWtYCXeZzP7pBu6LCusvM7bLfMid989Dw1E8y3E9b_-oyvX3YDG_GKZuoJwAii6uYSaD_y15dxVjfor7Ch7a36g9t1A-w_YzPluGRHWxzHb6eaAtVDCLOV4aJ9W-FrxI5gG8ytfoe9564ttGK0Y--v_LF_mS4',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sannu, Artisan!', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text('Amadou Diallo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _StatPrimaryCard(),
                      SizedBox(width: 10),
                      _StatSmallCard(icon: Icons.inventory_2_outlined, title: 'Active Orders', value: '12'),
                      SizedBox(width: 10),
                      _StatSmallCard(icon: Icons.warning_amber_rounded, title: 'Low Stock', value: '3', warn: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _QuickAction(label: 'Analytics', icon: Icons.bar_chart_rounded)),
                    SizedBox(width: 10),
                    Expanded(child: _QuickAction(label: 'Shipments', icon: Icons.local_shipping_outlined)),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Spacer(),
                    Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                const _OrderItem(
                  title: 'Handwoven Basket',
                  orderId: '#2034',
                  customer: 'Fatoumata B.',
                  price: 'CFA 15K',
                  status: 'Pending',
                ),
                const SizedBox(height: 10),
                const _OrderItem(
                  title: 'Tuareg Silver Ring',
                  orderId: '#2033',
                  customer: 'Jean-Luc M.',
                  price: 'CFA 45K',
                  status: 'Processing',
                ),
                const SizedBox(height: 10),
                const _OrderItem(
                  title: 'Bogolan Fabric',
                  orderId: '#2032',
                  customer: 'Awa S.',
                  price: 'CFA 12K',
                  status: 'Shipped',
                ),
              ],
            ),
            Positioned(
              bottom: 28,
              right: 18,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPrimaryCard extends StatelessWidget {
  const _StatPrimaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              Spacer(),
              Text('+12%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 24),
          Text('Total Revenue', style: TextStyle(color: Colors.white70)),
          Text('CFA 1.25M', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatSmallCard extends StatelessWidget {
  const _StatSmallCard({
    required this.icon,
    required this.title,
    required this.value,
    this.warn = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADFD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: warn ? Colors.red : AppColors.primary),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADFD4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({
    required this.title,
    required this.orderId,
    required this.customer,
    required this.price,
    required this.status,
  });

  final String title;
  final String orderId;
  final String customer;
  final String price;
  final String status;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      'Pending' => const Color(0xFFB45309),
      'Processing' => const Color(0xFF1D4ED8),
      _ => const Color(0xFF047857),
    };
    final bg = switch (status) {
      'Pending' => const Color(0xFFFEF3C7),
      'Processing' => const Color(0xFFDBEAFE),
      _ => const Color(0xFFD1FAE5),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEADFD4)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1),
                    ),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Order $orderId - $customer', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
