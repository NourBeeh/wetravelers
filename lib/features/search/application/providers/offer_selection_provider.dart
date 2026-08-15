import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedOffer {
  final String offerId;
  final String providerId;
  final String providerName;
  final double price;
  final String currency;
  final String searchId;
  final String offerType;
  final Map<String, dynamic> metadata;

  const SelectedOffer({
    required this.offerId,
    required this.providerId,
    required this.providerName,
    required this.price,
    required this.currency,
    required this.searchId,
    required this.offerType,
    this.metadata = const {},
  });
}

final selectedOfferProvider = StateProvider<SelectedOffer?>((ref) => null);
