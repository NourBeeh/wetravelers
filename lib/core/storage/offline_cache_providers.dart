import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_cache.dart';

/// Opens the on-disk Hive-backed offline cache once and shares it app-wide.
///
/// The box is a singleton keyed by its name, so repeated provider restarts
/// reuse the same open box rather than re-opening the file.
final offlineCacheProvider = Provider<OfflineCache>((ref) {
  throw UnimplementedError(
    'offlineCacheProvider must be overridden with HiveOfflineCache.open() in main() before use.',
  );
});

/// Convenience override used by tests to inject a lightweight in-memory store.
final memoryOfflineCacheProvider = Provider<OfflineCache>((ref) {
  return MemoryOfflineCache();
});