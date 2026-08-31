/// Configuration for price display
class PriceDisplayConfig {
  final double currentPrice;
  final String currency;
  final double? originalPrice;
  final double? savingsAmount;
  final double? savingsPercentage;
  final String? unit;
  final double? perNight;
  final double? perDay;
  final double? perTraveler;
  final double? total;
  final bool? taxesIncluded;
  final bool? taxesExcluded;
  final String? fromPrice;

  const PriceDisplayConfig({
    required this.currentPrice,
    required this.currency,
    this.originalPrice,
    this.savingsAmount,
    this.savingsPercentage,
    this.unit,
    this.perNight,
    this.perDay,
    this.perTraveler,
    this.total,
    this.taxesIncluded,
    this.taxesExcluded,
    this.fromPrice,
  });

  bool get hasOriginalPrice => originalPrice != null && originalPrice! > currentPrice;
  bool get hasSavingsAmount => savingsAmount != null && savingsAmount! > 0;
  bool get hasSavingsPercentage => savingsPercentage != null && savingsPercentage! > 0;
  bool get hasUnit => unit != null && unit!.isNotEmpty;
  bool get hasPerNight => perNight != null && perNight! > 0;
  bool get hasPerDay => perDay != null && perDay! > 0;
  bool get hasPerTraveler => perTraveler != null && perTraveler! > 0;
  bool get hasTotal => total != null && total! > 0 && total != currentPrice;
  bool get hasFromPrice => fromPrice != null && fromPrice!.isNotEmpty;

  /// Get all price lines to display
  List<PriceLine> getLines() {
    final lines = <PriceLine>[];
    
    // Primary price with unit
    if (hasUnit) {
      lines.add(PriceLine(
        label: unit!,
        value: currentPrice,
        currency: currency,
        isPrimary: true,
      ));
    } else {
      lines.add(PriceLine(
        label: '',
        value: currentPrice,
        currency: currency,
        isPrimary: true,
      ));
    }
    
    // Per night / day / traveler
    if (hasPerNight) {
      lines.add(PriceLine(
        label: '/night',
        value: perNight!,
        currency: currency,
        isPrimary: false,
      ));
    }
    if (hasPerDay) {
      lines.add(PriceLine(
        label: '/day',
        value: perDay!,
        currency: currency,
        isPrimary: false,
      ));
    }
    if (hasPerTraveler) {
      lines.add(PriceLine(
        label: '/person',
        value: perTraveler!,
        currency: currency,
        isPrimary: false,
      ));
    }
    
    // Total
    if (hasTotal) {
      lines.add(PriceLine(
        label: 'total',
        value: total!,
        currency: currency,
        isPrimary: false,
        isTotal: true,
      ));
    }
    
    // From price
    if (hasFromPrice) {
      lines.add(PriceLine(
        label: 'from',
        value: double.parse(fromPrice!),
        currency: currency,
        isPrimary: false,
        isFrom: true,
      ));
    }
    
    return lines;
  }
}

/// Individual price line
class PriceLine {
  final String label;
  final double value;
  final String currency;
  final bool isPrimary;
  final bool isTotal;
  final bool isFrom;

  const PriceLine({
    required this.label,
    required this.value,
    required this.currency,
    this.isPrimary = false,
    this.isTotal = false,
    this.isFrom = false,
  });
}

/// Analyzes price data and creates display config
class PriceDisplayStrategy {
  static PriceDisplayConfig analyze({
    required double currentPrice,
    required String currency,
    double? originalPrice,
    double? savingsAmount,
    double? savingsPercentage,
    String? unit,
    double? perNight,
    double? perDay,
    double? perTraveler,
    double? total,
    bool? taxesIncluded,
    bool? taxesExcluded,
    String? fromPrice,
  }) {
    return PriceDisplayConfig(
      currentPrice: currentPrice,
      currency: currency,
      originalPrice: originalPrice,
      savingsAmount: savingsAmount,
      savingsPercentage: savingsPercentage,
      unit: unit,
      perNight: perNight,
      perDay: perDay,
      perTraveler: perTraveler,
      total: total,
      taxesIncluded: taxesIncluded,
      taxesExcluded: taxesExcluded,
      fromPrice: fromPrice,
    );
  }
}