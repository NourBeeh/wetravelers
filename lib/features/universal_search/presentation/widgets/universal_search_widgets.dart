import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_motion.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/theme/app_typography.dart';
import 'package:wetravellers/features/universal_search/application/universal_search_state.dart';
import 'package:wetravellers/features/universal_search/domain/structured_travel_intent.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_ai_search_field.dart'
    show kAiSmartSearchHeroTag;
import 'package:wetravellers/features/home/presentation/widgets/home_section.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Header — the hero destination + mic placeholder (US-1 STEP 12).
// ---------------------------------------------------------------------------

/// The pinned search header: back affordance, the hero-destination field,
/// clear + send, and the disabled microphone extension point.
class UniversalSearchHeader extends StatelessWidget {
  const UniversalSearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onBack,
    required this.onClear,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          // Glass circular back — the quiet language the AI chat header
          // close uses.
          Material(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Hero(
              tag: kAiSmartSearchHeroTag,
              // A quiet structural stand-in while the capsule lands: same
              // bounds, same silhouette — the header never flashes when
              // the flight hands over.
              placeholderBuilder: (_, _, _) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(color: AppColors.aiContainer),
                ),
                child: const SizedBox(height: 40 + AppSpacing.md),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(color: AppColors.aiContainer),
                ),
                child: Row(
                  children: <Widget>[
                    // Same 24px sparkle + md gap as the closed Home pill —
                    // the caret lands exactly where the hint text sat.
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 24,
                      color: AppColors.ai,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        minLines: 1,
                        maxLines: 4,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => onSubmit(),
                        style: AppTypography.forLight().bodyMedium,
                        decoration: InputDecoration(
                          hintText: l10n.aiSearchSheetHint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                    if (hasText)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textTertiary),
                        tooltip: 'Clear',
                        visualDensity: VisualDensity.compact,
                        onPressed: onClear,
                      ),
                    const SizedBox(width: AppSpacing.xs),
                    _SendButton(enabled: hasText, onTap: onSubmit),
                    const SizedBox(width: AppSpacing.xs),
                    // Disabled microphone placeholder — US-3+ extension
                    // point. Semantically a disabled button, excluded from
                    // interactive traversal.
                    ExcludeSemantics(
                      child: Semantics(
                        button: true,
                        enabled: false,
                        label: 'Voice search — coming soon',
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Center(
                            child: Icon(
                              Icons.mic_none_rounded,
                              size: 20,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestions body — recents / categories / live suggestions (US-1 STEP 10).
// ---------------------------------------------------------------------------

/// Offline fallback prompts surfaced before any typing and whenever the
/// suggestion backend is unreachable — the surface is always useful.
class _SmartSearchEntry {
  const _SmartSearchEntry(this.en, this.ar);

  final String en;
  final String ar;

  String resolve(Locale locale) =>
      locale.languageCode == 'ar' ? ar : en;
}

const List<_SmartSearchEntry> _fallbackSuggestions = <_SmartSearchEntry>[
  _SmartSearchEntry(
      'Flights from Cairo to Dubai next week', 'طيران من القاهرة لدبي الأسبوع الجاي'),
  _SmartSearchEntry(
      'Hotels in Sharm El Sheikh for 2 nights', 'فنادق في شرم الشيخ لليلتين'),
  _SmartSearchEntry(
      'Cheap flights to Istanbul this month', 'أرخص رحلات لاستنبول الشهر ده'),
  _SmartSearchEntry(
      'Weekend trip ideas with a budget under \$300', 'أفكار ويك إند بميزانية تحت ٣٠٠ دولار'),
  _SmartSearchEntry(
      'Car rental in Riyadh for 3 days', 'تأجير عربية في الرياض ٣ أيام'),
  _SmartSearchEntry(
      'Best family destinations in Egypt', 'أحسن وجهات عائلية في مصر'),
];

typedef CategoryTapCallback = void Function(String route);

/// The ACTIVE/TYPING body: recents (ACTIVE), categories (ACTIVE only),
/// live suggestions with the local fallback.
class UniversalSearchSuggestionsBody extends StatelessWidget {
  const UniversalSearchSuggestionsBody({
    super.key,
    required this.state,
    required this.onSuggestionTap,
    required this.onRecentTap,
    required this.onRecentDismiss,
    required this.onClearRecents,
    required this.onCategoryTap,
  });

  final UniversalSearchState state;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<int> onRecentDismiss;
  final VoidCallback onClearRecents;
  final CategoryTapCallback onCategoryTap;

  List<String> _suggestionsFor(Locale locale) {
    if (state.suggestions.isNotEmpty) return state.suggestions;
    if (state.query.trim().length >= 2) {
      final resolved =
          _fallbackSuggestions.map((e) => e.resolve(locale)).toList();
      final q = state.query.trim().toLowerCase();
      final matches =
          resolved.where((s) => s.toLowerCase().contains(q)).toList();
      return matches.isNotEmpty ? matches : resolved;
    }
    return _fallbackSuggestions.map((e) => e.resolve(locale)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final suggestions = _suggestionsFor(locale);
    final showRecents =
        state.phase == UniversalSearchPhase.active && state.recents.isNotEmpty;

    if (state.suggestionsLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    final rows = <Widget>[
      if (showRecents) ...<Widget>[
        _SectionHeader(
          title: l10n.recentSearches,
          onClear: onClearRecents,
        ),
        for (var i = 0; i < state.recents.length; i++)
          _RecentTile(
            text: state.recents[i],
            onTap: () => onRecentTap(state.recents[i]),
            onDismiss: () => onRecentDismiss(i),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
      // Categories — ACTIVE only; hidden in TYPING (US-1 STEP 11).
      if (state.phase == UniversalSearchPhase.active) ...<Widget>[
        _CategoriesRow(onCategoryTap: onCategoryTap),
        const SizedBox(height: AppSpacing.sm),
      ],
      _SectionHeader(title: l10n.aiSearchSuggestions),
      for (final suggestion in suggestions)
        _SuggestionTile(
          text: suggestion,
          onTap: () => onSuggestionTap(suggestion),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: rows,
    );
  }
}

/// The four category chips — each exits to the EXISTING vertical page.
class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.onCategoryTap});

  final CategoryTapCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _CategoryChip(
              icon: Icons.flight_takeoff_rounded,
              label: l10n.searchFlights,
              onTap: () => onCategoryTap('/flights'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CategoryChip(
              icon: Icons.hotel_rounded,
              label: l10n.searchHotels,
              onTap: () => onCategoryTap('/hotels'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CategoryChip(
              icon: Icons.directions_car_rounded,
              label: l10n.searchCars,
              onTap: () => onCategoryTap('/cars'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CategoryChip(
              icon: Icons.card_travel_rounded,
              label: l10n.searchPackages,
              onTap: () => onCategoryTap('/packages'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    return Material(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 22, color: AppColors.brand),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
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
    );
  }
}

// ---------------------------------------------------------------------------
// Loading + Results bodies (US-1 STEP 19/20).
// ---------------------------------------------------------------------------

/// The SEARCHING body — shimmer placeholder while the existing
/// controllers run.
class UniversalSearchLoadingBody extends StatelessWidget {
  const UniversalSearchLoadingBody({super.key, required this.aiInterpreting});

  final bool aiInterpreting;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: aiInterpreting ? AppColors.ai : null,
        ),
      ),
    );
  }
}

typedef FollowUpTapCallback = void Function(FollowUpAction action);

/// The RESULTS/AI_RESULT body — narrative + product sections rendered
/// through the EXISTING `HomeSectionWidget`, follow-up chips for
/// intent-based results, and the edit-query affordance.
class UniversalSearchResultsBody extends ConsumerWidget {
  const UniversalSearchResultsBody({
    super.key,
    required this.state,
    this.scrollController,
    required this.onEditQuery,
    required this.onFollowUp,
    required this.onRetry,
  });

  final UniversalSearchState state;
  final ScrollController? scrollController;
  final VoidCallback onEditQuery;
  final FollowUpTapCallback onFollowUp;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = AppTypography.forLight();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  state.aiNarrative ??
                      l10n.aiSearchResultsFor(state.query.trim()),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.captionSemibold.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              InkWell(
                onTap: onEditQuery,
                borderRadius: AppRadius.pillBorder,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: AppRadius.pillBorder,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.aiSearchEditQuery,
                        style: typography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Follow-up chips — only when the result came from a structured
        // intent (US-1 STEP 20: the two intent-patchable follow-ups).
        if (state.phase == UniversalSearchPhase.aiResult &&
            state.structuredIntent != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                _FollowUpChip(
                  label: 'أرخص',
                  onTap: () => onFollowUp(FollowUpAction.cheaper),
                ),
                _FollowUpChip(
                  label: 'أفخم',
                  onTap: () => onFollowUp(FollowUpAction.morePremium),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.resultSections.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.search_off_rounded,
                            size: 36, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.aiSearchNoSuggestions,
                          textAlign: TextAlign.center,
                          style: typography.body
                              .copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: onRetry,
                          child: Text(l10n.adminRetry),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.xl,
                  ),
                  itemCount: state.resultSections.length,
                  itemBuilder: (context, index) => HomeSectionWidget(
                    section: state.resultSections[index],
                  ),
                ),
        ),
      ],
    );
  }
}

class _FollowUpChip extends StatelessWidget {
  const _FollowUpChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    return Material(
      color: AppColors.aiContainer,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: typography.captionSemibold.copyWith(
              color: AppColors.onAiContainer,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared tiles — carried over from the v1 surface (US-1 STEP 4).
// ---------------------------------------------------------------------------

/// Quiet section header with an optional trailing clear action.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onClear});

  final String title;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: typography.captionSemibold.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (onClear != null)
            InkWell(
              onTap: onClear,
              child: Text(
                l10n.clearAll,
                style: typography.captionSemibold.copyWith(
                  color: AppColors.ai,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One persisted recent search row — history icon, text, individual remove.
class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.text,
    required this.onTap,
    required this.onDismiss,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyLargeMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.textTertiary),
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One live/default suggestion row.
class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.aiContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  size: 18,
                  color: AppColors.ai,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: typography.bodyLargeMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.north_west_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send prompt',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? null : AppColors.surfaceTertiary,
              gradient: enabled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[AppColors.ai, AppColors.aiLight],
                    )
                  : null,
            ),
            child: Icon(
              Icons.arrow_upward,
              size: 20,
              color: enabled
                  ? Colors.white
                  : AppColors.textTertiary.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
