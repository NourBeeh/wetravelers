import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'auth_repository.dart';
import 'auth_state.dart';
import 'user_model.dart';

/// Provides the authentication repository to the tree.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Later phases swap in a real repository backed by a concrete ApiClient.
  return const LocalAuthRepository();
});

/// Exposes the reactive [AuthState] produced by [AuthController].
final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

/// Convenience `.user` selector for the currently authenticated user.
final authUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(authControllerProvider);
  return switch (state) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
});