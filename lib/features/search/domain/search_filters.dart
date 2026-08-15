class SearchFilters {
  final double? priceMin;
  final double? priceMax;
  final int? maxStops;
  final double? minRating;
  final int? minSeats;
  final List<String>? airlines;
  final List<String>? amenities;

  const SearchFilters({
    this.priceMin,
    this.priceMax,
    this.maxStops,
    this.minRating,
    this.minSeats,
    this.airlines,
    this.amenities,
  });

  SearchFilters copyWith({
    double? priceMin,
    double? priceMax,
    int? maxStops,
    double? minRating,
    int? minSeats,
    List<String>? airlines,
    List<String>? amenities,
  }) {
    return SearchFilters(
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      maxStops: maxStops ?? this.maxStops,
      minRating: minRating ?? this.minRating,
      minSeats: minSeats ?? this.minSeats,
      airlines: airlines ?? this.airlines,
      amenities: amenities ?? this.amenities,
    );
  }

  bool get isEmpty => priceMin == null && priceMax == null && maxStops == null && minRating == null && minSeats == null && (airlines?.isEmpty ?? true) && (amenities?.isEmpty ?? true);
}
