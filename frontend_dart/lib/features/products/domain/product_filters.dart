class ProductFilters {
  ProductFilters({
    this.minPrice,
    this.maxPrice,
    this.regions = const [],
    this.minRating,
  });

  final double? minPrice;
  final double? maxPrice;
  final List<String> regions;
  final double? minRating;

  ProductFilters copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? regions,
    double? minRating,
  }) {
    return ProductFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      regions: regions ?? this.regions,
      minRating: minRating ?? this.minRating,
    );
  }

  bool get hasActiveFilters =>
      minPrice != null || maxPrice != null || regions.isNotEmpty || minRating != null;

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (regions.isNotEmpty) count++;
    if (minRating != null) count++;
    return count;
  }

  ProductFilters clear() => ProductFilters();
}
