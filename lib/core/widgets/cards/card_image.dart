import 'package:flutter/material.dart';

class CardImage extends StatelessWidget {
  final String? url;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final String? semanticLabel;

  /// Shown centered on the placeholder background when the network image fails
  /// or the url is null/empty — a much better degraded experience than a bare
  /// grey rectangle when an external image service glitches.
  final IconData? fallbackIcon;

  const CardImage({
    super.key,
    required this.url,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.semanticLabel,
    this.fallbackIcon,
  });

  /// Unified image-source resolver for the whole card system.
  ///
  /// Mock/offline data points at bundled assets (`assets/images/...`), while
  /// the live API returns absolute http(s) URLs. One check here means every
  /// card renders both modes without per-card special-casing — flipping the
  /// real API on later needs zero widget changes.
  static bool isAssetSource(String url) => url.startsWith('assets/');

  /// Resolves an image source string into the matching [ImageProvider]:
  /// bundled asset (`assets/...`) → [AssetImage], http(s) → [NetworkImage].
  /// Returns null for null/empty input so callers can keep their
  /// "no image → no provider" branching.
  static ImageProvider? providerFor(String? url) {
    if (url == null || url.isEmpty) return null;
    return isAssetSource(url) ? AssetImage(url) : NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Brightness-aware placeholder so degradation also looks right in dark mode.
    Widget buildFallback() {
      if (placeholder != null) return placeholder!;
      final fallbackColor = scheme.surfaceContainerHighest;
      if (fallbackIcon == null) {
        return ColoredBox(color: fallbackColor);
      }
      return ColoredBox(
        color: fallbackColor,
        child: Center(
          child: Icon(
            fallbackIcon,
            size: 40,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final Widget image;
    if (url == null || url!.isEmpty) {
      image = _SkeletonImage();
    } else if (isAssetSource(url!)) {
      image = Image.asset(
        url!,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) => buildFallback(),
      );
    } else {
      image = Image.network(
        url!,
        fit: fit,
        semanticLabel: semanticLabel,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _SkeletonImage();
        },
        errorBuilder: (context, error, stackTrace) => buildFallback(),
      );
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: image,
        ),
      ),
    );
  }
}

class _SkeletonImage extends StatefulWidget {
  const _SkeletonImage();

  @override
  State<_SkeletonImage> createState() => _SkeletonImageState();
}

class _SkeletonImageState extends State<_SkeletonImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          color: scheme.surfaceContainerHighest.withValues(alpha: _animation.value),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        );
      },
    );
  }
}
