import 'package:flutter/material.dart';

class CommandBar extends StatefulWidget {
  final void Function(String)? onSubmitted;
  const CommandBar({super.key, this.onSubmitted});

  @override
  State<CommandBar> createState() => _CommandBarState();
}

class _CommandBarState extends State<CommandBar> {
  /// Holds the typed text so both the keyboard submit action and the Ask
  /// button can read and submit the same value.
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Reads the current text, trims it, and — when non-empty — forwards it to
  /// [CommandBar.onSubmitted]. The field is cleared after a successful submit.
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmitted?.call(text);
    _controller.clear();
  }

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
                    controller: _controller,
                    onSubmitted: (_) => _submit(),
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
                  onPressed: _submit,
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
