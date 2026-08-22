import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/search/hotel_search_params.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/features/search/application/providers/hotel_car_providers.dart';
import 'package:wetravellers/features/search/application/controllers/hotel_search_controller.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/core/theme/app_colors.dart';

class HotelSearchPage extends ConsumerStatefulWidget {
  const HotelSearchPage({super.key});

  @override
  ConsumerState<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends ConsumerState<HotelSearchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerAnimation;

  String _destination = '';
  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 10));
  int _guests = 2;
  int _rooms = 1;

  final _destController = TextEditingController();
  bool _formExpanded = true;

  final _popularDestinations = [
    ('Dubai', '🇦🇪'),
    ('Istanbul', '🇹🇷'),
    ('London', '🇬🇧'),
    ('Paris', '🇫🇷'),
    ('Cairo', '🇪🇬'),
    ('Riyadh', '🇸🇦'),
  ];

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
          _destination = extra['city']?.toString() ?? '';
          _destController.text = _destination;
          _checkIn = extra['checkIn'] as DateTime? ?? _checkIn;
          _checkOut = extra['checkOut'] as DateTime? ?? _checkOut;
        });
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _search() {
    if (_destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _formExpanded = false);
    final params = HotelSearchParams(
      destination: _destination.trim(),
      checkIn: _checkIn,
      checkOut: _checkOut,
      rooms: _rooms,
      adults: _guests,
    );
    ref.read(hotelSearchControllerProvider.notifier).search(params);
  }

  int get _nights => _checkOut.difference(_checkIn).inDays.abs().clamp(1, 999);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hotelSearchControllerProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _formExpanded ? 380 : 70,
            pinned: true,
            backgroundColor: AppColors.brand,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildSearchForm(theme),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _formExpanded ? 0 : 1,
              child: Text(
                _destination.isEmpty ? 'Hotels' : 'Hotels · $_destination',
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
          _buildResultsSliver(state, theme, cs),
        ],
      ),
    );
  }

  Widget _buildSearchForm(ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0057B3), AppColors.brand, Color(0xFF5EA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 56, 16, 16),
      child: FadeTransition(
        opacity: _headerAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hotels', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${_nights} night${_nights > 1 ? 's' : ''} · $_guests guest${_guests > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),

            // Destination Field
            _buildField(
              icon: Icons.location_on_outlined,
              child: TextField(
                controller: _destController,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Where are you going?',
                  hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => _destination = v,
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(height: 10),

            // Dates Row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    icon: Icons.calendar_today_outlined,
                    child: GestureDetector(
                      onTap: _pickCheckIn,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Check-in', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                          Text(DateFormat('MMM d').format(_checkIn),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(
                    icon: Icons.calendar_today_outlined,
                    child: GestureDetector(
                      onTap: _pickCheckOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Check-out', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                          Text(DateFormat('MMM d').format(_checkOut),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Guests row
            _buildField(
              icon: Icons.people_outline,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Guests & Rooms', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                        Text('$_guests guests · $_rooms room', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                      ],
                    ),
                  ),
                  _counterBtn(Icons.remove, () { if (_guests > 1) setState(() => _guests--); }),
                  const SizedBox(width: 8),
                  Text('$_guests', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  _counterBtn(Icons.add, () { setState(() => _guests++); }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Search Hotels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),

            // Popular destinations chips
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _popularDestinations.map((dest) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _destination = dest.$1;
                          _destController.text = dest.$1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Text('${dest.$2} ${dest.$1}',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
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

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.brandContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.brand),
      ),
    );
  }

  Future<void> _pickCheckIn() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() { _checkIn = d; if (_checkOut.isBefore(_checkIn)) _checkOut = _checkIn.add(const Duration(days: 3)); });
  }

  Future<void> _pickCheckOut() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _checkOut = d);
  }

  Widget _buildResultsSliver(HotelSearchState state, ThemeData theme, ColorScheme cs) {
    switch (state.status) {
      case HotelSearchStatus.idle:
        return SliverToBoxAdapter(child: _buildIdleState(cs));
      case HotelSearchStatus.loading:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const _HotelCardSkeleton(),
            childCount: 5,
          ),
        );
      case HotelSearchStatus.success:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _HotelCard(
              offer: state.results[i],
              nights: _nights,
              onTap: () {
                ref.read(selectedOfferProvider.notifier).state = SelectedOffer(
                  offerId: state.results[i].id,
                  providerId: state.results[i].providerId,
                  providerName: state.results[i].providerName,
                  price: state.results[i].price,
                  currency: state.results[i].currency,
                  searchId: '',
                  offerType: 'hotel',
                );
                context.push('/booking/review');
              },
            ),
            childCount: state.results.length,
          ),
        );
      case HotelSearchStatus.empty:
        return SliverToBoxAdapter(
          child: _buildEmptyState(cs),
        );
      case HotelSearchStatus.error:
        return SliverToBoxAdapter(
          child: _buildErrorState(state.errorMessage ?? 'Error', cs),
        );
    }
  }

  Widget _buildIdleState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.hotel_outlined, size: 64, color: cs.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Find your perfect stay', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text('Search from thousands of hotels worldwide', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.search_off, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No hotels found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text('Try a different destination or dates', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => setState(() => _formExpanded = true), child: const Text('Edit Search')),
        ],
      ),
    );
  }

  Widget _buildErrorState(String msg, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.wifi_off_rounded, size: 64, color: cs.error.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Connection error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(icon: const Icon(Icons.refresh), label: const Text('Retry'), onPressed: _search),
        ],
      ),
    );
  }
}

// ─── Hotel Card ────────────────────────────────────────────────────────────────

class _HotelCard extends StatelessWidget {
  final HotelOffer offer;
  final int nights;
  final VoidCallback onTap;

  const _HotelCard({required this.offer, required this.nights, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final totalPrice = (offer.price * nights).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  if (offer.imageUrl != null)
                    Image.network(
                      offer.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  else
                    _placeholderImage(),

                  // Rating badge
                  if (offer.rating != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
                            const SizedBox(width: 3),
                            Text(offer.rating!.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            if (offer.reviewCount != null)
                              Text(' (${offer.reviewCount})',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

                  // Bookmark
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(offer.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF8E8E93)),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    offer.subtitle ?? '${offer.city}, ${offer.country}',
                                    style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${offer.price.round()}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.brand),
                          ),
                          const Text('per night', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                          Text(
                            '\$$totalPrice total',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5F5F63)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Room type
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.brandContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      offer.roomType,
                      style: const TextStyle(fontSize: 12, color: AppColors.brand, fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Amenities
                  if (offer.amenities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: offer.amenities.take(4).map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(a, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                        );
                      }).toList(),
                    ),
                  ],

                  // CTA
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.brandContainer,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel_rounded, size: 48, color: AppColors.brand),
          SizedBox(height: 8),
          Text('Hotel Image', style: TextStyle(color: AppColors.brand, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────────

class _HotelCardSkeleton extends StatefulWidget {
  const _HotelCardSkeleton();

  @override
  State<_HotelCardSkeleton> createState() => _HotelCardSkeletonState();
}

class _HotelCardSkeletonState extends State<_HotelCardSkeleton>
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
      builder: (_, __) {
        final opacity = 0.5 + _anim.value * 0.3;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200, decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: opacity),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              )),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 200, color: Colors.grey.withValues(alpha: opacity), margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 12, width: 140, color: Colors.grey.withValues(alpha: opacity * 0.7), margin: const EdgeInsets.only(bottom: 12)),
                    Container(height: 40, color: Colors.grey.withValues(alpha: opacity * 0.5)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}