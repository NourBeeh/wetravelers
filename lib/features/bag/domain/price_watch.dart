import 'package:flutter/foundation.dart';

enum PriceWatchStatus { active, triggered, paused, removed }

@immutable
class WatchItem {
  final String id;
  final String offerId;
  final String providerId;
  final String type;
  final double? targetPrice;
  final double currentPrice;
  final String currency;
  final DateTime lastCheckedAt;
  final bool enabled;
  final PriceWatchStatus status;

  const WatchItem({
    required this.id,
    required this.offerId,
    required this.providerId,
    required this.type,
    this.targetPrice,
    required this.currentPrice,
    required this.currency,
    required this.lastCheckedAt,
    required this.enabled,
    required this.status,
  });
}
