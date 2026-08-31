import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/home/home_item.dart';
import 'package:wetravellers/core/domain/models/home/home_types.dart';
import 'package:wetravellers/core/domain/models/offers/travel_package_offer.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/features/search/application/providers/offer_selection_provider.dart';
import 'package:wetravellers/features/search/presentation/widgets/package_search_card.dart';

class PackagesSearchPage extends ConsumerStatefulWidget {
  const PackagesSearchPage({super.key});

  @override
  ConsumerState<PackagesSearchPage> createState() => _PackagesSearchPageState();
}

class _PackagesSearchPageState extends ConsumerState<PackagesSearchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerAnimation;

  String _destinationLabel = '';
  bool _formExpanded = true;
  List<HomeItem> _results = const [];

  // Mock data only this phase (Phase 19B) — no backend call.
  static final List<HomeItem> _mockPackages = [
    HomeItem(
      id: 'pkg-sharm-1',
      type: HomeCardType.package,
      title: 'Sharm El Sheikh · 5 days',
      subtitle: 'Flights + resort + transfers',
      price: 599,
      currency: 'USD',
      rating: 4.7,
      reviewCount: 132,
      highlights: ['All inclusive', 'Airport transfer'],
      imageUrl: 'https://loremflickr.com/400/300/redsea,resort',
    ),
    HomeItem(
      id: 'pkg-luxor-1',
      type: HomeCardType.package,
      title: 'Luxor & Aswan cruise · 4 nights',
      subtitle: 'Nile cruise with guided tours',
      price: 749,
      currency: 'USD',
      rating: 4.8,
      reviewCount: 87,
      highlights: ['Guided temples', 'Full board'],
      imageUrl: 'https://loremflickr.com/400/300/luxor,nile,cruise',
    ),
    HomeItem(
      id: 'pkg-hurghada-1',
      type: HomeCardType.package,
      title: 'Hurghada getaway · 4 days',
      subtitle: 'Beach resort + snorkeling trips',
      price: 459,
      currency: 'USD',
      rating: 4.5,
      reviewCount: 118,
      highlights: ['Reef snorkeling', 'All inclusive'],
      imageUrl: 'https://loremflickr.com/400/300/hurghada,redsea,beach',
    ),
    HomeItem(
      id: 'pkg-siwa-1',
      type: HomeCardType.package,
      title: 'Siwa Oasis safari · 3 days',
      subtitle: 'Desert springs & salt lakes',
      price: 329,
      currency: 'USD',
      rating: 4.6,
      reviewCount: 64,
      highlights: ['4x4 desert safari', 'Eco lodge stay'],
      imageUrl: 'https://loremflickr.com/400/300/siwa,desert,oasis',
    ),
    HomeItem(
      id: 'pkg-whitedesert-1',
      type: HomeCardType.package,
      title: 'White Desert camping · 2 nights',
      subtitle: 'Crystal formations under the stars',
      price: 289,
      currency: 'USD',
      rating: 4.8,
      reviewCount: 52,
      highlights: ['Bedouin dinner', 'Stargazing camp'],
      imageUrl: 'https://loremflickr.com/400/300/desert,camping,egypt',
    ),
    HomeItem(
      id: 'pkg-abusimbel-1',
      type: HomeCardType.package,
      title: 'Aswan & Abu Simbel · 3 days',
      subtitle: 'Temples, felucca sailing & Nubian village',
      price: 419,
      currency: 'USD',
      rating: 4.7,
      reviewCount: 76,
      highlights: ['Abu Simbel entry', 'Felucca sunset sail'],
      imageUrl: 'https://loremflickr.com/400/300/abusimbel,temple,egypt',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _headerAnimation = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
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

  void _search(String destination, int tripDays) {
    _collapseForm();
    var results = List.of(_mockPackages);
    final query = destination.trim().toLowerCase();
    if (query.isNotEmpty) {
      results = results.where((p) =>
          p.title.toLowerCase().contains(query) ||
          (p.subtitle ?? '').toLowerCase().contains(query)).toList();
    }
    if (!_formExpanded && tripDays <= 2) {
      results = results.where((p) => (p.price ?? 0) < 500).toList();
    }
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Gradient App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _formExpanded ? 430 : 70,
            pinned: true,
            backgroundColor: AppColors.brand,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _formExpanded ? 0 : 1,
              child: Text(
                _destinationLabel.isEmpty ? 'Packages' : 'Packages · $_destinationLabel',
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
          _buildResultsSliver(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tour Packages', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Everything arranged, just pack and go',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: AppSpacing.md),
            _PackageSearchForm(
              onDestinationChanged: (d) {
                if (d != _destinationLabel) setState(() => _destinationLabel = d);
              },
              onSearchStarted: _search,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSliver() {
    if (_results.isEmpty) {
      return SliverToBoxAdapter(child: _buildIdleOrEmpty());
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => PackageSearchCard(
          offer: _convertToTravelPackageOffer(_results[i]),
          onTap: () {
            ref.read(selectedOfferProvider.notifier).state = SelectedOffer(
              offerId: _results[i].id,
              providerId: _results[i].metadata['providerId']?.toString() ?? '',
              providerName: _results[i].metadata['providerName']?.toString() ?? '',
              price: _results[i].price ?? 0,
              currency: _results[i].currency ?? 'USD',
              searchId: '',
              offerType: 'package',
            );
            context.push('/booking/review');
          },
        ),
        childCount: _results.length,
      ),
    );
  }

  TravelPackageOffer _convertToTravelPackageOffer(HomeItem item) {
    final metadata = item.metadata;
    return TravelPackageOffer(
      id: item.id,
      providerId: metadata['providerId']?.toString() ?? '',
      providerName: metadata['providerName']?.toString() ?? '',
      title: item.title,
      subtitle: item.subtitle,
      description: item.description,
      imageUrl: item.imageUrl,
      price: item.price ?? 0,
      currency: item.currency ?? 'USD',
      availability: item.metadata['availability'] as bool?,
      validUntil: item.metadata['validUntil'] is DateTime
          ? item.metadata['validUntil'] as DateTime
          : null,
      metadata: Map<String, dynamic>.from(metadata),
      rating: item.rating,
      reviewCount: item.reviewCount,
      destination: metadata['destination']?.toString() ?? item.subtitle ?? '',
      durationDays: metadata['durationDays'] is int
          ? metadata['durationDays'] as int
          : int.tryParse(metadata['durationDays']?.toString() ?? '') ?? 0,
      inclusions: (metadata['inclusions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Widget _buildIdleOrEmpty() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Icon(Icons.tour_outlined, size: 64, color: cs.primary.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text('Discover curated tour packages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Text('Search above to explore all-inclusive trips across Egypt and beyond.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Search Form ───────────────────────────────────────────────────────────────

class _PackageSearchForm extends StatefulWidget {
  final void Function(String destination)? onDestinationChanged;
  final void Function(String destination, int tripDays)? onSearchStarted;

  const _PackageSearchForm({this.onDestinationChanged, this.onSearchStarted});

  @override
  State<_PackageSearchForm> createState() => _PackageSearchFormState();
}

class _PackageSearchFormState extends State<_PackageSearchForm> {
  final TextEditingController _destCtrl = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  int _tripDays = 5;

  static const List<(String, String)> _popularPackages = [
    ('Sharm El Sheikh', '🇪🇬'),
    ('Luxor & Aswan', '🛳️'),
    ('Hurghada', '🐠'),
    ('Siwa Oasis', '🏜️'),
    ('White Desert', '⛺'),
  ];

  @override
  void dispose() {
    _destCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destination Field
        _buildField(
          icon: Icons.location_on_outlined,
          child: TextField(
            controller: _destCtrl,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Where do you want to go?',
              hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => widget.onDestinationChanged?.call(v),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Dates + trip length row
        Row(
          children: [
            Expanded(
              child: _buildField(
                icon: Icons.calendar_today_outlined,
                child: GestureDetector(
                  onTap: _pickDate,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Departure', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                      Text(DateFormat('EEE, MMM d').format(_startDate),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildField(
                icon: Icons.timelapse,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trip length', style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                          Text('$_tripDays days',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () { if (_tripDays > 2) setState(() => _tripDays--); },
                      child: const Icon(Icons.remove_circle_outline, size: 18, color: AppColors.brand),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () { if (_tripDays < 21) setState(() => _tripDays++); },
                      child: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.brand),
                    ),
                  ],
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
            onPressed: () => widget.onSearchStarted?.call(_destCtrl.text, _tripDays),
            icon: const Icon(Icons.search, size: 20),
            label: const Text('Search Packages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.brand,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),

        // Popular packages chips
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _popularPackages.map((dest) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _destCtrl.text = dest.$1);
                    widget.onDestinationChanged?.call(dest.$1);
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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _startDate = d);
  }
}
