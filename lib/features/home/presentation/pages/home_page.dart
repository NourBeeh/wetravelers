import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/home/presentation/home_controller.dart';
import 'package:wetravellers/features/home/presentation/widgets/home_section.dart';
import 'package:wetravellers/features/home/providers/home_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: _buildBody(state, ref),
      ),
    );
  }

  Widget _buildBody(HomeState state, WidgetRef ref) {
    switch (state.status) {
      case HomeStatus.loading:
        return SafeArea(
          top: true,
          bottom: false,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: 5,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _SkeletonCard(height: 180),
            ),
          ),
        );
      case HomeStatus.success:
      case HomeStatus.partial:
        return SafeArea(
          top: true,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                  child: const _HomeHero(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => HomeSectionWidget(section: state.sections[index]),
                  childCount: state.sections.length,
                ),
              ),
            ],
          ),
        );
      case HomeStatus.empty:
        return const SafeArea(
          top: true,
          bottom: false,
          child: Center(child: Text('No content available')),
        );
      case HomeStatus.error:
        return SafeArea(
          top: true,
          bottom: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Something went wrong. Please try again.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.read(homeControllerProvider.notifier).load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0057B3), AppColors.brand, const Color(0xFF5EA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where to next?',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Plan a city break, beach escape or weekend getaway.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Search entry point → flights search
          GestureDetector(
            onTap: () => context.push('/flights'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppColors.brand),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Search flights, hotels & more',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brandContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_forward, size: 16, color: AppColors.brand),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Service quick links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ServiceLink(icon: Icons.flight_takeoff, label: 'Flights', route: '/flights'),
              _ServiceLink(icon: Icons.hotel, label: 'Hotels', route: '/hotels'),
              _ServiceLink(icon: Icons.directions_car, label: 'Cars', route: '/cars'),
              _ServiceLink(icon: Icons.tour, label: 'Packages', route: '/packages'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _ServiceLink({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final opacity = 0.4 + _anim.value * 0.3;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flexible image placeholder — absorbs height changes so the
                // fixed text rows below can never overflow the card.
                Expanded(
                  child: Container(width: double.infinity, decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  )),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 14, width: 180, color: Colors.grey.withValues(alpha: opacity)),
                const SizedBox(height: AppSpacing.xs),
                Container(height: 12, width: 120, color: Colors.grey.withValues(alpha: opacity * 0.7)),
              ],
            ),
          ),
        );
      },
    );
  }
}
