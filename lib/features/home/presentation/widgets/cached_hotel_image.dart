import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/widgets/shimmer.dart';
import 'package:wetravellers/features/home/application/hotel_image_cache.dart';

/// H3 — Hive-backed hotel card image.
///
/// Render pipeline per URL:
/// 1. **Hive cache hit** → decode the stored bytes with a hard [cacheWidth]
///    (P2, official Flutter guidance: `Image.memory(cacheWidth:)` → the
///    engine decodes at display resolution, so a 2000px hotel photo never
///    enters `ImageCache` as a full-size bitmap).
/// 2. **Miss** → shimmer placeholder (same look as the H1 skeleton rail),
///    fetch over the network, store the raw bytes into the cache for next
///    time, then decode as above.
/// 3. **Failure** → the same neutral fallback icon the old
///    `Image.network(errorBuilder:)` used.
///
/// The widget NEVER throws: every failure degrades to placeholder/fallback.
/// Concurrency-safe: per-URL in-flight loads are shared, so a rail with the
/// same image twice loads it once.
class CachedHotelImage extends StatefulWidget {
  const CachedHotelImage({
    super.key,
    required this.url,
    this.height = 120,
    this.width,
    this.cache,
    this.httpClient,
  });

  final String url;

  /// Display height — also drives decode sizing together with [width].
  final double height;

  /// Optional tight width (defaults to the parent's constraints).
  final double? width;

  /// Optional injected cache (defaults to a no-op cache so the widget also
  /// works in tests without Hive).
  final HotelImageCache? cache;

  /// Optional injected byte fetcher (defaults to `http.get` style function;
  /// tests inject deterministic bytes).
  final Future<Uint8List?> Function(Uri uri)? httpClient;

  @override
  State<CachedHotelImage> createState() => _CachedHotelImageState();

  /// Shared in-flight loads keyed by URL — never fetch the same URL twice.
  @visibleForTesting
  static final Map<String, Future<Uint8List?>> _inFlight =
      <String, Future<Uint8List?>>{};
}

class _CachedHotelImageState extends State<CachedHotelImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CachedHotelImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final url = widget.url;
    final cache = widget.cache;

    // 1) Cache read (best-effort).
    if (cache != null) {
      final cached = await cache.read(url);
      if (cached != null && mounted && widget.url == url) {
        setState(() => _bytes = cached);
        return;
      }
    }

    // 2) Network fetch — shared per URL so a rail never double-loads.
    final fetched = await _sharedFetch(url);
    if (fetched != null) {
      await cache?.write(url, fetched); // Best-effort store.
    }
    if (!mounted || widget.url != url) return;
    setState(() => _bytes = fetched);
  }

  Future<Uint8List?> _sharedFetch(String url) {
    return CachedHotelImage._inFlight.putIfAbsent(url, () async {
      try {
        final fetcher = widget.httpClient ?? _defaultFetch;
        return await fetcher(Uri.parse(url));
      } finally {
        // The load completed — drop the shared entry so a LATER reload
        // (after TTL eviction) can fetch again.
        CachedHotelImage._inFlight.remove(url);
      }
    });
  }

  static Future<Uint8List?> _defaultFetch(Uri uri) async {
    try {
      final client = HttpClient();
      try {
        final request = await client
            .getUrl(uri)
            .timeout(const Duration(seconds: 10));
        final response = await request.close().timeout(
              const Duration(seconds: 10),
            );
        if (response.statusCode != 200) return null;
        final builder = await response.fold<BytesBuilder>(
          BytesBuilder(),
          (buffer, chunk) => buffer..add(chunk),
        ).timeout(const Duration(seconds: 15));
        return builder.takeBytes();
      } finally {
        client.close();
      }
    } catch (_) {
      return null; // Never throw — degrade to the fallback icon.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;

    // Loading / miss → shimmer (same primitive as the H1 skeleton rail).
    if (bytes == null) {
      return ShimmerBox(
        height: widget.height,
        width: widget.width ?? double.infinity,
      );
    }

    // P2: decode at display resolution — the engine downsamples on decode,
    // so ImageCache holds ~260×120@dpi bitmaps, never multi-megapixel ones.
    final devicePixelRatio =
        MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final decodeWidth = ((widget.width ?? 260) * devicePixelRatio).round();

    return Image.memory(
      bytes,
      height: widget.height,
      width: widget.width,
      fit: BoxFit.cover,
      cacheWidth: decodeWidth,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        height: widget.height,
        width: widget.width,
        color: AppColors.surfaceTertiary,
        child: const Icon(Icons.image_not_supported_outlined, size: 32),
      );
}

/// Exposed for tests: drains the shared in-flight table between suites.
@visibleForTesting
Future<void> debugDrainInFlight() async {
  CachedHotelImage._inFlight.clear();
}
