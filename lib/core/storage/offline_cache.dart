/// Persistence contract for the Phase 16 offline support foundation.
///
/// Stores immutable JSON-safe maps under string keys so any domain object can
/// be cached by serializing it to a plain map at the repository boundary. A
/// real on-disk implementation (Hive) lives in `hive_offline_cache.dart`; the
/// in-memory implementation below is used by tests and as a no-op fallback.
abstract interface class OfflineCache {
  /// Persists [value] under [key], replacing any previous entry.
  Future<void> write(String key, Map<String, dynamic> value);

  /// Reads [key] or returns `null` when absent.
  Future<Map<String, dynamic>?> read(String key);

  /// Removes [key]. Missing keys are a no-op.
  Future<void> delete(String key);

  /// Whether [key] currently has a value.
  Future<bool> contains(String key);

  /// Removes every stored value for this cache.
  Future<void> clear();
}

/// Non-persisting in-memory store used by tests before a real store lands.
class MemoryOfflineCache implements OfflineCache {
  final Map<String, Map<String, dynamic>> _store = <String, Map<String, dynamic>>{};

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<bool> contains(String key) async => _store.containsKey(key);

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<Map<String, dynamic>?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    _store[key] = value;
  }
}