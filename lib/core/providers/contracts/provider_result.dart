import 'package:flutter/foundation.dart';

@immutable
class ProviderResult<T> {
  const ProviderResult.success(this.data, {this.providerId}) : error = null;
  const ProviderResult.failure(this.error, {this.providerId}) : data = null;

  final T? data;
  final Object? error;
  final String? providerId;

  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}