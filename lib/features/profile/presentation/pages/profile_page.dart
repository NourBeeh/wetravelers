import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/user_model.dart';
import '../../../../core/network/user_facing_message.dart';
import '../../../../core/theme/app_spacing.dart';

/// Profile entry (Phase 17).
///
/// Guest → sign-in CTA. Authenticated → basic user info, logout and a link
/// into Settings. No settings redesign in this phase.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: switch (authState) {
        AuthLoading() => const Center(child: CircularProgressIndicator()),
        AuthAuthenticated(:final user) => _ProfileContent(user: user!),
        AuthError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userFacingMessage(error, subject: 'profile'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        AuthUnauthenticated() => _GuestContent(theme: theme),
      },
    );
  }
}

class _GuestContent extends StatelessWidget {
  const _GuestContent({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 44,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'You are browsing as a guest',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sign in to save your trips, offers and preferences.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => context.go('/auth'),
              icon: const Icon(Icons.login),
              label: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final displayName = user.displayName?.trim() ?? '';
    final email = user.email;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              (displayName.isNotEmpty ? displayName[0] : email.isNotEmpty ? email[0] : '?')
                  .toUpperCase(),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            displayName.isNotEmpty ? displayName : 'Traveller',
            style: theme.textTheme.titleLarge,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Center(child: Text(email, style: theme.textTheme.bodyMedium)),
        ],
        const SizedBox(height: AppSpacing.xl),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).logout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
