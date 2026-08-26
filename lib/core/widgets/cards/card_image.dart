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

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: url == null || url!.isEmpty
              ? buildFallback()
              : Image.network(
                  url!,
                  fit: fit,
                  semanticLabel: semanticLabel,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: scheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => buildFallback(),
                ),
        ),
      ),
    );
  }
}
