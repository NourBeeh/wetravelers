import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/theme/app_typography.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

/// NAV — Home-centric vertical navigation strip (replaces the bottom bar).
///
/// The four product verticals live as a horizontal row of premium buttons
/// directly under the AI search pill on the Home surface:
///
///   ✈ طيران   🏨 إقامات   🚗 سيارات   🧭 برامج سياحية
///
/// Each button routes to its EXISTING search page ('/flights', '/hotels',
/// '/cars', '/packages') — no new pages, no new controllers, no route
/// changes. Groups + Explore dissolve into Home discovery later (7B);
/// their entry points live here as a compact secondary row so nothing is
/// lost (rules: no page deletion).
///
/// Light-only premium language: soft-filled pills with the vertical's hue,
/// 48px touch targets, RTL/LTR mirrored automatically by the Row.
class HomeNavButtons extends StatelessWidget {
  const HomeNavButtons({super.key, this.showSecondary = true});

  /// Whether the compact Groups/Explore row renders under the verticals.
  final bool showSecondary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = AppTypography.forLight();

    final verticals = <_NavItemData>[
      _NavItemData(
        label: l10n.searchFlights,
        icon: Icons.flight_takeoff_rounded,
        hue: AppColors.flightHue,
        path: '/flights',
      ),
      _NavItemData(
        label: l10n.searchHotels,
        icon: Icons.hotel_rounded,
        hue: AppColors.hotelHue,
        path: '/hotels',
      ),
      _NavItemData(
        label: l10n.searchCars,
        icon: Icons.directions_car_rounded,
        hue: AppColors.carHue,
        path: '/cars',
      ),
      _NavItemData(
        label: l10n.searchPackages,
        icon: Icons.map_rounded,
        hue: AppColors.packageHue,
        path: '/packages',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Primary verticals — the Home navigation row.
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: verticals.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) =>
                _NavButton(item: verticals[index], typography: typography),
          ),
        ),
        if (showSecondary) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: _SecondaryButton(
                  label: l10n.exploreTitle,
                  icon: Icons.explore_rounded,
                  path: '/explore',
                  typography: typography,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SecondaryButton(
                  label: l10n.groupsTitle,
                  icon: Icons.groups_rounded,
                  path: '/groups',
                  typography: typography,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.hue,
    required this.path,
  });

  final String label;
  final IconData icon;
  final Color hue;
  final String path;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.typography});

  static const double _iconSize = 26;

  final _NavItemData item;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      // 48px minimum accessible target height (the pill is taller).
      child: Material(
        color: item.hue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(item.path),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.icon, size: _iconSize, color: item.hue),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: typography.captionSemibold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.path,
    required this.typography,
  });

  final String label;
  final IconData icon;
  final String path;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: AppColors.surfaceTertiary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
