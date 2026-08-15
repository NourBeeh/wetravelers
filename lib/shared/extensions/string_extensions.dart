/// String helpers for display formatting.
extension StringFormattingExtension on String {
  /// "hello_world" -> "Hello World".
  String toTitleCase() {
    if (isEmpty) return this;
    final words = split(RegExp(r'[_\-\s]+'));
    final titled = words
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
    return titled;
  }

  /// Truncates to [maxLength] characters, appending [ellipsis].
  String ellipsize(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength).trimRight()}$ellipsis';
  }
}