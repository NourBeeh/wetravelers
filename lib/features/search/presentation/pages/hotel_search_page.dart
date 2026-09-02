import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wetravellers/core/domain/models/search/hotel_search_params.dart';
import 'package:wetravellers/features/search/application/providers/hotel_car_providers.dart';
import 'package:wetravellers/features/search/application/controllers/hotel_search_controller.dart';
import 'package:wetravellers/core/theme/app_colors.dart';
import 'package:wetravellers/core/theme/app_spacing.dart';
import 'package:wetravellers/core/theme/app_radius.dart';
import 'package:wetravellers/core/theme/app_typography.dart';
import 'package:wetravellers/features/search/presentation/widgets/search_scaffold.dart';
import 'package:wetravellers/features/search/presentation/widgets/search_states_view.dart';
import 'package:wetravellers/features/search/presentation/widgets/destination_picker_sheet.dart';
import 'package:wetravellers/features/search/presentation/widgets/hotel_search_card.dart';
import 'package:wetravellers/features/search/presentation/widgets/search_view_toggle.dart';
import 'package:wetravellers/features/search/presentation/widgets/search_map_placeholder.dart';
import 'package:wetravellers/features/search/application/providers/search_view_providers.dart';
import 'package:wetravellers/features/search/domain/search_view_mode.dart';

class HotelSearchPage extends ConsumerStatefulWidget {
  const HotelSearchPage({super.key});

  @override
  ConsumerState<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends ConsumerState<HotelSearchPage> {
  final _destController = TextEditingController();
  final _checkInCtrl = TextEditingController();
  final _checkOutCtrl = TextEditingController();

  String _destination = '';
  DateTime _checkIn = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 10));
  int _guests = 2;
  int _rooms = 1;

  HotelSearchParams? _lastParams;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _checkInCtrl.text = DateFormat('EEE, MMM d').format(_checkIn);
    _checkOutCtrl.text = DateFormat('EEE, MMM d').format(_checkOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    // Pre-fill from navigation extras — must read the router AFTER
    // initState completes (inherited widgets are legal here).
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null) {
      _destination = extra['city']?.toString() ?? '';
      _destController.text = _destination;
      _checkIn = extra['checkIn'] as DateTime? ?? _checkIn;
      _checkOut = extra['checkOut'] as DateTime? ?? _checkOut;
      _checkInCtrl.text = DateFormat('EEE, MMM d').format(_checkIn);
      _checkOutCtrl.text = DateFormat('EEE, MMM d').format(_checkOut);
    }
  }

  @override
  void dispose() {
    _destController.dispose();
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    super.dispose();
  }

  int get _nights => _checkOut.difference(_checkIn).inDays.abs().clamp(1, 999);

  String get _subtitle =>
      '$_nights night${_nights > 1 ? 's' : ''} · $_guests guest${_guests > 1 ? 's' : ''} · $_rooms room${_rooms > 1 ? 's' : ''}';

  void _pickDestination() {
    showPickerSheet(
      context,
      title: 'Where to?',
      entries: kCities,
      onSelected: (entry) => setState(() {
        _destination = entry.name;
        _destController.text = entry.name;
      }),
    );
  }

  Future<void> _pickCheckIn() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        _checkIn = d;
        // Cross-validation: checkout must stay after checkin.
        if (_checkOut.isBefore(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 3));
          _checkOutCtrl.text = DateFormat('EEE, MMM d').format(_checkOut);
        }
        _checkInCtrl.text = DateFormat('EEE, MMM d').format(_checkIn);
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        _checkOut = d;
        _checkOutCtrl.text = DateFormat('EEE, MMM d').format(_checkOut);
      });
    }
  }

  void _search() {
    if (_destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a destination'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final params = HotelSearchParams(
      destination: _destination.trim(),
      checkIn: _checkIn,
      checkOut: _checkOut,
      rooms: _rooms,
      adults: _guests,
    );
    _lastParams = params;
    ref.read(hotelSearchControllerProvider.notifier).search(params);
  }

  void _retry() {
    final params = _lastParams;
    if (params != null) {
      ref.read(hotelSearchControllerProvider.notifier).search(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hotelSearchControllerProvider);

    return SearchScaffold(
      hue: AppColors.hotelHue,
      title: 'Hotels',
      subtitle: _subtitle,
      collapsedTitle:
          _destination.isEmpty ? 'Hotels' : 'Hotels · $_destination',
      headerActions: const SearchViewToggle(),
      form: _buildForm(),
      body: _buildResults(state),
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFieldInput(
          icon: Icons.location_on_outlined,
          hint: 'Where are you going?',
          controller: _destController,
          readOnly: true,
          onTap: _pickDestination,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: SearchFieldInput(
                icon: Icons.calendar_today_outlined,
                hint: 'Check-in',
                controller: _checkInCtrl,
                readOnly: true,
                onTap: _pickCheckIn,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SearchFieldInput(
                icon: Icons.calendar_today_outlined,
                hint: 'Check-out',
                controller: _checkOutCtrl,
                readOnly: true,
                onTap: _pickCheckOut,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildGuestsRow(),
        const SizedBox(height: AppSpacing.md),
        _buildRoomsRow(),
        const SizedBox(height: AppSpacing.lg),
        SearchSubmitButton(
          label: 'Search hotels',
          onPressed: _search,
          hue: AppColors.hotelHue,
        ),
      ],
    );
  }

  Widget _buildGuestsRow() {
    return _stepperRow(
      icon: Icons.people_outline_rounded,
      label: '$_guests guest${_guests > 1 ? 's' : ''}',
      count: _guests,
      onDecrement: () => setState(() { if (_guests > 1) _guests--; }),
      onIncrement: () => setState(() => _guests++),
    );
  }

  Widget _buildRoomsRow() {
    return _stepperRow(
      icon: Icons.meeting_room_outlined,
      label: '$_rooms room${_rooms > 1 ? 's' : ''}',
      count: _rooms,
      onDecrement: () => setState(() { if (_rooms > 1) _rooms--; }),
      onIncrement: () => setState(() => _rooms++),
    );
  }

  Widget _stepperRow({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    final typography = AppTypography.forLight();
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.brand),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: typography.bodyLarge.copyWith(color: AppColors.textPrimary),
            ),
          ),
          _stepperButton(Icons.remove_rounded, onDecrement),
          const SizedBox(width: AppSpacing.md),
          Text('$count',
              style: typography.bodyLargeMedium
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: AppSpacing.md),
          _stepperButton(Icons.add_rounded, onIncrement),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.brandContainer,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Icon(icon, size: 18, color: AppColors.brand),
      ),
    );
  }

  // ── Results ─────────────────────────────────────────────────────────────
  Widget _buildResults(HotelSearchState state) {
    final viewMode = ref.watch(searchViewModeProvider);

    switch (state.status) {
      case HotelSearchStatus.idle:
        return const SearchStatesView.idle(
          icon: Icons.hotel_outlined,
          title: 'Find your perfect stay',
          body: 'Search from thousands of hotels worldwide',
        );
      case HotelSearchStatus.loading:
        return const SearchStatesView.loading(
          skeleton: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: HotelSearchCard.loading(),
          ),
        );
      case HotelSearchStatus.success:
        if (viewMode == SearchViewMode.map) {
          return const SearchMapPlaceholder();
        }
        return Column(
          children: [
            for (final offer in state.results)
              HotelSearchCard(
                offer: offer,
                onTap: () => context.push('/offer-details', extra: offer),
                onFavorite: (value) {
                  // TODO: Implement wishlist persistence
                },
                isFavorite: false,
              ),
          ],
        );
      case HotelSearchStatus.empty:
        return const SearchStatesView.empty(
          icon: Icons.search_off_rounded,
          title: 'No hotels found',
          body: 'Try a different destination or dates',
        );
      case HotelSearchStatus.error:
        return SearchStatesView.error(
          title: 'Connection error',
          body: state.errorMessage ?? 'Something went wrong. Please try again.',
          onAction: _retry,
        );
    }
  }
}
