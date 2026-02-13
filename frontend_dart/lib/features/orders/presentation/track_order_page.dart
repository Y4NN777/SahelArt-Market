import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

class TrackOrderPage extends StatelessWidget {
  const TrackOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Track Your Order', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEADFD4)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCa9Xc2NzCv0y5BXzaqAz2WeVSw8yg7ZSQ4N0fZs0cWa9A--LGWIc1PNk1VTCSddgJIhSDkv5j2vIyJBEcH_2-mGM6JfIC7bmvDrgRmWEs2Jktzlc86_XirIsl_gV2RT6tzLQaioa8qzEEr3Hs7QmabIvr3DtzoDfyS_x3vgGegsa1yPcbF74fbLtE3kBz6FrasKctA70a-QByZquRRMgMt5J8sMaJJiKDrpgVkrdAFZQZCYHUtTUOzImoZqRAEYcg5HsJ5uHO9-mTq',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #SA-4920', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      SizedBox(height: 2),
                      Text('Hand-woven Tuareg Basket', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Est. Delivery: Oct 24 - Oct 26', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBpYPLa-PA39d-ftOmBcJ-6cCskRdKXSvstzO7222ChqB6VJ7xxrprFsl0qjbS9yRF6VX03SMP2UIPyjs8ei65HcJQCb2Jq_sngZe4gNmlZLP9xnj2TOOUWGre_m1B6d0G_hOAD_drW4CtrX6zR6N6HkJkAZBmLMVoLAc4iEb4sW7MxcBDuoJfFDptrirdrqfT6rSM25kN_CKvIHdRQC54KkqY06ZqS5-HmTZMy6J1uuwzLzR6SG6q8UaJlwCWRAsjTYLqqQGpeYzc1',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('Live', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEADFD4)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shipment Status', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 14),
                _Step(title: 'Order Placed', desc: 'We have received your order.', done: true),
                _Step(title: 'Artisan Preparing', desc: 'Your basket is being finalized in Niamey.', current: true),
                _Step(title: 'In Transit', desc: 'On the way to logistics center.'),
                _Step(title: 'Delivered', desc: 'Package arrived at your door.', isLast: true),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Contact Support'),
              ),
              const SizedBox(height: 4),
              TextButton(onPressed: () {}, child: const Text('Problem with order?')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.desc,
    this.done = false,
    this.current = false,
    this.isLast = false,
  });

  final String title;
  final String desc;
  final bool done;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = done || current ? AppColors.primary : const Color(0xFFD1D5DB);
    final lineColor = done ? AppColors.primary : const Color(0xFFD1D5DB);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              child: done ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: lineColor.withValues(alpha: 0.4),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                    color: current ? AppColors.primary : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
