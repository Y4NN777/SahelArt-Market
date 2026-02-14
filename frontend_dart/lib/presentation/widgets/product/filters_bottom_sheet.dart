import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/theme/colors.dart';
import '../../../features/products/domain/product_filters.dart';

Future<ProductFilters?> showFiltersBottomSheet(
  BuildContext context, {
  required ProductFilters currentFilters,
  required List<String> availableRegions,
  required double minPrice,
  required double maxPrice,
}) {
  return showModalBottomSheet<ProductFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FiltersBottomSheet(
      currentFilters: currentFilters,
      availableRegions: availableRegions,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ),
  );
}

class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({
    super.key,
    required this.currentFilters,
    required this.availableRegions,
    required this.minPrice,
    required this.maxPrice,
  });

  final ProductFilters currentFilters;
  final List<String> availableRegions;
  final double minPrice;
  final double maxPrice;

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late RangeValues _priceRange;
  late List<String> _selectedRegions;
  late double? _selectedMinRating;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.currentFilters.minPrice ?? widget.minPrice,
      widget.currentFilters.maxPrice ?? widget.maxPrice,
    );
    _selectedRegions = List.from(widget.currentFilters.regions);
    _selectedMinRating = widget.currentFilters.minRating;
  }

  void _reset() {
    setState(() {
      _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
      _selectedRegions.clear();
      _selectedMinRating = null;
    });
  }

  void _apply() {
    final filters = ProductFilters(
      minPrice: _priceRange.start == widget.minPrice ? null : _priceRange.start,
      maxPrice: _priceRange.end == widget.maxPrice ? null : _priceRange.end,
      regions: _selectedRegions,
      minRating: _selectedMinRating,
    );
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1ECE7))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildPriceSection(),
                    const SizedBox(height: 24),
                    _buildRegionsSection(),
                    const SizedBox(height: 24),
                    _buildRatingSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF1ECE7))),
                ),
                child: SafeArea(
                  top: false,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Appliquer les filtres',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prix',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_priceRange.start.toStringAsFixed(0)} - ${_priceRange.end.toStringAsFixed(0)} CFA',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _priceRange,
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: math.max(1, ((widget.maxPrice - widget.minPrice) / 1000).round()),
          activeColor: AppColors.primary,
          inactiveColor: const Color(0x33EC7813),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRegionsSection() {
    if (widget.availableRegions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Région',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableRegions.map((region) {
            final isSelected = _selectedRegions.contains(region);
            return FilterChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedRegions.add(region);
                  } else {
                    _selectedRegions.remove(region);
                  }
                });
              },
              selectedColor: const Color(0x33EC7813),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final ratingOptions = [
      (4.5, '4.5+'),
      (4.0, '4+'),
      (3.5, '3.5+'),
      (3.0, '3+'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note minimum',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ratingOptions.map((option) {
            final rating = option.$1;
            final label = option.$2;
            final isSelected = _selectedMinRating == rating;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMinRating = selected ? rating : null;
                });
              },
              selectedColor: const Color(0x33EC7813),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
