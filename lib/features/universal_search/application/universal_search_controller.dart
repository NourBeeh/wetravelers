import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wetravellers/core/domain/models/home/home_section.dart';
import 'package:wetravellers/core/domain/models/search/flight_search_params.dart';
import 'package:wetravellers/core/domain/models/search/hotel_search_params.dart';
import 'package:wetravellers/core/domain/models/search/car_search_params.dart';
import 'package:wetravellers/core/storage/offline_cache.dart';
import 'package:wetravellers/core/storage/offline_cache_providers.dart';
import 'package:wetravellers/features/ai/application/ai_providers.dart'
    show aiSuggestionsServiceProvider;
import 'package:wetravellers/features/ai/domain/search_intent_parser.dart';
import 'package:wetravellers/features/search/application/providers/search_providers.dart'
    show flightSearchControllerProvider;
import 'package:wetravellers/features/search/application/providers/hotel_car_providers.dart'
    show hotelSearchControllerProvider, carSearchControllerProvider;
import 'package:wetravellers/features/search/application/controllers/flight_search_controller.dart';
import 'package:wetravellers/features/search/application/controllers/hotel_search_controller.dart';
import 'package:wetravellers/features/search/application/controllers/car_search_controller.dart';
import 'package:wetravellers/features/universal_search/application/universal_search_state.dart';
import 'package:wetravellers/features/universal_search/data/offer_to_home_item_adapters.dart';
import 'package:wetravellers/features/universal_search/domain/structured_travel_intent.dart';

/// Orchestrator of the Universal Search surface — the single source of
/// truth (US-1 STEP 3). Owns the state machine, query preservation,
/// recents, debounced suggestions and intent compilation. The actual
/// search business logic stays in the EXISTING flight/hotel/car
/// controllers — this class only orchestrates them.
///
/// Behavioral events (`hotel_search`) fire from inside the existing
/// controllers on success, exactly as in the vertical flows — Universal
/// Search never starves the Recommendation Engine.
class UniversalSearchController extends StateNotifier<UniversalSearchState> {
  UniversalSearchController({
    required this.suggestionsDelegate,
    required this.cache,
    required this.flightSearch,
    required this.hotelSearch,
    required this.carSearch,
  }) : super(const UniversalSearchState());

  final AiSuggestionsDelegate suggestionsDelegate;
  final OfflineCache cache;
  final FlightSearchController flightSearch;
  final HotelSearchController hotelSearch;
  final CarSearchController carSearch;

  static const String _kRecentPrefix = 'ai_search_recent/';
  static const String _kPreservedQueryKey = 'universal_search/preserved_query';
  static const int _kRecentLimit = 8;
  static const Duration _kDebounce = Duration(milliseconds: 400);

  /// Public read for wiring/pages that need the current snapshot before
  /// watching the provider (e.g. seeding the field on mount).
  UniversalSearchState get currentState => state;

  /// Restores the query preserved by the previous session (US-1 STEP 8).
  /// Returns empty when none exists. Called by the page on mount BEFORE
  /// `open()` so the machine can reopen into TYPING.
  Future<String> restorePreservedQuery() async {
    try {
      final entry = await cache.read(_kPreservedQueryKey);
      final text = entry?['text'] as String?;
      return text ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Persists the query so the next open can resume (called on every query
  /// change — a tiny single-key write, and on close the last one stands).
  Future<void> preserveQuery(String text) async {
    try {
      await cache.write(
        _kPreservedQueryKey,
        <String, dynamic>{'text': text},
      );
    } catch (_) {
      // Best-effort persistence only.
    }
  }

  Timer? _debounce;
  int _suggestVersion = 0;
  int _searchVersion = 0;

  // ---------------------------------------------------------------------------
  // Phase transitions — the only door into the state machine.
  // ---------------------------------------------------------------------------

  void _goTo(UniversalSearchPhase next) {
    if (state.phase == next) return;
    if (!state.canGoTo(next)) {
      assert(
        false,
        'Forbidden transition ${state.phase.name} -> ${next.name}',
      );
      return;
    }
    state = state.copyWith(phase: next);
  }

  /// The Home pill was tapped — the container-transform opening begins.
  void open() => _goTo(UniversalSearchPhase.opening);

  /// The route mounted. Reopening with a preserved query enters TYPING
  /// directly (US-1 STEP 8); a fresh surface enters ACTIVE.
  void surfaceReady() {
    if (state.phase != UniversalSearchPhase.opening) return;
    final hasQuery = state.query.trim().isNotEmpty;
    _goTo(hasQuery ? UniversalSearchPhase.typing : UniversalSearchPhase.active);
    if (hasQuery) {
      onQueryChanged(state.query);
    }
  }

  /// Begin the closing flight. The query is PRESERVED — never cleared.
  void close() {
    _debounce?.cancel();
    if (state.canGoTo(UniversalSearchPhase.closing)) {
      _goTo(UniversalSearchPhase.closing);
    }
  }

  /// The route fully exited — back to CLOSED.
  void surfaceClosed() {
    if (state.phase == UniversalSearchPhase.closing) {
      _goTo(UniversalSearchPhase.closed);
    }
  }

  // ---------------------------------------------------------------------------
  // Query + suggestions (debounced, version-guarded).
  // ---------------------------------------------------------------------------

  void onQueryChanged(String text) {
    final query = text.trim();
    switch (state.phase) {
      case UniversalSearchPhase.active:
        if (query.isEmpty) {
          state = state.copyWith(query: text);
          return;
        }
        _goTo(UniversalSearchPhase.typing);
      case UniversalSearchPhase.typing:
        if (query.isEmpty) {
          _goTo(UniversalSearchPhase.active);
        }
      case UniversalSearchPhase.results:
      case UniversalSearchPhase.aiResult:
        // Editing the field always leaves the results view first.
        _goTo(UniversalSearchPhase.typing);
      case UniversalSearchPhase.closed:
      case UniversalSearchPhase.opening:
      case UniversalSearchPhase.searching:
      case UniversalSearchPhase.closing:
        state = state.copyWith(query: text);
        return;
    }
    state = state.copyWith(query: text);
    preserveQuery(text); // US-1 STEP 8 — the query outlives the surface.

    _debounce?.cancel();
    if (query.length < 2) {
      state = state.copyWith(
        suggestions: const [],
        suggestionsLoading: false,
      );
      return;
    }
    state = state.copyWith(suggestionsLoading: true);
    _debounce = Timer(_kDebounce, () => _fetchSuggestions(query));
  }

  Future<void> _fetchSuggestions(String query) async {
    final version = ++_suggestVersion;
    try {
      final suggestions = await suggestionsDelegate.suggest(query);
      if (version != _suggestVersion) return;
      state = state.copyWith(
        suggestionsLoading: false,
        suggestions: suggestions,
      );
    } catch (_) {
      if (version != _suggestVersion) return;
      state = state.copyWith(
        suggestionsLoading: false,
        suggestions: const [], // the page layer renders the local fallback
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Submission — SearchIntentParser door (US-1 STEP 14).
  // ---------------------------------------------------------------------------

  /// Submit the current query. A query that compiles into a valid intent
  /// runs through the EXISTING vertical controllers; anything else keeps
  /// the established AI sheet flow (page layer renders it).
  Future<void> submit() async {
    final text = state.query.trim();
    if (text.isEmpty) return;
    _debounce?.cancel();

    final parsed = SearchIntentParser.parse(text);
    if (parsed.isValid && parsed.destination != null) {
      await _runStructured(parsed);
    } else {
      _goTo(UniversalSearchPhase.searching);
      state = state.copyWith(aiInterpreting: true);
    }
  }

  Future<void> _runStructured(ParsedSearchIntent parsed) async {
    final version = ++_searchVersion;
    _goTo(UniversalSearchPhase.searching);
    state = state.copyWith(
      aiInterpreting: false,
      structuredIntent: StructuredTravelIntent(
        type: parsed.service!,
        origin: parsed.origin,
        destination: parsed.destination,
        date: parsed.date,
        returnDate: parsed.returnDate,
        guests: parsed.passengers,
      ),
    );

    final sections = await _executeIntent(state.structuredIntent!);
    if (version != _searchVersion) return;

    if (sections.isEmpty) {
      state = state.copyWith(resultSections: const []);
      _goTo(UniversalSearchPhase.aiResult);
      return;
    }
    state = state.copyWith(resultSections: sections);
    _goTo(UniversalSearchPhase.results);
  }

  /// Runs an intent through the EXISTING controllers and adapts the offers
  /// into renderable Home sections. `hotel_search` behavioral events fire
  /// from inside the hotel controller on success — same as the vertical
  /// flows, no duplicate event schema.
  Future<List<HomeSection>> _executeIntent(StructuredTravelIntent intent) async {
    final fallback = DateTime.now().add(const Duration(days: 7));
    switch (intent.type) {
      case 'flight':
        await flightSearch.search(FlightSearchParams(
          origin: intent.origin ?? 'CAI',
          destination: intent.destination!,
          departureDate: intent.date ?? fallback,
          returnDate: intent.returnDate,
          adults: intent.guests ?? 1,
        ));
        return offersToHomeSections(flightSearch.state.results);
      case 'hotel':
        await hotelSearch.search(HotelSearchParams(
          destination: intent.destination!,
          checkIn: intent.date ?? fallback,
          checkOut:
              intent.returnDate ?? (intent.date ?? fallback).add(const Duration(days: 2)),
          adults: intent.guests ?? 2,
        ));
        return offersToHomeSections(hotelSearch.state.results);
      case 'car':
        await carSearch.search(CarSearchParams(
          pickupLocation: intent.origin ?? intent.destination!,
          dropoffLocation: intent.destination!,
          pickupDateTime: intent.date ?? fallback,
          dropoffDateTime: (intent.date ?? fallback).add(const Duration(days: 3)),
        ));
        return offersToHomeSections(carSearch.state.results);
      default:
        return const <HomeSection>[];
    }
  }

  /// The AI flow (page layer) landed with product sections.
  void aiResultsReady(List<HomeSection> sections, String? narrative) {
    if (state.phase != UniversalSearchPhase.searching) return;
    state = state.copyWith(
      aiInterpreting: false,
      aiNarrative: narrative,
      resultSections: sections,
    );
    _goTo(UniversalSearchPhase.aiResult);
  }

  /// The AI flow failed — the surface stays actionable.
  void aiResultsFailed() {
    if (state.phase != UniversalSearchPhase.searching) return;
    state = state.copyWith(aiInterpreting: false, aiNarrative: null);
    _goTo(UniversalSearchPhase.aiResult);
  }

  // ---------------------------------------------------------------------------
  // Follow-ups (US-1 STEP 20 — only the two intent-patchable ones).
  // ---------------------------------------------------------------------------

  Future<void> applyFollowUp(FollowUpAction action) async {
    final intent = state.structuredIntent;
    if (intent == null) return;
    final version = ++_searchVersion;
    _goTo(UniversalSearchPhase.searching);

    // Patch the intent (US-0 §12): a follow-up is a NEW intent, the
    // original stays immutable. The two US-1 actions re-run the same
    // intent through the existing controllers — the vertical forms carry
    // the price refinements in their own flows.
    final patched = intent.copyWith();
    state = state.copyWith(structuredIntent: patched);

    final sections = await _executeIntent(patched);
    if (version != _searchVersion) return;
    state = state.copyWith(resultSections: sections);
    _goTo(sections.isEmpty
        ? UniversalSearchPhase.aiResult
        : UniversalSearchPhase.results);
  }

  // ---------------------------------------------------------------------------
  // Recents — submit-only updates (US-1 STEP 9).
  // ---------------------------------------------------------------------------

  Future<void> loadRecents() async {
    final recents = <String>[];
    try {
      for (var i = 0; i < _kRecentLimit; i++) {
        final entry = await cache.read('$_kRecentPrefix$i');
        final text = entry?['text'] as String?;
        if (text == null || text.trim().isEmpty) break;
        recents.add(text);
      }
    } catch (_) {
      // Unreadable history must never block the search surface.
    }
    state = state.copyWith(recents: recents);
  }

  /// Recording a recent is allowed ONLY on submit.
  Future<void> recordRecent(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;
    final updated = <String>[
      trimmed,
      ...state.recents.where((e) => e != trimmed),
    ].take(_kRecentLimit).toList();
    state = state.copyWith(recents: updated);
    try {
      for (var i = 0; i < _kRecentLimit; i++) {
        final key = '$_kRecentPrefix$i';
        if (i < updated.length) {
          await cache.write(key, <String, dynamic>{'text': updated[i]});
        } else if (await cache.contains(key)) {
          await cache.delete(key);
        }
      }
    } catch (_) {
      // Best-effort persistence only.
    }
  }

  Future<void> removeRecentAt(int index) async {
    final updated = <String>[...state.recents]..removeAt(index);
    state = state.copyWith(recents: updated);
    try {
      for (var i = 0; i < _kRecentLimit; i++) {
        final key = '$_kRecentPrefix$i';
        if (i < updated.length) {
          await cache.write(key, <String, dynamic>{'text': updated[i]});
        } else if (await cache.contains(key)) {
          await cache.delete(key);
        }
      }
    } catch (_) {
      // Best-effort persistence only.
    }
  }

  Future<void> clearRecents() async {
    state = state.copyWith(recents: const []);
    try {
      final keys = await cache.keys();
      for (final key in keys) {
        if (key.startsWith(_kRecentPrefix)) {
          await cache.delete(key);
        }
      }
    } catch (_) {
      // Best-effort persistence only.
    }
  }

  // ---------------------------------------------------------------------------
  // Selection (booking hand-off stays with SelectedOffer in the page).
  // ---------------------------------------------------------------------------

  void selectResult(String id) {
    state = state.copyWith(selectedResultId: id);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Delegate over `aiSuggestionsServiceProvider` — kept abstract so tests
/// stub typeahead without HTTP.
abstract class AiSuggestionsDelegate {
  Future<List<String>> suggest(String query);
}

/// Riverpod wiring (US-1): real delegates over the existing services and
/// controllers. Nothing is re-implemented here.
///
/// `autoDispose` keeps the surface state route-scoped: a fresh machine is
/// born on every push of `/smart-search` (query preservation across
/// close/reopen is carried by the controller's recent ring + the field
/// text itself survives through the retained provider while the app
/// lives) — the page drives OPENING -> ACTIVE/TYPING on mount.
final universalSearchControllerProvider = StateNotifierProvider.autoDispose<
    UniversalSearchController, UniversalSearchState>((ref) {
  return UniversalSearchController(
    suggestionsDelegate: _AiApiSuggestionsDelegate(
      ref.watch(aiSuggestionsServiceProvider),
    ),
    cache: ref.watch(offlineCacheProvider),
    flightSearch: ref.watch(flightSearchControllerProvider.notifier),
    hotelSearch: ref.watch(hotelSearchControllerProvider.notifier),
    carSearch: ref.watch(carSearchControllerProvider.notifier),
  );
});

class _AiApiSuggestionsDelegate implements AiSuggestionsDelegate {
  _AiApiSuggestionsDelegate(this._service);

  final dynamic _service;

  @override
  Future<List<String>> suggest(String query) async {
    return _service.suggest(query) as Future<List<String>>;
  }
}
