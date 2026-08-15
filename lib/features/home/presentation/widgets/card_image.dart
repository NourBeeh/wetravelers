import 'package:flutter/material.dart';

class CardImage extends StatelessWidget {
  final String? url;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final String? semanticLabel;

  const CardImage({
    super.key,
    required this.url,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: url == null || url!.isEmpty
              ? placeholder ?? const ColoredBox(color: Color(0xFFEEEEEE))
              : Image.network(
                  url!,
                  fit: fit,
                  semanticLabel: semanticLabel,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return placeholder ?? const ColoredBox(color: Color(0xFFEEEEEE));
                  },
                ),
        ),
      ),
    );
  }
}
