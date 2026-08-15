import 'package:flutter/foundation.dart';

@immutable
class ProviderErrorInfo {
  final String providerId;
  final String providerName;
  final String errorMessage;

  const ProviderErrorInfo({
    required this.providerId,
    required this.providerName,
    required this.errorMessage,
  });
}

@immutable
class SearchResultMeta {
  final String searchId;
  final DateTime timestamp;
  final List<ProviderErrorInfo> providerErrors;

  const SearchResultMeta({
    required this.searchId,
    required this.timestamp,
    this.providerErrors = const [],
  });
}

@immutable
class NormalizedSearchResult<T> {
  final List<T> results;
  final SearchResultMeta meta;

  const NormalizedSearchResult({
    required this.results,
    required this.meta,
  });
}
