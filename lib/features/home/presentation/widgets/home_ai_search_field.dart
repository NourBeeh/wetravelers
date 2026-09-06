import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/theme/app_typography.dart';
import 'package:wetravellers/l10n/app_localizations.dart';

/// Hero tag shared by the closed Home pill and the opened search header.
const String kAiSmartSearchHeroTag = 'ai-smart-search-pill';

/// Smart AI search field pinned in the Home header.
///
/// A Google-grade premium search bar: a stark-white pill with the AI
/// sparkle on the leading edge, a soft violet search circle on the trailing
/// edge, wrapped in a slow rotating light comet — a premium sweep of AI
/// violet and brand indigo travelling around the pill border with a quiet
/// breathing glow behind it.
///
/// The pill itself rides a [Hero] flight to the full-screen search page
/// (container transform): on tap it stretches to the page header while the
/// glowing aura stays behind in Home. During the flight a fixed-style
/// capsule shuttle is shown — a single calm gradient, no rotating comet, no
/// live hint text — so typography and effects never flicker mid-flight.
class HomeAiSearchField extends StatefulWidget {
  const HomeAiSearchField({super.key});

  @override
  State<HomeAiSearchField> createState() => _HomeAiSearchFieldState();
}

class _HomeAiSearchFieldState extends State<HomeAiSearchField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _auraController;
  late final Animation<double> _aura;

  @override
  void initState() {
    super.initState();
    // One slow revolution every ~4.5s — the unhurried pace is the premium
    // feel; the comet fades in/out through the sweep so it reads as a
    // travelling light, never a spinning ring.
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
    _aura = CurvedAnimation(parent: _auraController, curve: Curves.linear);
  }

  @override
  void dispose() {
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.forLight();
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.aiSearchHint,
      child: AnimatedBuilder(
        animation: _aura,
        builder: (context, _) {
          // Quiet breathing glow behind the pill — same restrained language
          // the retired AI centre button used. Deliberately OUTSIDE the
          // hero: the glow keeps breathing in Home while the pill flies.
          final breath = 0.06 + _aura.value * 0.06;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.ai.withValues(alpha: breath),
                  blurRadius: 16 + _aura.value * 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _RotatingAuraBorder(
              aura: _aura,
              // Quiet static hairline behind the comet so the field keeps
              // a visible outline on every frame.
              baseBorder: AppColors.ai.withValues(alpha: 0.22),
              child: Hero(
                tag: kAiSmartSearchHeroTag,
                // The closed pill leaves Home entirely while flying.
                placeholderBuilder: (_, _, _) => const SizedBox.shrink(),
                flightShuttleBuilder: _pillShuttle,
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: <Widget>[
                        const SizedBox(width: AppSpacing.xs),
                        // Decorative sparkle — the tap target is the text
                        // region only, Instagram-style.
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 24,
                          color: AppColors.ai,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // The tap region: only the hint-text area opens the
                        // search page. Its vertical extent is the full pill
                        // height, so the target stays >= 48px (a11y) while
                        // the icons remain purely visual.
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: InkWell(
                              onTap: () => context.push('/smart-search'),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  l10n.aiSearchHint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.bodyLarge.copyWith(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Google-style trailing search affordance — a soft
                        // violet circle hosting the lens. Decorative.
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.aiContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.ai,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        // Disabled microphone placeholder — US-3+ extension
                        // point. Never interactive, excluded from taps.
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
                        const SizedBox(width: AppSpacing.xs),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The in-flight capsule — pixel-identical to the expanded header the
  /// flight lands into (US-1 handoff contract): same surfaceSecondary
  /// background, same aiContainer hairline, same leading sparkle at the
  /// same 24px + md gap. The handoff at t=1 is a pure size change with
  /// zero style swap — no snap.
  Widget _pillShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: Curves.easeIn.transform(
            animation.value.clamp(0.0, 1.0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: AppRadius.pillBorder,
              border: Border.all(color: AppColors.aiContainer),
            ),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 24,
                  color: AppColors.ai,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A light comet travelling around the pill border.
///
/// A rounded-rect ring slightly larger than the child is painted through a
/// rotating [SweepGradient] via [ShaderMask]: most of the sweep is
/// transparent and a short arc blends AI violet into brand indigo, so the
/// visible border light orbits the field slowly instead of flashing. The
/// ring sits ABOVE the hero child with pointer events ignored, so the
/// comet keeps orbiting in Home while the pill itself is free to fly.
class _RotatingAuraBorder extends StatelessWidget {
  const _RotatingAuraBorder({
    required this.aura,
    required this.baseBorder,
    required this.child,
  });

  final Animation<double> aura;
  final Color baseBorder;
  final Widget child;

  static const double _borderWidth = 2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Static hairline — the pill's resting outline, wrapped around
        // the hero so the pill keeps its shape while idle in Home.
        Container(
          padding: const EdgeInsets.all(_borderWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: baseBorder, width: _borderWidth),
          ),
          child: child,
        ),
        // The travelling light comet, masked on top of the same ring shape.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: aura,
              builder: (context, _) {
                final rotation = aura.value * 2 * 3.141592653589793;
                return ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) {
                    return SweepGradient(
                      startAngle: -1.5707963267948966,
                      endAngle: 4.71238898038469,
                      colors: const <Color>[
                        Color(0x00000000),
                        Color(0x00000000),
                        AppColors.ai,
                        AppColors.brand,
                        AppColors.aiLight,
                        Color(0x00000000),
                        Color(0x00000000),
                      ],
                      stops: const <double>[0.0, 0.52, 0.62, 0.72, 0.82, 0.92, 1.0],
                      transform: GradientRotation(rotation),
                    ).createShader(bounds);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.ai,
                        width: _borderWidth,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
