import 'package:flutter/foundation.dart';

/// Who authored a chat message in the AI conversation.
enum AiChatRole { user, assistant }

/// A single immutable message in the AI chat conversation.
@immutable
class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.text,
    this.fromCache = false,
  });

  const AiChatMessage.user(String text)
      : this(role: AiChatRole.user, text: text);

  const AiChatMessage.assistant(String text, {bool fromCache = false})
      : this(role: AiChatRole.assistant, text: text, fromCache: fromCache);

  final AiChatRole role;
  final String text;

  /// Whether an assistant reply was served from the offline cache.
  final bool fromCache;

  bool get isUser => role == AiChatRole.user;

  AiChatMessage copyWith({String? text, bool? fromCache}) => AiChatMessage(
        role: role,
        text: text ?? this.text,
        fromCache: fromCache ?? this.fromCache,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatMessage &&
          other.role == role &&
          other.text == text &&
          other.fromCache == fromCache;

  @override
  int get hashCode => Object.hash(role, text, fromCache);

  @override
  String toString() => 'AiChatMessage(${role.name}, $text)';
}
