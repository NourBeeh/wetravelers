import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  const AccessibleButton({super.key, required this.onPressed, required this.child, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: SizedBox(
          height: 48,
          child: Focus(
            child: Builder(
              builder: (context) {
                final focused = Focus.of(context).hasFocus;
                return ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: focused
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                        : null,
                  ),
                  child: child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}