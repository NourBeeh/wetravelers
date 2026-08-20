import 'dart:async';

import 'package:hive/hive.dart';

import 'offline_cache.dart';

/// Hive-backed [OfflineCache] for the Phase 16 offline support foundation.
///
/// Hive is a pure-Dart key-value store with AES-256 encryption and no native
/// dependencies, so it works identically on mobile, desktop and web. Values
/// are stored as immutable `Map<String, dynamic>` entries (boxes are
/// `Box<Map>`), which keeps the domain serializers in
/// `offline_cache_serializers.dart` the single source of shape knowledge.
class HiveOfflineCache implements OfflineCache {
  HiveOfflineCache(this._box);

  final Box<Map<String, dynamic>> _box;

  static const String defaultBoxName = 'wetravellers_offline';

  /// Initializes Hive (assigns its on-disk home) and opens the box used by the
  /// offline cache. [homeDir] defaults to a per-app folder in the process
  /// working directory, which the platform layer can override later.
  ///
  /// Safe to call repeatedly: `openBox` returns the already-open box instance.
  static Future<HiveOfflineCache> open({
    String? homeDir,
    required String boxName,
  }) async {
    Hive.init(homeDir ?? _defaultHomeDir);
    final box = await Hive.openBox<Map<String, dynamic>>(boxName);
    return HiveOfflineCache(box);
  }

  static const String _defaultHomeDir = 'wetravellers_offline_data';

  @override
  Future<void> clear() async {
    for (final key in _box.toMap().keys.toList()) {
      _box.delete(key);
    }
  }

  @override
  Future<bool> contains(String key) async => _box.get(key) != null;

  @override
  Future<void> delete(String key) async {
    _box.delete(key);
  }

  @override
  Future<Map<String, dynamic>?> read(String key) async => _box.get(key);

  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    _box.put(key, value);
  }
}