import 'package:flutter/material.dart';

class CommandBar extends StatelessWidget {
  final void Function(String)? onSubmitted;
  const CommandBar({super.key, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: true,
      right: true,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onSubmitted: onSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Search flights, hotels, cars or ask the assistant',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.mic_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Ask'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
