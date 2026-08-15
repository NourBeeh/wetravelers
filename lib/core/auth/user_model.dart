import 'package:flutter/foundation.dart';

/// Authenticated user model used across the whole app.
///
/// Immutable, JSON-serialisable. Extended in later phases (profile, trips,
/// preferences) without breaking the core contract.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.phoneNumber,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? phoneNumber;

  bool get isAnonymous => id.isEmpty;

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    bool clearDisplayName = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? phoneNumber,
    bool clearPhoneNumber = false,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: clearDisplayName ? null : displayName ?? this.displayName,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
      phoneNumber: clearPhoneNumber ? null : phoneNumber ?? this.phoneNumber,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'phoneNumber': phoneNumber,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          other.id == id &&
          other.email == email &&
          other.displayName == displayName &&
          other.avatarUrl == avatarUrl &&
          other.phoneNumber == phoneNumber;

  @override
  int get hashCode => Object.hash(id, email, displayName, avatarUrl, phoneNumber);

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';
}