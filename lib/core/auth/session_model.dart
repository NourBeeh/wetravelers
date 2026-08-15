import 'package:flutter/foundation.dart';
import 'user_model.dart';
import 'token_model.dart';

@immutable
class Session {
  const Session({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final AuthUser user;
  final Token accessToken;
  final Token refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
