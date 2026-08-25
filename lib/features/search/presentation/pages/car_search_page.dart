import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/search/car_search_params.dart';
import 'package:wetravellers/features/search/application/providers/hotel_car_providers.dart';
import 'package:wetravellers/features/search/application/controllers/car_search_controller.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/search/presentation/widgets/car_result_card.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';

class CarSearchPage extends ConsumerStatefulWidget {
  const CarSearchPage({super.key});

  @override
  ConsumerState<CarSearchPage> createState() => _CarSearchPageState();
}

class _CarSearchPageState extends ConsumerState<CarSearchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerAnimation;

  String _pickupLabel = '';
  bool _formExpanded = true;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _headerAnimation = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();

    // Pre-fill from navigation extras
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) {
        setState(() {
          _pickupLabel = extra['pickupLocation']?.toString() ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _collapseForm() {
    setState(() {
      _formExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carSearchControllerProvider);
    final theme = Theme.of(context);

    // Extract initial search parameters from GoRouter state
    final goRouterState = GoRouterState.of(context);
    final extra = goRouterState.extra as Map<String, dynamic>?;
    final initialPickupLocation = extra?['pickupLocation'] as String?;
    final initialDropoffLocation = extra?['dropoffLocation'] as String?;
    final initialPickupDate = extra?['pickupDate'] as DateTime?;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _formExpanded ? 430 : 70,
            pinned: true,
            backgroundColor: AppColors.brand,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(initialPickupLocation, initialDropoffLocation, initialPickupDate),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _formExpanded ? 0 : 1,
              child: Text(
                _pickupLabel.isEmpty ? 'Cars' : 'Cars · $_pickupLabel',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            actions: [
              if (!_formExpanded)
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onPressed: () => setState(() => _formExpanded = true),
                  tooltip: 'Edit Search',
                ),
            ],
          ),

          // ─── Results ────────────────────────────────────────────────────
          _buildResultsSliver(state, initialPickupLocation, initialDropoffLocation, initialPickupDate),
        ],
      ),
    );
  }

  Widget _buildHeader(String? initialPickupLocation,
      String? initialDropoffLocation, DateTime? initialPickupDate) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0057B3), AppColors.brand, Color(0xFF5EA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, MediaQuery.of(context).padding.top + 56, AppSpacing.lg, AppSpacing.lg),
      child: FadeTransition(
        opacity: _headerAnimation,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cars', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Rentals for every journey, from city runarounds to road trips',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              const SizedBox(height: AppSpacing.md),
              CarSearchFormWidget(
                initialPickupLocation: initialPickupLocation,
                initialDropoffLocation: initialDropoffLocation,
                initialPickupTime: initialPickupDate,
                onPickupChanged: (pickup) {
                  if (pickup != _pickupLabel) setState(() => _pickupLabel = pickup);
                },
                onSearchStarted: _collapseForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSliver(CarSearchState state, String? initialPickupLocation,
      String? initialDropoffLocation, DateTime? initialPickupDate) {
    switch (state.status) {
      case CarSearchStatus.idle:
        return SliverToBoxAdapter(child: _buildIdleState());
      case CarSearchStatus.loading:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, _) => const _CarCardSkeleton(),
            childCount: 6,
          ),
        );
      case CarSearchStatus.success:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final item = state.results[i];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedOfferProvider.notifier).state = SelectedOffer(
                    offerId: item.id,
                    providerId: item.providerId,
                    providerName: item.providerName,
                    price: item.price,
                    currency: item.currency,
                    searchId: '',
                    offerType: 'car',
                  );
                  context.push('/booking/review');
                },
                child: CarResultCard(offer: item),
              );
            },
            childCount: state.results.length,
          ),
        );
      case CarSearchStatus.empty:
        return const SliverToBoxAdapter(child: Center(child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No cars found'),
        )));
      case CarSearchStatus.error:
        return SliverToBoxAdapter(child: Center(child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text(state.errorMessage ?? 'Error'),
        )));
    }
  }

  Widget _buildIdleState() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Icon(Icons.directions_car_outlined, size: 64, color: cs.primary.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text('Find your perfect ride', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Text('Compare car rentals at pickup points worldwide', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Search Form ───────────────────────────────────────────────────────────────

class CarSearchFormWidget extends ConsumerStatefulWidget {
  final String? initialPickupLocation;
  final String? initialDropoffLocation;
  final DateTime? initialPickupTime;
  final void Function(String pickup)? onPickupChanged;
  final VoidCallback? onSearchStarted;

  const CarSearchFormWidget({
    super.key,
    this.initialPickupLocation,
    this.initialDropoffLocation,
    this.initialPickupTime,
    this.onPickupChanged,
    this.onSearchStarted,
  });

  @override
  ConsumerState<CarSearchFormWidget> createState() => _CarSearchFormWidgetState();
}

class _CarSearchFormWidgetState extends ConsumerState<CarSearchFormWidget> {
  late final TextEditingController _pickup;
  late final TextEditingController _dropoff;
  late DateTime _pickupTime;
  late DateTime _dropoffTime;

  @override
  void initState() {
    super.initState();
    _pickup = TextEditingController(text: widget.initialPickupLocation ?? '');
    _dropoff = TextEditingController(text: widget.initialDropoffLocation ?? '');
    _pickupTime = widget.initialPickupTime ?? DateTime.now().add(const Duration(days: 1));
    _dropoffTime = DateTime.now().add(const Duration(days: 2));
  }

  @override
  void dispose() {
    _pickup.dispose();
    _dropoff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup Field
        _buildField(
          icon: Icons.location_on_outlined,
          child: TextField(
            controller: _pickup,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Pickup location',
              hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => widget.onPickupChanged?.call(v),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Dropoff Field
        _buildField(
          icon: Icons.flag_outlined,
          child: TextField(
            controller: _dropoff,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Dropoff location',
              hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Dates Row
        Row(
          children: [
            Expanded(
              child: _buildField(
                icon: Icons.calendar_today_outlined,
                child: GestureDetector(
                  onTap: _pickPickupDate,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pick-up', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                      Text(DateFormat('EEE, MMM d').format(_pickupTime),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1D1F))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildField(
                icon: Icons.calendar_today_outlined,
                child: GestureDetector(
                  onTap: _pickDropoffDate,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Drop-off', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                      Text(DateFormat('EEE, MMM d').format(_dropoffTime),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1D1F))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Search button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search, size: 20),
            label: const Text('Search Cars',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.brand,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> _pickPickupDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _pickupTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        _pickupTime = d;
        if (_dropoffTime.isBefore(_pickupTime)) {
          _dropoffTime = _pickupTime.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickDropoffDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dropoffTime,
      firstDate: _pickupTime.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _dropoffTime = d);
  }

  void _search() {
    widget.onSearchStarted?.call();
    final params = CarSearchParams(pickupLocation: _pickup.text, dropoffLocation: _dropoff.text, pickupDateTime: _pickupTime, dropoffDateTime: _dropoffTime);
    ref.read(carSearchControllerProvider.notifier).search(params);
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

class _CarCardSkeleton extends StatefulWidget {
  const _CarCardSkeleton();

  @override
  State<_CarCardSkeleton> createState() => _CarCardSkeletonState();
}

class _CarCardSkeletonState extends State<_CarCardSkeleton>
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
        final opacity = 0.5 + _anim.value * 0.3;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(width: 72, height: 48, decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 140, color: Colors.grey.withValues(alpha: opacity), margin: const EdgeInsets.only(bottom: 8)),
                      Container(height: 12, width: 100, color: Colors.grey.withValues(alpha: opacity * 0.7)),
                    ],
                  ),
                ),
                Container(height: 24, width: 60, color: Colors.grey.withValues(alpha: opacity * 0.7)),
              ],
            ),
          ),
        );
      },
    );
  }
}
